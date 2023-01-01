---
title: Using ongoing developed libraries
type: post
tags: [ perl ]
comment: true
date: 2022-04-10 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some ideas to use libraries while I'm developing them.

Sometimes I happen to be working on some code and rely on some *other*
code that I've refactored into a separate library in a separate tree
(usually, a separate [Git][] repository too). Very often, this separate
library is something that is not on [CPAN][] and might possibly never
end up there.

One alternative is to produce a package and put it in a DarkPAN kind of
thing, so that I use the toolchain just as I would do with regular
libraries. This might get in the way of developing code, though,
especially in a *lone-coder* scenario where I don't really need too much
cerimony because, well, I'm the only coder. Why? It's clunky to generate
a new package and install it for each change.

One alternative I came up with is to have a clone of the [Git][]
repository under the `local` sub-directory, where also the *local*
modules are installed by [Carton][] (remember [Installing Perl
Modules][]? They end up in `local/lib/perl5`). So I might end up with
something along the lines:

```
myproject
  bin
    the-program
  lib
  local
    lib
      perl5
        ... modules installed with Carton...
    some-library
      lib
    some-other-library
      lib
```

Now it's just a matter of invoking `local-lib` ([Another trick for
PERL5LIB][]) with the right targets:

```shell
$ local-lib lib local/some-library/lib local/some-other-library/lib
```

or, of course, setting it in a wrapper shell script, should I need it.

I know, this is super-clunky too.

I took a look in [CPAN][] and there seem to be some attempts at solving
a similar problem, although not the same. So I'm meditating on a small
`lib::` module (like `lib::src` or something like this) to allow
automating the inclusion of this kind of *ongoing development* stuff
easily.

The idea would be to reshape the directory structure, like this:

```
myproject
  bin
    the-program
  lib
  local
    lib
      perl5
        ... modules installed with Carton...
    src
      some-library
        lib
      some-other-library
        lib
```

i.e. move these *sourcey* libraries/[Git][] clones in a specific
sub-directory, and then include all stuff there like this in
`bin/the-program`:

```perl
use FindBin '$Bin';
use lib::src "$Bin/../local/src";
```

This in turn should look inside `local/src` for all sub-directories that
have a `lib` and add them to `@INC`. Or, even, look for *their*
`local/lib/perl5` sub-directories too...

Let's see!

[Perl]: https://www.perl.org/
[Git]: https://www.git-scm.com/
[CPAN]: https://metacpan.org/
[Installing Perl Modules]: {{ '/2020/01/04/installing-perl-modules/' | prepend: site.baseurl }}
[Carton]: https://metacpan.org/pod/Carton
[Another trick for PERL5LIB]: {{ '/2021/04/17/local-lib/' | prepend: site.baseurl }}
