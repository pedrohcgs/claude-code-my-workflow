% BibTeX bibliography style `aer' (American Economic Review)
% this file is based on the `harvard' family of files
        % version 0.99a for BibTeX versions 0.99a or later, LaTeX version 2.09.
        % Copyright (C) 1991, all rights reserved.
        % Copying of this file is authorized only if either
        % (1) you make absolutely no changes to your copy, including name, or
        % (2) if you do make changes, you name it something other than
        % btxbst.doc, plain.bst, unsrt.bst, alpha.bst, abbrv.bst, agsm.bst,
        % dcu.bst, cje.bst, aer.bst, or kluwer.bst.
        % This restriction helps ensure that all standard styles are identical.

% ACKNOWLEDGEMENT:
%   This document is a modified version of alpha.bst to which it owes much of
%   its functionality.

% AUTHOR
%   Peter Williams, Key Centre for Design Quality, Sydney University
%   e-mail: peterw@archsci.arch.su.oz.au

ENTRY
  { address author booktitle chapter edition editor howpublished institution
    journal key month note number organization pages publisher school
    series title type volume year}
  { field.used }
  { label.touse extra.label sort.label list.year }


FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}

FUNCTION {and}
{   {}
    { pop$ #0 }
  if$
}

FUNCTION {or}
{   { pop$ #1 }
    {}
  if$
}

INTEGERS {quoted italic bold plain attribute
        space comma tiedcomma semicolon colon period block empty separator
        prev.separator next.separator next.attribute}

STRINGS { s temp f name.list first.name.format later.name.formats name.style}

FUNCTION {init.state.consts}
{
  #100  'quoted :=
  #200  'italic :=
  #300  'bold   :=
  #400  'plain  :=

  #7 'space :=
  #6 'comma :=
%  #5 'tiedcomma :=
%  #4 'semicolon :=
  #3 'colon :=
  #2 'period :=
  #1 'block :=
  #0 'empty :=
}

FUNCTION {output2}
{
% Wrap the attribute.
    attribute bold = {"{\bf " swap$ * "}" *} {} if$
    attribute italic = {"{\it " swap$ * "}" *} {} if$
    attribute quoted = {"``" swap$ * "''" *} {} if$
% Append additional separators
    separator comma = {"," * space 'separator :=} {} if$
%    separator tiedcomma = {",~" * empty 'separator :=} {} if$
    separator space = {" " *} {} if$
    write$
    separator block = {newline$ "\newblock " write$} {} if$
% Update variables, and put the new string back on the stack
    next.attribute 'attribute :=
    next.separator 'separator :=
    temp
}

% <string> <separator> <string> <attribute> <final separator> output <string>
FUNCTION {output.nonnull}
{   'next.separator :=
    'next.attribute :=
    'temp :=
    'prev.separator :=
% If the new separator is stronger than the previous one, use it.
    prev.separator separator < {prev.separator 'separator :=} {} if$
% Append most separators to the string.
    separator block = {add.period$} {} if$
    separator period = {add.period$ space 'separator :=} {} if$
%    separator semicolon = {";" * space 'separator :=} {} if$
    separator colon = {":" * space 'separator :=} {} if$
    separator comma = attribute quoted = and
        {"," * space 'separator :=} {} if$
    output2
}

FUNCTION {output}
{   'next.separator :=
    'next.attribute :=
    duplicate$ empty$
        {pop$ pop$}
        {next.attribute next.separator output.nonnull}
        if$
}

FUNCTION {output.check}
{   's :=
    'next.separator :=
    'next.attribute :=
    duplicate$ empty$
        {pop$ pop$ "empty " s * " in " * cite$ * warning$ }
        {next.attribute next.separator output.nonnull}
        if$
}

FUNCTION {item.check}
{ 'temp :=
  empty$
    { "empty " temp * " in " * cite$ * warning$ }
    {}
  if$
}

FUNCTION {plain.space} { plain space }

FUNCTION {plain.space.output} { plain.space output }

FUNCTION {plain.comma} { plain comma }

FUNCTION {fin.entry}
{ 
  block note plain.space.output
  period "" plain empty output.nonnull pop$
  newline$
}

FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    {}
  if$
}

FUNCTION {emphasize}
{ duplicate$ empty$
    { pop$ "" }
    { "{\em " swap$ * "}" * }
  if$
}

FUNCTION {quote}
{ duplicate$ empty$
    { pop$ "" }
    { add.period$ "`" swap$ * "'" * }
  if$
}


% <prev name list> <new name list> compare.names <modified name list>
INTEGERS {len1 len2 i}
FUNCTION {compare.names}
{   's :=
    'temp :=
    temp num.names$ 'len1 :=
    s num.names$ 'len2 :=
% len1 := min(len1,len2)
    len1 len2 > {len2 'len1 :=} {} if$
% start with an empty string, then while the components are the same
% add "\bysame"
    ""
    #1 'i :=
    {i len1 > not}
    { temp i "{ff }{vv }{ll}{ jj}" format.name$
% duplicate$ i int.to.str$ * warning$
      s i "{ff }{vv }{ll}{ jj}" format.name$
% duplicate$ i int.to.str$ * warning$
      =
        { #1 i < {" and " *} {} if$
          "\bysame{}" * i #1 + 'i :=}
        {#-1 'len1 :=}
        if$
      }
    while$
% add the rest of the second string
    {i len2 > not}
    { #1 i < {" and " *} {} if$
      s i "{ff }{vv }{ll}{ jj}" format.name$ *
      i #1 + 'i :=
      }
    while$
% duplicate$ warning$
}

INTEGERS { nameptr namesleft numnames }

FUNCTION {format.names}
{ 'name.list :=
  'name.style :=
  'later.name.formats :=
  's := % binary separator
  'first.name.format :=
  #1 'nameptr :=
  name.list num.names$ 'numnames :=
% If we're to make this entry bold or something, prepend to the string of names
  name.style "" = {} {"{" name.style *} if$
  numnames 'namesleft :=
    { namesleft #0 > }
    { name.list nameptr nameptr #1 = {first.name.format} {later.name.formats} if$
                format.name$ 'temp :=
      nameptr #1 >
        { namesleft #1 >
            { ", " * temp * }
            { temp "others" =
                { " et~al." * }
                {nameptr #2 =   % handle ", and" vs " and "
                    {s * temp *}
                    {", and " * temp * }
                    if$
                }
                if$
            }
            if$
        }
        'temp
        if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
% If we're to make this entry bold or something, append to the string of names
  name.style "" = {} {"}" * *}  if$
}

FUNCTION {format.authors}
{ 'temp :=
    "{vv~}{ll}{, jj}{, ff}" " and " "{ff~}{vv~}{ll}{, jj}" "" temp
                format.names
}

FUNCTION {format.editors}
{ 'temp :=
    "{vv~}{ll}{, jj}{, ff}" " and " "{ff~}{vv~}{ll}{, jj}" ""
                temp format.names
      editor num.names$ #1 >
        { ", eds" * }
        { ", ed." * }
      if$
}

FUNCTION {format.editors.notkey}
{ editor empty$
    { "" }
    { "{ff~}{vv~}{ll}{, jj}" " and " "{ff~}{vv~}{ll}{, jj}" ""
                editor format.names
      editor num.names$ #1 > {", eds."} {", ed."} if$
      *
    }
  if$
}

FUNCTION {format.title}
{ space title quoted comma }

FUNCTION {n.dashify}
{ 'temp :=
  ""
    { temp empty$ not }
    { temp #1 #1 substring$ "-" =
        { temp #1 #2 substring$ "--" = not
            { "--" *
              temp #2 global.max$ substring$ 'temp :=
            }
            {   { temp #1 #1 substring$ "-" = }
                { "-" *
                  temp #2 global.max$ substring$ 'temp :=
                }
              while$
            }
          if$
        }
        { temp #1 #1 substring$ *
          temp #2 global.max$ substring$ 'temp :=
        }
      if$
    }
  while$
}

FUNCTION {format.btitle}
{ title emphasize
}

FUNCTION {tie.or.space.connect}
{ duplicate$ text.length$ #3 <
    { "~" }
    { " " }
  if$
  swap$ * *
}

FUNCTION {either.or.check}
{ empty$
    'pop$
    { "can't use both " swap$ * " fields in " * cite$ * warning$ }
  if$
}

FUNCTION {format.bvolume}
{ volume empty$
    { "" }
    { "Vol." volume tie.or.space.connect
      series empty$
        {}
        { " of " * series emphasize * }
      if$
      "volume and number" number either.or.check
    }
  if$
}

FUNCTION {format.bvolume.output}
  {comma format.bvolume plain.space.output}

FUNCTION {mid.sentence.q}
{
    separator empty = separator block = separator period = or or not
}

FUNCTION {format.number.series}
{ volume empty$
    { number empty$
        {series field.or.null}
        { mid.sentence.q
            { "number" }
            { "Number" }
          if$
          number tie.or.space.connect
          series empty$
            { "there's a number but no series in " cite$ * warning$ }
            { add.period$ " In " * series quote * }
          if$
        }
      if$
    }
    { "" }
  if$
}

FUNCTION {format.edition.output}
{ edition empty$
    { }
    { comma edition
      mid.sentence.q { "l" } { "t" } if$
      change.case$ " ed." *
      plain.space.output
    }
  if$
}

FUNCTION {format.publisher.address}
{
    address empty$
        {comma publisher plain.comma output}
        {publisher empty$
            {}
            {comma address plain colon output
             colon publisher plain.comma output}
            if$}
         if$
}

INTEGERS { multiresult }

FUNCTION {multi.page.check}
{ 'temp :=
  #0 'multiresult :=
    { multiresult not
      temp empty$ not
      and
    }
    { temp #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
        { #1 'multiresult := }
        { temp #2 global.max$ substring$ 'temp := }
      if$
    }
  while$
  multiresult
}

FUNCTION {format.pages}
{ pages empty$
    { "" }
    { pages multi.page.check
        { "pp.~" pages n.dashify * }
        { "p.~" pages * }
      if$
    }
  if$
}

FUNCTION {output.month.year}
  {
      space month plain.space.output
      space year plain.comma "year" output.check
  }

FUNCTION {output.vol.num.pages}
{ space volume italic space output
  number empty$
    {}
    { space "(" number * ")" * plain.comma output.nonnull
      volume empty$
        { "there's a number but no volume in " cite$ * warning$ }
        {}
      if$
    }
  if$
% "*** a" warning$
  comma 'next.separator :=      % hack
  pages empty$
    {}
    { number empty$ volume empty$ and
        { comma format.pages plain.space.output }
        { comma pages n.dashify plain.space.output }
      if$
    }
  if$
}

FUNCTION {format.chapter.pages}
{ chapter empty$
    'format.pages
    { type empty$
        { "chapter" }
        { type "l" change.case$ }
      if$
      chapter tie.or.space.connect
      pages empty$
        {}
        { ", " * format.pages * }
      if$
    }
  if$
}

FUNCTION {output.in.ed.booktitle}
{ booktitle "booktitle" item.check
  comma "in" plain.space output.nonnull
  editor empty$
    { space booktitle quoted space output.nonnull}
    { space format.editors.notkey plain.space output.nonnull
          comma booktitle italic comma output.nonnull
     }
     if$
}

FUNCTION {empty.misc.check}
{ author empty$ title empty$ howpublished empty$
  month empty$ year empty$ note empty$
  and and and and and
  key empty$ not and
    { "all relevant fields are empty in " cite$ * warning$ }
    {}
  if$
}

FUNCTION {format.thesis.type}
{ type empty$
    {}
    { pop$
      type "t" change.case$
    }
  if$
}

FUNCTION {format.tr.number}
{ type empty$
    { "Technical Report" }
    'type
  if$
  number empty$
    {  }
    { number tie.or.space.connect }
  if$
}

FUNCTION {format.article.crossref}
{ key empty$
    { journal empty$
        { "need key or journal for " cite$ * " to crossref " * crossref *
          warning$
          ""
        }
        { "in {\it " journal * "\/} \cite{" * crossref * "}" *}
      if$
    }
    { add.period$ "In \citeasnoun{" crossref * "}" * }
  if$
 
}

FUNCTION {format.book.crossref}
{ volume empty$
    { "empty volume in " cite$ * "'s crossref of " * crossref * warning$
      "in "
    }
    { "Vol." volume tie.or.space.connect
      " of " *
    }
  if$
  editor empty$
  editor field.or.null author field.or.null =
  or
    { key empty$
        { series empty$
            { "need editor, key, or series for " cite$ * " to crossref " *
              crossref * warning$
              "" *
            }
            { "{\it " * series * "\/} \cite{" * crossref * "}" *}
          if$
        }
        { " \citeasnoun{" * crossref * "}" * }
      if$
    }
    { " \citeasnoun{" * crossref * "}" * }
  if$
}

FUNCTION {output.incoll.inproc.crossref}
{ editor empty$
  editor field.or.null author field.or.null =
  or
    { key empty$
        { booktitle empty$
            { "need editor, key, or booktitle for " cite$ * " to crossref " *
              crossref * warning$
            }
            { period "In {\it " booktitle * "\/}" * " \cite{" * crossref * "}" * plain.space output.nonnull}
          if$
        }
        { period "In \citeasnoun{" crossref * "}" * plain.space output.nonnull}
      if$
    }
    { period "In \citeasnoun{" crossref * "}" * plain.space output.nonnull}
  if$
}

INTEGERS { len }

FUNCTION {chop.word}
{ 's :=
  'len :=
  s #1 len substring$ =
    { s len #1 + global.max$ substring$ }
    's
  if$
}

INTEGERS { author.field editor.field organization.field title.field key.field }

FUNCTION {init.field.constants}
{ #0 'author.field :=
  #1 'editor.field :=
  #2 'organization.field :=
  #3 'title.field :=
  #4 'key.field :=
}

FUNCTION {format.lab.names.abbr}
{ 'name.list :=
  name.list num.names$ 'numnames :=
  numnames #1 >
    { numnames #2 >
        { name.list #1 "{vv~}{ll}" format.name$ " et al." * }
        { name.list #2 "{ff }{vv }{ll}{ jj}" format.name$ "others" =
            { name.list #1 "{vv~}{ll}" format.name$ " et al." * }
            { name.list #1 "{vv~}{ll}" format.name$ " and " *
              name.list #2 "{vv~}{ll}" format.name$ * 
            }
          if$
        }
      if$
      field.used editor.field = {", eds" *} {} if$
    }
    {
        name.list #1 "{vv~}{ll}" format.name$
        field.used editor.field = {", ed" *} {} if$
    }
  if$
}

FUNCTION {format.lab.names.full}
{ 'name.list :=
  #1 'nameptr :=
  name.list num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { name.list nameptr "{vv~}{ll}" format.name$ 'temp :=
      nameptr #1 >
        { namesleft #1 >
            { ", " * temp * }
            { temp "others" =
                { " et~al." * }
                { " and " * temp * }
              if$
            }
          if$
        }
        'temp
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
  numnames #1 > field.used editor.field = and {", eds" *} {} if$
  numnames #1 = field.used editor.field = and {", ed" *} {} if$
}

STRINGS { prev.author }

FUNCTION {make.list.label}
{author.field field.used =
    { prev.author author compare.names format.authors
         author 'prev.author :=}
    { editor.field field.used =
        { prev.author editor compare.names format.editors
                editor 'prev.author := }
        { organization.field field.used =
            { "The " #4 organization chop.word
                duplicate$ prev.author = {pop$ "\bysame{}"}
                                         {duplicate$ 'prev.author :=} if$}
            { "foo" 'prev.author :=
              title.field field.used =
                { format.btitle }
                { key.field field.used =
                    { key #3 text.prefix$ }
                    { "Internal error :001 on " cite$ * " label" * warning$ }
                  if$
                }
              if$
            }
          if$
        }
      if$
    }
  if$
}

FUNCTION {make.full.label}
{ author.field field.used =
    { author format.lab.names.full }
    { editor.field field.used =
        { editor format.lab.names.full }
        { organization.field field.used =
            { "The " #4 organization chop.word #3 text.prefix$ }
            { title.field field.used =
                { format.btitle }
                { key.field field.used =
                    { key #3 text.prefix$ }
                    { "Internal error :001 on " cite$ * " label" * warning$ }
                  if$
                }
              if$
            }
          if$
        }
      if$
    }
  if$
}

FUNCTION {make.abbr.label}
{ author.field field.used =
    { author format.lab.names.abbr }
    { editor.field field.used =
        { editor format.lab.names.abbr }
        { organization.field field.used =
            { "The " #4 organization chop.word #3 text.prefix$ }
            { title.field field.used =
                { format.btitle }
                { key.field field.used =
                    { key #3 text.prefix$ }
                    { "Internal error :001 on " cite$ * " label" * warning$ }
                  if$
                }
              if$
            }
          if$
        }
      if$
    }
  if$
}

FUNCTION {output.bibitem}
{ newline$
  "\harvarditem[" write$
  make.abbr.label write$
  "]{" write$
  make.full.label write$
  "}{" write$
  list.year write$
  "}{" write$
  cite$ write$
  "}" write$
  newline$
  ""
  empty 'separator :=
  plain 'attribute :=
% }
%
%  FUNCTION {list.label.output}
% {
  space make.list.label bold comma output.nonnull
  }

FUNCTION {author.item.check} {author "author" item.check}

FUNCTION {format.title.if.not.sortkey.check}
{title.field field.used =
    {}
    { format.title "title" output.check }
  if$}

FUNCTION {article}
{ output.bibitem
  author.item.check
  format.title.if.not.sortkey.check
  crossref missing$
    { space journal italic comma "journal" output.check
      output.month.year
      output.vol.num.pages
    }
    { space format.article.crossref plain.space output.nonnull
      comma format.pages plain.space.output
    }
  if$
  fin.entry
}

FUNCTION {book}
{ output.bibitem
    author empty$
    { editor "author and editor" item.check }
    { crossref missing$
        { "author and editor" editor either.or.check }
        {}
      if$
    }
  if$
  title.field field.used =
    {}
    { space title italic space "title" output.check }
  if$
  crossref missing$
    { 
      space format.number.series plain.space.output
      format.edition.output
      format.bvolume.output
      format.publisher.address
      output.month.year
    }
    { space format.book.crossref plain.space output.nonnull
      format.edition.output
    }
  if$
  fin.entry
}

FUNCTION {booklet}
{ output.bibitem
  format.title.if.not.sortkey.check
  space howpublished plain.space.output
  space address plain.space.output
  output.month.year
  fin.entry
}

FUNCTION {inbook}
{ output.bibitem
    author empty$
    { editor "author and editor" item.check }
    { crossref missing$
        { "author and editor" editor either.or.check }
        {}
      if$
    }
  if$
  title.field field.used =
    {}
    { space title italic space "title" output.check }
  if$
  crossref missing$
    { space format.number.series plain.space.output
      format.edition.output
      comma format.bvolume plain.comma output
      format.publisher.address
      output.month.year
    }
    { space format.book.crossref plain.space output.nonnull
      format.edition.output
    }
  if$
  format.chapter.pages "chapter and pages" output.check
  fin.entry
}

FUNCTION {incollection}
{ output.bibitem
  format.title.if.not.sortkey.check
  author.item.check
  crossref missing$
    { output.in.ed.booktitle
      format.edition.output
      format.bvolume.output
      space format.number.series plain.space.output
      format.publisher.address
      output.month.year
    }
    { output.incoll.inproc.crossref }
  if$
  space format.chapter.pages plain.space.output
  fin.entry
}

FUNCTION {inproceedings}
{ output.bibitem
  format.title.if.not.sortkey.check
  author.item.check
  crossref missing$
    { output.in.ed.booktitle
      format.bvolume.output
      space format.number.series plain.space.output
      address empty$
        { space organization plain.space.output
          space publisher plain.space.output
        }
        { space organization plain.space.output
          space publisher plain.space.output
          space address plain.space output.nonnull
        }
      if$
      output.month.year
    }
    { output.incoll.inproc.crossref}
  if$
  space format.pages plain.space.output
  fin.entry
}

FUNCTION {conference} { inproceedings }

FUNCTION {manual}
{ output.bibitem
    title.field field.used =
    {}
    {author empty$ {comma}{space} if$ title italic space "title" output.check }
  if$
  organization.field field.used = organization empty$ or
        {} {space organization plain.space output.nonnull} if$
  format.edition.output
  format.publisher.address
  output.month.year
  fin.entry
}

FUNCTION {mastersthesis}
{ output.bibitem
  author.item.check
  format.title.if.not.sortkey.check
  space "Master's thesis" format.thesis.type plain.space output.nonnull
  comma school plain.space "school" output.check
  comma address plain.space.output
  output.month.year
  fin.entry
}

FUNCTION {misc}
{ output.bibitem
  format.title.if.not.sortkey.check
  space howpublished plain.space.output
  output.month.year
  fin.entry
  empty.misc.check
}

FUNCTION {phdthesis}
{ output.bibitem
    author.item.check
  title.field field.used =
    {}
    { space title quoted period "title" output.check }
  if$
  space "PhD dissertation" format.thesis.type plain.space output.nonnull
  comma school plain.space "school" output.check
  comma address plain.space.output
  output.month.year
  fin.entry
}

FUNCTION {proceedings}
{ output.bibitem
    title.field field.used =
    {}
    { space title italic space "title" output.check }
  if$
  format.bvolume.output
  space format.number.series plain.space.output
  address empty$
    { editor empty$
        {}
        { space organization plain.space.output
        }
      if$
      space publisher plain.space.output
    }
    { editor empty$
        {}
        { space organization plain.space.output }
      if$
      space publisher plain.space.output
      space address plain.space output.nonnull
    }
  if$
  output.month.year
  fin.entry
}

FUNCTION {techreport}
{ output.bibitem
  author.item.check
  format.title.if.not.sortkey.check
  space format.tr.number plain.space output.nonnull
  institution empty$
    {}
    { comma institution plain.space "institution" output.check }
    if$
  comma address plain.space.output
  output.month.year
  fin.entry
}

FUNCTION {unpublished}
{ output.bibitem
    author.item.check
  format.title.if.not.sortkey.check
  output.month.year
  note "note" item.check
  fin.entry
}

FUNCTION {default.type} { misc }

MACRO {jan} {"January"}

MACRO {feb} {"February"}

MACRO {mar} {"March"}

MACRO {apr} {"April"}

MACRO {may} {"May"}

MACRO {jun} {"June"}

MACRO {jul} {"July"}

MACRO {aug} {"August"}

MACRO {sep} {"September"}

MACRO {oct} {"October"}

MACRO {nov} {"November"}

MACRO {dec} {"December"}

READ

EXECUTE {init.field.constants}

FUNCTION {sortify}
{ purify$
  "l" change.case$
}

FUNCTION {author.editor.key.label}
{ author empty$
    { editor empty$
        { title empty$
            { key.field 'field.used := }
            { title.field 'field.used := }
          if$
        }
        { editor.field 'field.used := }
      if$
    }
    { author.field 'field.used := }
  if$
}

FUNCTION {key.organization.label}
 {organization empty$
        { title empty$
            { key.field 'field.used := }
            { title.field 'field.used := }
          if$
        }
        { organization.field 'field.used := }
        if$}

FUNCTION {author.key.organization.label}
{ author empty$
    { key.organization.label}
    { author.field 'field.used := }
    if$
}

FUNCTION {editor.key.organization.label}
{ editor empty$
    { key.organization.label}
    { editor.field 'field.used := }
  if$
}

FUNCTION {sort.format.title}
{ 'temp :=
  "A " #2
    "An " #3
      "The " #4 temp chop.word
    chop.word
  chop.word
  sortify
  #1 global.max$ substring$
}

FUNCTION {calc.label}
{ type$ "book" =
  type$ "inbook" =
  or
    'author.editor.key.label
    { type$ "proceedings" =
        'editor.key.organization.label
        { type$ "manual" =
            'author.key.organization.label
            'author.editor.key.label    % don't really use .editor.
          if$
        }
      if$
    }
  if$
  make.abbr.label
  title.field field.used =
    { sort.format.title }
    { sortify }
  if$
  year field.or.null purify$ #-1 #4 substring$ sortify
  *
  'sort.label :=
}

FUNCTION {first.presort}
{ "abcxyz" 'prev.author :=
  calc.label
  sort.label
  title.field field.used =
    {}
    { "    "
      *
      make.list.label sortify
      *
      "    "
      *
      title field.or.null
      sort.format.title
      *
    }
  if$
  #1 entry.max$ substring$
  'sort.key$ :=
}


ITERATE {first.presort}

SORT

STRINGS { last.sort.label next.extra }

INTEGERS { last.extra.num }

FUNCTION {initialize.last.extra.num}
{ #0 int.to.chr$ 'last.sort.label :=
  "" 'next.extra :=
  #0 'last.extra.num :=
}

FUNCTION {forward.pass}
{ last.sort.label sort.label =
    { last.extra.num #1 + 'last.extra.num :=
      last.extra.num int.to.chr$ 'extra.label :=
    }
    { "a" chr.to.int$ 'last.extra.num :=
      "" 'extra.label :=
      sort.label 'last.sort.label :=
    }
  if$
}

FUNCTION {reverse.pass}
{ next.extra "b" =
    { "a" 'extra.label := }
    {}
  if$
  year empty$
    { "n.d." extra.label * 'list.year := }
    { year extra.label * 'list.year := }
  if$
  extra.label 'next.extra :=
}

EXECUTE {initialize.last.extra.num}

ITERATE {forward.pass}

REVERSE {reverse.pass}

FUNCTION {second.presort}
{ "abcxyz" 'prev.author :=
  make.list.label
  title.field field.used =
    { sort.format.title }
    { sortify }
  if$
  "    "
  *
  list.year field.or.null sortify
  *
  "    "
  *
  title.field field.used =
    {}
    { title field.or.null
      sort.format.title
      *
    }
  if$
  #1 entry.max$ substring$
  'sort.key$ :=
}

ITERATE {second.presort}

SORT


INTEGERS { number.label }

FUNCTION {initialize.longest.label}
{
  #1 'number.label :=
  "abcxyz" 'prev.author :=
}

FUNCTION {longest.label.pass}
{ 
    "" 'extra.label :=
    author empty$ { editor empty$ {"foo"} {editor} if$}
                  {author}
                   if$
    'f :=
% remember this entry to compare to the next one
    author empty$ { editor empty$ {"abcxyz"} {editor} if$} {author} if$
        'prev.author := 
}

EXECUTE {initialize.longest.label}

ITERATE {longest.label.pass}

FUNCTION {begin.bib}
{ preamble$ empty$
    {}
    { preamble$ write$ newline$ }
  if$
  "\ifx\undefined\bysame" write$ newline$
  "\newcommand{\bysame}{\leavevmode\hbox to\leftmargin{\hrulefill\,\,}}"
       write$ newline$
  "\fi" write$ newline$
  "\begin{thebibliography}{xx}" write$ newline$
}

EXECUTE {begin.bib}

EXECUTE {init.state.consts}

FUNCTION {init.call}
 { "abcxyz" 'prev.author := }

EXECUTE {init.call}

ITERATE {call.type$}

FUNCTION {end.bib}
        {newline$ "\end{thebibliography}" write$ newline$ }

EXECUTE {end.bib}

