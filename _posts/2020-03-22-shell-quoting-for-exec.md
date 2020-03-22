---
title: Shell quoting for exec
type: post
tags: [ shell, coding ]
comment: true
date: 2020-03-22 10:19:29 +0100
published: true
---

**TL;DR**

> What I use for quoting things properly in the shell so that I can call
> `exec`.

In the previous post about [Rich’s sh (POSIX shell)
tricks][rich-pst] we disclosed a *mine* for POSIX shell "programming".


# Quoting, programmatically and properly

One interesting function is to properly *quote* stuff (*Shell-quoting
arbitrary strings*). In the author's words, here's a function that works:

```shell
quote () { printf %s\\n "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/" ; }
```

This is the second gold nugget in the page, following the hint about
properly printing with `printf` instead of `echo`. And yes, it comes second
only because printing happens more frequently 😄.

I've played a bit with the possibility that the target system might *not*
have `sed` installed. It's possible to build a function that does the same
as `quote` above, but without using `sed`; anyway, it's probably just
a style exercise, because it's so easy to bring `sed` around using
[Busybox][] (there's a statically compiled binary that does the trick, as
discussed in [Busybox - multipurpose executable][]). So... this is left as
a simple exercise for the reader 😏

# Where to use it?

Where is the `quote` function above useful? Glad you asked!

One first place is when you have to `eval` something:

```shell
$ x='hello all'
$ eval "y=$x"
/bin/sh: 1: eval: all: not found
```

The error happens because `x` is expanded and *then* the expression is
evaluated, which is the same as this:

```shell
$ eval "y=hello all"
```

i.e. calling the `all` command with environment variable `y` set to `hello`.
Whooops!

Time for `quote` to kick in:

```shell
$ quote () { printf %s\\n "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/" ; }
$ x='hello all'
$ eval "y=$(quote "$x")"
$ printf 'y is <%s>\n' "$y"
y is <hello all>
```

This is also useful when you have to call the shell and pass a whole command
with option `-c`, like this:

```shell
$ /bin/sh -c "y=$x; printf '%s\n' \"y is <$y>\""
/bin/sh: 1: all: not found
y is <>
```

which might happen more frequently than you think if you're scripting remote
execution of commands via `ssh`:

```shell
$ ssh remote-server /bin/sh -c ":; y=$x; printf '%s\n' \"y is <\$y>\""
bash: all: command not found
y is <>
```

Again, `quote` makes the day here:

```shell
$ ssh polettix.it /bin/sh -c ":; y=$(quote "$x"); printf '%s\n' \"y is <\$y>\""
y is <hello all>
```

> If you're curious about why I put an initial `:;` in the command... it's the
> only way I found to make it work. There must be some issue when running
> remote commands where the first command sets a variable, I don't know.


[rich-pst]: {{ '/2020/03/21/rich-s-posix-shell-hints/' | prepend: site.baseurl | prepend: site.url }}
[Busybox - multipurpose executable]: {{ '/2019/09/29/busybox-multipurpose-executable/' | prepend: site.baseurl | prepend: site.url }}
[Busybox]: https://busybox.net/
