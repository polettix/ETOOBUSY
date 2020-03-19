---
title: A shell approach
type: post
tags: [ shell, coding ]
comment: true
date: 2020-03-19 23:58:13 +0100
published: true
---

**TL;DR**

> I noticed a pattern in my shell scripts lately.

Well, a few actually, but here's one.

I already wrote about a possible way to implement a [POSIX shell
"modulino"][], like this:

```shell
#!/bin/sh

module_function() {
   printf 'module function here\n'
}

main() {
   module_function
   printf 'main here\n'
}

! grep -- '6f8fc63c06-whatevah-db049fa26dd5953b5771e4' "$0" >/dev/null 2>&1 \
   || main "$@"
```

This allows writing scripts that double down as libraries of shell
functions. The next step is to give access to all functions as if they were
*sub-commands*:

```shell
#!/bin/sh

help() {
   printf >&2 'this is some help\n'
}

module_function() {
   printf 'module function here\n'
}

main() {
   [ $# -gt 0 ] || set -- help
   "$@"
}

! grep -- '6f8fc63c06-whatevah-db049fa26dd5953b5771e4' "$0" >/dev/null 2>&1 \
   || main "$@"
```

The `main` function is called only if the script is run directly (i.e. it is
*not* sourced), and is passed the whole argument list. It this list is
empty, it sets it to a default value (in this case, `help`); in any case, it
executes the list as a command.

This leads to the following behaviour (suppose the script is named
`modulino.sh`):

```shell
$ ./modulino.sh        # calls the default function, i.e. help
this is some help

$ ./modulino.sh help   # calls help explicitly 
this is some help

$ ./modulino.sh module_function  @ calls other function
module function here
```
Neat, uh?

[POSIX shell "modulino"]: https://gitlab.com/polettix/notechs/snippets/1868379
