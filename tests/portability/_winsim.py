"""Windows path-separator simulation harness (portability suite, issue #171).

Written during the 2026-09-27 stress test and kept as the shared fixture for
tests/portability/test_*.py.

Loads a REAL module from the repo with `os` swapped for a fake whose `path` is
ntpath (sep='\\', altsep='/'), and whose filesystem calls translate a
Windows-shaped path back to the macOS filesystem:  C:\\a\\b  <->  /a/b.
Drive C: is mapped to the POSIX root, so the real clone is reachable as
C:\\private\\tmp\\...\\repo  and every os.walk / relpath / join produces the
backslash-separated strings real Windows Python produces.

It also holds the host-capability skips every test file shares (last section): a
case whose mechanism this Python or this host lacks is skipped with its reason.
"""
import builtins
import importlib.util
import io
import ntpath as _real_ntpath
import os as _os
import subprocess as _sp
import sys
import types

_real_open = builtins.open


def to_posix(p):
    if p is None or isinstance(p, int):
        return p
    if isinstance(p, bytes):
        return _os.fsencode(to_posix(_os.fsdecode(p)))
    p = _os.fspath(p)
    if len(p) >= 2 and p[1] == ":" and p[0].isalpha():
        p = p[2:] or "\\"
    return p.replace("\\", "/")


def to_win(p):
    if isinstance(p, bytes):
        return _os.fsencode(to_win(_os.fsdecode(p)))
    if p.startswith("/"):
        return "C:" + p.replace("/", "\\")
    return p.replace("/", "\\")


# ---- ntpath copy whose FS predicates translate ------------------------------
_spec = importlib.util.find_spec("ntpath")
nt = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(nt)


def _wrap1(fn):
    def w(p, *a, **k):
        return fn(to_posix(p), *a, **k)
    return w


for _n in ("exists", "lexists", "isdir", "isfile", "islink", "getmtime",
           "getsize", "getatime", "getctime", "isjunction", "ismount"):
    if hasattr(_os.path, _n):
        setattr(nt, _n, _wrap1(getattr(_os.path, _n)))


def _abspath(p):
    p = _os.fspath(p)
    if not nt.isabs(p):
        p = nt.join(fake.getcwd(), p)
    return nt.normpath(p)


def _realpath(p, *a, **k):
    p = _abspath(p)
    rp = _os.path.realpath(to_posix(p))
    return to_win(rp)


def _samefile(a, b):
    return _os.path.samefile(to_posix(a), to_posix(b))


nt.abspath = _abspath
nt.realpath = _realpath
nt.samefile = _samefile


def _expanduser(p):
    p = _os.fspath(p)
    if not p.startswith("~"):
        return p
    home = to_win(_os.path.expanduser("~"))
    i = 1
    while i < len(p) and p[i] not in "/\\":
        i += 1
    if i != 1:
        return p
    return home + p[i:]


nt.expanduser = _expanduser

# ---- fake os ----------------------------------------------------------------
fake = types.ModuleType("os")
fake.__dict__.update({k: v for k, v in _os.__dict__.items() if not k.startswith("__")})
fake.path = nt
fake.sep = "\\"
fake.altsep = "/"
fake.pathsep = ";"
fake.linesep = "\r\n"
fake.name = "nt"


def _getcwd():
    return to_win(_os.getcwd())


fake.getcwd = _getcwd
for _n in ("chdir", "listdir", "stat", "lstat", "makedirs", "mkdir", "remove",
           "unlink", "rmdir", "access", "readlink", "utime", "chmod", "truncate"):
    if hasattr(_os, _n):
        def _mk(fn):
            def w(p=".", *a, **k):
                return fn(to_posix(p), *a, **k)
            return w
        setattr(fake, _n, _mk(getattr(_os, _n)))


def _open(p, *a, **k):
    return _os.open(to_posix(p), *a, **k)


fake.open = _open


def _rename(a, b, *x, **k):
    return _os.rename(to_posix(a), to_posix(b), *x, **k)


def _replace(a, b, *x, **k):
    return _os.replace(to_posix(a), to_posix(b), *x, **k)


fake.rename = _rename
fake.replace = _replace


