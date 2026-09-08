#!/bin/sh
# Best-effort terminal notification. Native TUI notifications are also enabled.
if [ -t 2 ]; then
  printf '\a' >&2
fi
exit 0

