---
title: Installing Perl Modules
type: post
tags: [ perl, module, carton, cpanm, toolbox ]
comment: true
date: 2020-01-04 02:03:04
published: true
---

**TL;DR**

> When you need to install Perl modules locally for a project, nothing beats
> [Carton][] and [Cpanminus][cpanm].

<script id="asciicast-291607" src="https://asciinema.org/a/291607.js" data-speed="1.5" async></script>

When I need to install Perl modules, I usually do this from [CPAN][]
directly without relying on the modules shipped with [Debian][]. This allows
me fine control over versions, etc., at the cost of **not** installing those
modules in any place known to system perl.

(Sometimes I also find it useful to install my own `perl` too, but this is
for another time).

To install modules locally for a project there are two very easy ways, i.e.
[Carton][] and [Cpanminus][cpanm]. You don't have to (explicitly) use both,
and if you can go with [Carton][] alone it's probably the fastest way.

## `cpanfile`, where your needs are explicit

Both tools (can) rely on a [cpanfile][], i.e.

> A format for describing CPAN dependencies for Perl applications

This can be as easy as just list your needs in a clear way, like this:

```perl
requires 'Log::Log4perl::Tiny';
requires 'Try::Catch', '1.1.0';
```

## `carton`, quick and to the point

If you can, just stick with [Carton][] and you're a word away from having
your modules installed:

```
shell$ carton
Installing modules using /home/poletti/tmp/cpanfile
Successfully installed ExtUtils-Config-0.008
Successfully installed ExtUtils-InstallPaths-0.012
Successfully installed ExtUtils-Helpers-0.026
Successfully installed Module-Build-Tiny-0.039
Successfully installed Log-Log4perl-Tiny-1.4.0
Successfully installed Try-Catch-v1.1.0
6 distributions installed
Complete! Modules were installed into /home/poletti/tmp/local
```

This will also produce a file `cpanfile.snapshot` that you might want to put
under version control.

Installing [Carton][] can take time and effort though, this is why I find it
useful to keep an **old** standalone [carton][local-carton] script
around.

## `cpanm`, elegant and fast

If you don't want to use [Carton][] for some reason, your best fallback
choice is [cpanm][]. A way to install modules quickly is to jump tests, like
this:

```
shell$ cpanm -l local --notest --installdeps .
--> Working on .
Configuring /home/poletti/tmp ... OK
==> Found dependencies: Try::Catch, Log::Log4perl::Tiny
--> Working on Try::Catch
Fetching http://www.cpan.org/authors/id/M/MA/MAMOD/Try-Catch-1.1.0.tar.gz ... OK
...
Successfully installed Log-Log4perl-Tiny-1.4.0
<== Installed dependencies for .. Finishing.
6 distributions installed
```

Installing [cpanm][] is much easier than [Carton][], there's even a suggested
way to just get the standalone executable:

```
cd ~/bin
curl -L https://cpanmin.us/ -o cpanm
chmod +x cpanm
```

You can also find an **old** standalone [cpanm][local-cpanm] here.

## Time's up

This is all I wanted to scribble about installing Perl modules... it should
not take unnecessary time for us to do it, nor to realize how to do it!

[Carton]: https://metacpan.org/pod/Carton
[cpanm]: https://metacpan.org/pod/App-cpanminus
[CPAN]: https://metacpan.org/
[Debian]: https://debian.org/
[cpanfile]: https://metacpan.org/pod/distribution/Module-CPANfile/lib/cpanfile.pod
[local-carton]: {{ '/assets/code/carton' | prepend: site.baseurl | prepend: site.url }}
[local-cpanm]: {{ '/assets/code/cpanm' | prepend: site.baseurl | prepend: site.url }}