class _Entry:
    def __init__(self, e, base):
        self._e = e
        self.name = e.name
        self.path = nt.join(base, e.name) if base not in ("", ".") or True else e.name

    def is_dir(self, **k):
        return self._e.is_dir(**k)

    def is_file(self, **k):
        return self._e.is_file(**k)

    def is_symlink(self):
        return self._e.is_symlink()

    def stat(self, **k):
        return self._e.stat(**k)

    def inode(self):
        return self._e.inode()

    def __fspath__(self):
        return self.path


class _Scandir:
    def __init__(self, p):
        self._p = p
        self._it = _os.scandir(to_posix(p))

    def __iter__(self):
        for e in self._it:
            yield _Entry(e, self._p)

    def __enter__(self):
        return self

    def __exit__(self, *a):
        self._it.close()

    def close(self):
        self._it.close()


def _scandir(p="."):
    return _Scandir(p)


fake.scandir = _scandir


def _walk(top, topdown=True, onerror=None, followlinks=False):
    top = _os.fspath(top)
    try:
        entries = list(_scandir(top))
    except OSError as err:
        if onerror is not None:
            onerror(err)
        return
    dirs, nondirs = [], []
    for e in entries:
        try:
            isd = e.is_dir() if followlinks else (e.is_dir() and not e.is_symlink())
        except OSError:
            isd = False
        (dirs if isd else nondirs).append(e.name)
    if topdown:
        yield top, dirs, nondirs
        for d in dirs:
            yield from _walk(nt.join(top, d), topdown, onerror, followlinks)
    else:
        for d in dirs:
            yield from _walk(nt.join(top, d), topdown, onerror, followlinks)
        yield top, dirs, nondirs


fake.walk = _walk


def fake_open(file, *a, **k):
    if isinstance(file, (str, bytes)) or hasattr(file, "__fspath__"):
        file = to_posix(file)
    return _real_open(file, *a, **k)


# ---- subprocess proxy: translate cwd, and give git's Windows output shape ---
def _fix_cmd_out(cmd, out):
    """git for Windows prints absolute paths as C:/x/y (forward slashes)."""
    if out is None:
        return out
    try:
        c = cmd if isinstance(cmd, str) else " ".join(map(str, cmd))
    except Exception:
        return out
    if "rev-parse" in c and ("--show-toplevel" in c or "--absolute-git-dir" in c
                             or "--git-common-dir" in c or "--git-dir" in c):
        def conv(s):
            lines = s.split("\n")
            return "\n".join(("C:" + l) if l.startswith("/") else l for l in lines)
        if isinstance(out, bytes):
            return conv(out.decode()).encode()
        return conv(out)
    return out


def _tr_kwargs(k):
    if "cwd" in k and k["cwd"] is not None:
        k["cwd"] = to_posix(k["cwd"])
    return k


def _tr_cmd(cmd):
    if isinstance(cmd, (list, tuple)):
        return [to_posix(x) if isinstance(x, str) and len(x) > 2 and x[1] == ":" else x for x in cmd]
    return cmd


class _SP(types.ModuleType):
    pass


fsub = _SP("subprocess")
fsub.__dict__.update({k: v for k, v in _sp.__dict__.items() if not k.startswith("__")})


def _run(cmd, *a, **k):
    r = _sp.run(_tr_cmd(cmd), *a, **_tr_kwargs(k))
    r.stdout = _fix_cmd_out(cmd, r.stdout)
    return r


def _check_output(cmd, *a, **k):
    return _fix_cmd_out(cmd, _sp.check_output(_tr_cmd(cmd), *a, **_tr_kwargs(k)))


def _call(cmd, *a, **k):
    return _sp.call(_tr_cmd(cmd), *a, **_tr_kwargs(k))


def _check_call(cmd, *a, **k):
    return _sp.check_call(_tr_cmd(cmd), *a, **_tr_kwargs(k))


def _Popen(cmd, *a, **k):
    return _sp.Popen(_tr_cmd(cmd), *a, **_tr_kwargs(k))


fsub.run = _run
fsub.check_output = _check_output
fsub.call = _call
fsub.check_call = _check_call
fsub.Popen = _Popen


