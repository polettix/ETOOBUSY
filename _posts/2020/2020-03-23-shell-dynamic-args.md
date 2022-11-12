---
title: Building shell arguments list dynamically
type: post
tags: [ shell, coding ]
series: Shell Tricks
comment: true
date: 2020-03-23 19:01:03 +0100
published: true
---

**TL;DR**

> My take on building a dynamic list of argument in the shell

Sometimes my shell script have to call an external command with a list of
arguments that is built dynamically.

For example, consider a trivial wrapper around `grep`, where I can set flag
`-i` for ignoring case through an environment variable
`WRAPGREP_IGNORE_CASE`:

```shell
wrapgrep() {
   local minus_i=''
   [ "$WRAPGREP_IGNORE_CASE" = "1" ] && minus_i='-i'
   grep $minus_i "$@"
}
```

In this case, I *do not* put double quotes around `$minus_i` when calling
`grep`, because if `minus_i` happens to be empty, then I would be passing
one empty parameter to `grep` instead of... nothing. Ouch.

Which brings us to the following section...

# Spaces in the argument?

What if the optional argument needs spaces? As an example, let's consider
wrapping [ffmpeg][] to *optionally* add metadata for the *title*:

```shell
wrong_ffmpeg_wrapper_for_title() { # name says it all...
   local meta=''
   [ -n "$TITLE" ] && meta="-metadata title=$TITLE"
   ffmpeg $meta "$@"
}
```

For sake of examples, in the following we will consider the following
function instead:

```shell
print_args_list() {
   printf 'called with the following arguments\n'
   local i=0
   while [ $# -gt 0 ] ; do
      i="$((i + 1))"
      printf '%2d <%s>\n' "$i" "$1"
      shift
   done
}
ffmpeg() { print_args_list "$@" ; }
```

Let's see `wrong_ffmpeg_wrapper_for_title` in action:

```shell
$ wrong_ffmpeg_wrapper_for_title blah blah blah
called with the following arguments
 1 <blah>
 2 <blah>
 3 <blah>

$ TITLE='whatever you do' wrong_ffmpeg_wrapper_for_title blah blah blah
called with the following arguments
 1 <-metadata>
 2 <title=whatever>
 3 <you>
 4 <do>
 5 <blah>
 6 <blah>
 7 <blah>
```

Ouch! Spaces really didn't help us here, because the whole `title=...`
argument (which is expected to be *one single* argument) has been split into
three. And no, putting quotes around `$TITLE` would not help here.

# Quoting maybe?

We might try to use [Shell quoting for exec][] maybe? Let's see:

```shell
quote () { printf %s\\n "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/" ; }
wrong2_ffmpeg_wrapper_for_title() { # hint: not going to work
   local meta=''
   [ -n "$TITLE" ] && meta="-metadata $(quote "title=$TITLE")"
   ffmpeg $meta "$@"
}
```

Let's give it a try:

```
$ TITLE='whatever you do' wrong2_ffmpeg_wrapper_for_title blah blah blah
called with the following arguments
 1 <-metadata>
 2 <'title=whatever>
 3 <you>
 4 <do'>
 5 <blah>
 6 <blah>
 7 <blah>
```

Still no luck: spaces are kept in the quoted string, and those single quotes
are just considered part of the text, not interpreted. We have to make sure
to properly manipulate the argument list *as an array of distinct elements*.

Wait...

# Let's go to the gold mine

Remember [Rich’s sh (POSIX shell) tricks][rich-pst]? It provides hints to
manage multiple *arrays* even when the POSIX shell only supports one (the
argument list). Here's the trick to *freeze* an argument list into a single
string:

```shell
# adapted from Rich's sh (POSIX shell) tricks - function "save"
# http://www.etalabs.net/sh_tricks.html
# https://web.archive.org/web/20200301180645/http://www.etalabs.net/sh_tricks.html
freeze_array() {
   local i
   for i do
      printf '%s\n' "$i" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/' \\\\/"
   done
   printf ' '
}
```

The code leverages the same idea as `quote`, only making sure to separate
items on different lines and stitching them together with a backslash. Let's
see it at work:

```shell
$ TITLE='whatever you do'
$ my_array="$(freeze_array -metadata "title=$TITLE")"
$ printf 'my_array is <%s>\n' "$my_array"
my_array is <'-metadata' \
'title=whatever you do' \
 >
```

Note that the last backslash stiches a single space in the last line, which
is fine.

How to *thaw* the frozen array? We cannot use a function for this, because
the only array we can manipulate is the argument list in the *current*
function, so calling another function... would set its argument list,
instead that of the function were are in. The trick is pretty easy, though:

```
# show that the current argument list is empty:
$ print_args_list "$@"
called with the following arguments

# THIS IS THE THAWING OPERATION!!!
$ eval "set -- $my_array"

# now the argument list is not empty any more!
$ print_args_list "$@"
called with the following arguments
 1 <-metadata>
 2 <title=whatever you do>
```

If you're wondering... *yes*, this is exactly what we needed. And also
*yes*, you can concatenate such strings to merge two arrays together!

# So the trick is...

We can now code our proper wrapper function for environment variable
`TITLE`:

```shell
freeze_array() {
   local i
   for i do
      printf '%s\n' "$i" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/' \\\\/"
   done
   printf ' '
}
ffmpeg_wrapper_for_title() {
   if [ -n "$TITLE" ] ; then
      local args="$(freeze_array -metadata "title=$TITLE" "$@")"
      eval "set -- $args"
   fi
   ffmpeg "$@"
}
```

When `TITLE` is not empty, the whole argument list is manipulated to add the
two new args, otherwise the original argument list is kept.

Example run:

```shell
$ TITLE='whatever you do' ffmpeg_wrapper_for_title blah blah blah
called with the following arguments
 1 <-metadata>
 2 <title=whatever you do>
 3 <blah>
 4 <blah>
 5 <blah>
```

And now we're happy 😎

[ffmpeg]: https://ffmpeg.org/
[Shell quoting for exec]: {{ '/2020/03/22/shell-quoting-for-exec/' | prepend: site.baseurl | prepend: site.url }}
[rich-pst]: {{ '/2020/03/21/rich-s-posix-shell-hints/' | prepend: site.baseurl | prepend: site.url }}
