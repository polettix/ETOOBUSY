---
title: A cheap trick to manipulate PERL5LIB
type: post
tags: [ perl, shell ]
comment: true
date: 2020-10-12 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Manipulating `PERL5LIB` for locally installed programs.

In time, I've become fond of *not* installing [Perl][] widely but
keeping them tight in some place where they can't interfere with others.
This led to [Installing Perl Modules][], where each project gets its
*own* rendition of modules.

Sometimes, though, I'd just like to install some [Perl][] application to
have it available in the shell. Which basically means I install it
somewhere below my home directory - like the `perl5` sub-directory that
`cpanm` defaults to.

This creates a problem, though, because it means that I have to ensure
that `PERL5LIB` is properly set to load modules from where they were
installed (`~/perl5/lib` and the like). I usually can't just set it in
the shell (like in `~/.bashrc`) because working in different projects
will probably mean I'm going to customize it shell by shell.

This usually meant that I installed a *wrapper* in `~/bin` like this:

```
#!/bin/sh
#
# ~/bin/galook - a wrapper for ~/perl5/bin/galook
#
export PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB" 
export PATH="$HOME/perl5/bin:$PATH"
exec "$HOME/perl5/bin/galook" "$@"
```

While I'm at it, I also ensure that multiple executables in that
directory can find each other.

After a few wrappers, I got obviously tired and wanted to solve the
issue *once and for all*, so I created this shell script at
`~/perl5/bin/__target__`:

```
#!/bin/sh
target="$(basename "$0")"
bindir="$(dirname "$(readlink -f "$0")")"
rootdir="$(dirname "$bindir")"
export PATH="$bindir:$PATH"
export PERL5LIB="$rootdir/lib/perl5:$PERL5LIB"
exec "$bindir/$target" "$@"
```

Then, instead of one ad-hoc wrapper `~/bin/galook` I just create it as
a symbolic link towards `__target__` above:

```
$ ls -l ~/bin/galook
lrwxrwxrwx 1 you you 23 Oct  8 00:26 /home/you/bin/galook -> ../perl5/bin/__target__
```

So... how is *this* solving my issue? Let's take a closer look:

```
1 #!/bin/sh
2 target="$(basename "$0")"
3 bindir="$(dirname "$(readlink -f "$0")")"
4 rootdir="$(dirname "$bindir")"
5 export PATH="$bindir:$PATH"
6 export PERL5LIB="$rootdir/lib/perl5:$PERL5LIB"
7 exec "$bindir/$target" "$@"
```

Remember that we will call the function with just `galook`, and it will
be resolved by the shell to be `~/bin/galook`, eventually calling the
above script in `~/perl5/bin/__target__`, i.e. a script in the same
directory as our real program `~/perl5/bin/galook`.

When the script is called, `$0` is simply `galook`. Line 2 makes sure to
get just this name, so even calling it with its "full" path
`~/bin/galook` would just yield `galook`. This is important because it's
the name of the *real* program we are after, although in a different
directory (i.e. `~/perl5/bin`).

Line 2 aims at finding the directory where the *real* program lives.
Note that there are two nested operations:

- `readlink -f "$0"` resolves the program we are calling into the real
  script position, i.e. it gives back `~/perl5/bin/__target__`;
- calling `dirname` on it gives back `~/perl5/bin`, i.e. exactly the
  directory we are after.

True, we could have just hardwired it, but it's much more general like
this 🤓

Now this is exactly what we need to manipulate `PATH` (line 5), but we
still have to do one extra step to find where the [Perl][] modules have
been installed to manipulate `PERL5LIB`.

For this reason, line 4 computes the *root* directory for our local
installations, by just getting the parent of `$bindir` (line 4). This
ends up being `~/perl5`. As modules are installed in `lib/perl5` inside
this directory, line 5 installs `$rootdir/lib/perl5` as the initial
path, so that we are fine.

Do you think I'm complicating bread? Let me know!

[Perl]: https://www.perl.org
[Installing Perl Modules]: {{ '/2020/01/04/installing-perl-modules/' | prepend: site.baseurl }}
