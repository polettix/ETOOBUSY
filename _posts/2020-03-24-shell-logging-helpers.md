---
title: Shell logging helpers
type: post
tags: [ shell, coding ]
comment: true
date: 2020-03-24 08:00:00 +0100
published: false
---

**TL;DR**

> Where we look at a few functions to log on standard error.

Some time ago I fell in love with [Log::Log4perl][]. To the point that I
wrote [Log::Log4perl::Tiny][], a stripped down replacement that served me
well in the years.

In the shell, I use to define similar functions, usually with less
functionality (i.e. `_LOG` is quite crude but effective):

```shell
_LOG() {
   : ${LOGLEVEL:='INFO'}
   LEVELS='
TRACE TRACE DEBUG INFO WARN ERROR FATAL
DEBUG       DEBUG INFO WARN ERROR FATAL
INFO              INFO WARN ERROR FATAL
WARN                   WARN ERROR FATAL
ERROR                       ERROR FATAL
FATAL                             FATAL
   '
   local timestamp="$(date '+%Y-%m-%dT%H%M%S%z')"
   if printf '%s' "$LEVELS" \
         | grep "^$LOGLEVEL .* $1" >/dev/null 2>&1 ; then
      printf >&2 '[%s] [%5s] %s\n' "$timestamp" "$@"
   fi
}
TRACE()  { _LOG TRACE "$*"; }
DEBUG()  { _LOG DEBUG "$*"; }
INFO()   { _LOG INFO  "$*"; }
WARN()   { _LOG WARN  "$*"; }
ERROR()  { _LOG ERROR "$*"; }
FATAL()  { _LOG FATAL "$*"; }
LOGDIE() { FATAL "$*"; exit 1; }
```

I hope this can be helpful!

[Log::Log4perl]: https://metacpan.org/pod/Log::Log4perl
[Log::Log4perl::Tiny]: https://metacpan.org/pod/Log::Log4perl::Tiny
