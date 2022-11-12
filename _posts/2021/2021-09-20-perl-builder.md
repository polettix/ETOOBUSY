---
title: perl-builder
type: post
tags: [ perl ]
comment: true
date: 2021-09-20 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I remembered about [perl-builder][].

For reasons that I'll hopefully talk about in some future post, I was
interested into getting the latest version of [Perl][]. Then the train
of thoughts started:

> OK, I can download and compile it.
>
> Wait, there will be options to be set. I can't remember what I settled
> upon.
>
> Wait, I surely have already solved this problem. It must be some
> `perl-...` command somewhere.

Presto! I went to the command line in my VM, but nothing popped up.

> Well, it must be something I'm not using since some time, at least on
> this computer.
>
> Wait, it **should** at least be in **that** position...

Presto, again! There it was, already tracked and shared:

```
$ git remote show origin
* remote origin
  Fetch URL: ssh://polettix.it/home/poletti/git/perl/perl-builder
  Push  URL: ssh://polettix.it/home/poletti/git/perl/perl-builder
  ...
```

> OK, it must be easy to use... let's see how to use it...

```
$ ./perl-builder --usage
Can't locate Log/Log4perl/Tiny.pm in @INC ...
```

> Holy Cow! Well, there *must* be a `cpanfile` right?

```
$ ls cpan*
cpanm
```

> Holy Friggin' Cow! How lazy of me... Well, let's set this up

(after some more back-and-forth)

> Now it's the right time!

```
$ ./perl-builder --usage
Usage:
       perl-builder [--usage] [--help] [--man] [--version]

       perl-builder locator
                    [--cpanm cpanm-locator]
                    [--mirror|-m URI]
                    [--output|-o path]
                    [--path|-p path]

$ ./perl-builder 5.34.0
$ ./perl-builder -o /path/to/perl-5.34.0.builder.pl 5.34.0
[2021/09/18 18:10:43 INFO ] http://www.cpan.org/src/5.0/perl-5.34.0.tar.gz
[2021/09/18 18:10:43 INFO ] downloading http://www.cpan.org/src/5.0/perl-5.34.0.tar.gz to perl-5.34.0.tar.gz
[2021/09/18 18:10:46 INFO ] getting deployable from http://repo.or.cz/w/deployable.git/blob_plain/HEAD:/bundle/deployable
[2021/09/18 18:10:46 INFO ] success
[2021/09/18 18:10:47 INFO ] getting wrapperl from https://raw.githubusercontent.com/polettix/wrapperl/master/wrapperl
[2021/09/18 18:10:47 INFO ] success
[2021/09/18 18:10:47 INFO ] getting cpanm from http://cpanmin.us/
[2021/09/18 18:10:47 INFO ] success
[2021/09/18 18:10:47 INFO ] saving builder to /home/poletti/sviluppo/perl/perl-builder/host/perl-5.34.0.builder.pl
deployable
wrapperl
cpanm
ancillaries.txt
installer
relocate
regenerate
perl-5.34.0.tar.gz
```

> OK, let's run it...

```
$ cd /tmp/whatever
$ /path/to/perl-5.34.0.builder.pl
 INFO: calling tar xvC build -f /tmp/perl-5.34.0.builder.pl-2021-09-18_18-11-21-JYJ_bBg3pd/perl-5.34.0.tar.gz
perl-5.34.0/
perl-5.34.0/README.android
perl-5.34.0/EXTERN.h
perl-5.34.0/overload.h

...

 INFO: calling sh Configure -des -Duserelocatableinc -Dman1dir=none -Dman3dir=none -Dprefix=/tmp/whatever/perl-5.34.0
First let's make sure your kit is complete.  Checking...
Locating common programs...
Checking compatibility between /bin/echo and builtin echo (if any)...
Symbolic links are supported.

...

  /home/poletti/sviluppo/perl/perl/perl-5.34.0/lib/5.34.0/pod/perltoot.pod
./perl -Ilib -I. installman --destdir= 
Manual page installation was disabled by Configure

$ ls
perl-5.34.0

$ ./perl-5.34.0/bin/perl -v

This is perl 5, version 34, subversion 0 (v5.34.0) built for x86_64-linux

Copyright 1987-2021, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.
```

> Yay!

I hope you enjoyed the ride, stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[perl-builder]: https://github.com/polettix/perl-builder
