---
title: Tricked by __PACKAGE__
type: post
tags: [ perl ]
comment: true
date: 2022-03-21 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> `__PACKAGE__` cannot be treated like a sub before `perl` version 5.16.

I recently worked on a [Log::Log4perl::Tiny update][] and I stumbled
into this:

```perl
$Carp::Internal{$_} = 1 for __PACKAGE__;
```

I'm not entirely sure *why* I was doing this exactly, but at least it
was already clear to me that I had to do *something*.

Even when using `strict`, [Perl][] lets us put barewords as hash keys,
because that's too handy to give up. This leads to a problem with the
special literal `__PACKAGE__` (or other literals like `__LINE__` and
`__FILE__`), because it's composed of "wordy characters" only (yes, the
underscore is considered a "wordy character", think `\w` in regular
expressions) and as such it is considered to be a bareword to be
stringified when used as a hash key:

```perl
$hash{__PACKAGE__} = 42;
# SAME as:
$hash{'__PACKAGE__'} = 42;
```

The trick in this case is to *break* the shortcut for stringification
and force `perl` to evaluate the symbol as *something*. This can e.g. be
done by using a scalar variable, because the `$` will prevent the
stringification:

```perl
my $package = __PACKAGE__;
$hash{$package} = 42;
```

I probably had this in mind at the time, but didn't like to conjure up
*another* variable, for some cleanness ideal that unfortunately is
probably a bad flavor of hubris (i.e. the "being clever" which amounts
to being stupid and unclear).

Whatever, I resolved to change this in the code and also to limit the
modification to [Carp][], by tossing a `local` in. So I put this
instead:

```
local $Carp::Internal{__PACKAGE__()} = 1;
```

My *assumption* was that `__PACKAGE__` could be treated much like
something declared with `use constant`, and as it seems this is indeed
the case in more *recent* `perl`s. This, or I can't make sense of the
matrix at [CPANTesters][]:

![Matrix at CPANTesters]({{ '/assets/images/llt-1.4.1-testers.png' | prepend: site.baseurl }})

Anyway, the matrix was still incomplete - expecially before 5.16, which
tickled my curiosity because the module is from about 12 years ago and
it is supposed to work with version 5.8 too.

Fast forward a few hours and I receive [this report][] and other similar
ones, all related to `perl` releases *before* 5.16. The interesting part
is this:

```
syntax error at [...]/Tiny.pm line 369, near "__PACKAGE__("
```

Ouch. Was this expected? Totally, as [perl5160delta.pod][] points out:

> The `__FILE__`, `__LINE__` and `__PACKAGE__` tokens can now be written
> with an empty pair of parentheses after them. This makes them parse
> the same way as time, fork and other built-in functions.

So OK, 5.16 was out a *long* time ago, but this is easy to adjust and
keep the backwards compatibility:

```
local $Carp::Internal{'' . __PACKAGE__} = 1;
```

Result: a [new trial release in CPAN][rel], and crossed fingers!


[Perl]: https://www.perl.org/
[Log::Log4perl::Tiny update]: {{ '/2022/03/20/log-log4perl-tiny-update/' | prepend: site.baseurl }}
[Carp]: https://metacpan.org/pod/Carp
[CPANTesters]: http://matrix.cpantesters.org/?dist=Log-Log4perl-Tiny+1.4.1-TRIAL
[this report]: http://www.cpantesters.org/cpan/report/25bc66ac-a7ca-11ec-be6c-4b881f24ea8f
[perl5160delta.pod]: https://metacpan.org/dist/perl/view/pod/perl5160delta.pod#__FILE__()-Syntax
[rel]: https://metacpan.org/release/POLETTIX/Log-Log4perl-Tiny-1.5.0-TRIAL