def load(path, name=None, argv=None, as_main=False):
    """Import the real module at `path` with os -> fake (ntpath)."""
    path = _os.path.abspath(path)
    name = name or ("__main__" if as_main else "mod_" + _os.path.basename(path).replace("-", "_").replace(".", "_"))
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    mod.__file__ = to_win(path)
    mod.open = fake_open
    saved = {k: sys.modules.get(k) for k in ("os", "os.path", "subprocess")}
    sys.modules["os"] = fake
    sys.modules["os.path"] = nt
    sys.modules["subprocess"] = fsub
    old_argv = sys.argv
    if argv is not None:
        sys.argv = argv
    try:
        spec.loader.exec_module(mod)
    finally:
        for k, v in saved.items():
            if v is None:
                sys.modules.pop(k, None)
            else:
                sys.modules[k] = v
        sys.argv = old_argv
    return mod


def run_main(path, argv=None, stdin=None, cwd=None):
    """Run a script as __main__ under simulation; returns (exit, stdout, stderr)."""
    out, err = io.StringIO(), io.StringIO()
    so, se, si = sys.stdout, sys.stderr, sys.stdin
    oldcwd = _os.getcwd()
    code = 0
    sys.stdout, sys.stderr = out, err
    if stdin is not None:
        sys.stdin = io.StringIO(stdin)
    try:
        if cwd:
            _os.chdir(to_posix(cwd))
        try:
            load(path, as_main=True, argv=[to_win(_os.path.abspath(path))] + list(argv or []))
        except SystemExit as e:
            code = e.code if isinstance(e.code, int) else (0 if e.code is None else 1)
    finally:
        sys.stdout, sys.stderr, sys.stdin = so, se, si
        _os.chdir(oldcwd)
    return code, out.getvalue(), err.getvalue()


# ---- fresh copies of os-dependent stdlib modules, bound to the fake os -------
def _fresh(name):
    spec = importlib.util.find_spec(name)
    m = importlib.util.module_from_spec(spec)
    saved = {k: sys.modules.get(k) for k in ("os", "os.path")}
    sys.modules["os"] = fake
    sys.modules["os.path"] = nt
    try:
        spec.loader.exec_module(m)
    finally:
        for k, v in saved.items():
            sys.modules[k] = v
    return m


ffnmatch = _fresh("fnmatch")
_saved_fn = sys.modules.get("fnmatch")
sys.modules["fnmatch"] = ffnmatch
fglob = _fresh("glob")
fglob.fnmatch = ffnmatch
sys.modules["fnmatch"] = _saved_fn

# ---- pathlib: a WindowsPath that works on this machine ----------------------
import pathlib as _pl


class WinPath(_pl.PureWindowsPath):
    def _real(self):
        s = str(self)
        if not nt.isabs(s) and not s.startswith(("\\", "/")):
            return _pl.PosixPath(to_posix(s))
        return _pl.PosixPath(to_posix(s))

    def _wrap(self, p):
        return type(self)(to_win(str(p)))

    @classmethod
    def cwd(cls):
        return cls(fake.getcwd())

    @classmethod
    def home(cls):
        return cls(to_win(str(_pl.Path.home())))

    def absolute(self):
        return self if self.is_absolute() else type(self)(fake.getcwd()) / self

    def resolve(self, strict=False):
        return type(self)(nt.realpath(str(self.absolute())))

    def expanduser(self):
        return type(self)(nt.expanduser(str(self)))

    def exists(self, **k): return self._real().exists()
    def is_file(self, **k): return self._real().is_file()
    def is_dir(self, **k): return self._real().is_dir()
    def is_symlink(self): return self._real().is_symlink()
    def stat(self, **k): return self._real().stat(**k)
    def lstat(self): return self._real().lstat()
    def read_text(self, *a, **k): return self._real().read_text(*a, **k)
    def read_bytes(self): return self._real().read_bytes()
    def write_text(self, *a, **k): return self._real().write_text(*a, **k)
    def write_bytes(self, *a, **k): return self._real().write_bytes(*a, **k)
    def open(self, *a, **k): return self._real().open(*a, **k)
    def mkdir(self, *a, **k): return self._real().mkdir(*a, **k)
    def unlink(self, *a, **k): return self._real().unlink(*a, **k)
    def rmdir(self): return self._real().rmdir()
    def touch(self, *a, **k): return self._real().touch(*a, **k)
    def chmod(self, *a, **k): return self._real().chmod(*a, **k)
    def samefile(self, o): return self._real().samefile(WinPath(o)._real())
    def rename(self, t): self._real().rename(WinPath(t)._real()); return type(self)(t)
    def replace(self, t): self._real().replace(WinPath(t)._real()); return type(self)(t)

    def iterdir(self):
        base = str(self)
        for c in self._real().iterdir():
            yield self / c.name if base not in (".", "") else type(self)(c.name)

    def glob(self, pat, **k):
        pat = pat.replace("\\", "/")
        for r in self._real().glob(pat, **k):
            yield self._wrap(r)

    def rglob(self, pat, **k):
        pat = pat.replace("\\", "/")
        for r in self._real().rglob(pat, **k):
            yield self._wrap(r)

    def walk(self, *a, **k):
        for root, ds, fs in self._real().walk(*a, **k):
            yield self._wrap(root), ds, fs

    def __fspath__(self):
        return str(self)


fpathlib = types.ModuleType("pathlib")
fpathlib.__dict__.update({k: v for k, v in _pl.__dict__.items() if not k.startswith("__")})
fpathlib.Path = WinPath
fpathlib.WindowsPath = WinPath

_FAKES = {"os": fake, "os.path": nt, "subprocess": fsub, "pathlib": fpathlib,
          "glob": fglob, "fnmatch": ffnmatch}


def load(path, name=None, argv=None, as_main=False):  # noqa: F811 (override)
    path = _os.path.abspath(path)
    name = name or ("__main__" if as_main else "mod_" + _os.path.basename(path).replace("-", "_").replace(".", "_"))
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    mod.__file__ = to_win(path)
    mod.open = fake_open
    saved = {k: sys.modules.get(k) for k in _FAKES}
    sys.modules.update(_FAKES)
    old_argv = sys.argv
    if argv is not None:
        sys.argv = argv
    try:
        spec.loader.exec_module(mod)
    finally:
        for k, v in saved.items():
            if v is None:
                sys.modules.pop(k, None)
            else:
                sys.modules[k] = v
        sys.argv = old_argv
    return mod

# importlib: a sibling loaded by (Windows) path must still be readable
import importlib.util as _ilu
_real_sffl = _ilu.spec_from_file_location


def _sffl(name, location=None, *a, **k):
    if isinstance(location, str) and len(location) > 2 and location[1] == ":":
        location = to_posix(location)
    return _real_sffl(name, location, *a, **k)


_ilu.spec_from_file_location = _sffl


# ---- what this host can do ---------------------------------------------------
# A case that leans on a mechanism the host lacks does not fail there: it passes,
# and pins nothing. So it SKIPS, and the gate's verdict line names the reason.
import locale as _locale
import shutil as _shutil
import tempfile as _tempfile
import unittest as _unittest

# #171 F3: below 3.10, `-W error::EncodingWarning` is "Invalid -W option ignored" and
# -X warn_default_encoding does nothing, so a locale-default read runs as before.
needs_encoding_warning = _unittest.skipUnless(
    hasattr(builtins, "EncodingWarning"),
    "EncodingWarning and -X warn_default_encoding are new in Python 3.10; "
    "below it the strict flags turn nothing into an error")
# ...and below 3.11 subprocess decodes text output without asking locale.getencoding,
# so patching it (the Windows ANSI code page) changes nothing.
needs_getencoding = _unittest.skipUnless(
    hasattr(_locale, "getencoding"),
    "locale.getencoding is new in Python 3.11; below it subprocess text decoding "
    "cannot be pointed at a Windows code page")


def _can_symlink():
    d = _tempfile.mkdtemp(prefix="winsim-symlink-")
    try:
        _os.symlink("target", _os.path.join(d, "link"))
        return True
    except (OSError, NotImplementedError, AttributeError):
        return False
    finally:
        _shutil.rmtree(d, ignore_errors=True)


# #171 F4: Windows refuses os.symlink without Developer Mode or elevation (WinError
# 1314); one unguarded call in a setUpModule errored every case in its file.
CAN_SYMLINK = _can_symlink()
needs_symlink = _unittest.skipUnless(
    CAN_SYMLINK, "os.symlink is refused on this host (Windows needs Developer Mode or elevation)")
