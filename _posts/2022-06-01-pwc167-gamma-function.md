---
title: PWC167 - Gamma Function
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-06-01 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#167][].
> Enjoy!

# The challenge

> Implement subroutine `gamma()` using the [Lanczos approximation][]
> method.
>
> **Example**
>
>     print gamma(3); # 1.99
>     print gamma(5); # 24
>     print gamma(7); # 719.99

# The questions

This is a quite specific request! I wonder whether we have to reproduce
the results or if something a bit more precise is good...

# The solution

The [wikipedia page][Lanczos approximation] is clear:

> The Lanczos approximation was popularized by [Numerical Recipes][]

Indeed, chapter 6 of [the book][] has an implementation of the
*logarithm* of the gamma function in the C language, which is extremely
easy to translate into [Perl][]. So here we go:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say "$_ -> @{[ gamma($_) ]}" for @ARGV;

sub gamma ($x) { exp(gammaln($x)) }

sub gammaln ($x) {
   die "bad argument in gammaln\n" if $x <= 0;

   state $cof = [
      57.1562356658629235,     -59.5979603554754912,
      14.1360979747417471,     -0.491913816097620199,
      .339946499848118887e-4,  .465236289270485756e-4,
      -.983744753048795646e-4, .158088703224912494e-3,
      -.210264441724104883e-3, .217439618115212643e-3,
      -.164318106536763890e-3, .844182239838527433e-4,
      -.261908384015814087e-4, .368991826595316234e-5
   ];

   my $y   = $x;
   my $tmp = $x + 5.24218750000000000;
   $tmp = ($x + 0.5) * log($tmp) - $tmp;
   my $ser = 0.999999999999997092;

   $ser += $_ / ++$y for $cof->@*;

   return $tmp + log(2.5066282746310005 * $ser / $x);
} ## end sub gammaln ($x)
```

The [Raku][] translation is straightforward:

```raku
#!/usr/bin/env raku
use v6;

sub MAIN (*@args) {
   put "$_ -> {gamma($_)}" for @args;
}

sub gamma ($x) { exp(gammaln($x)) }

sub gammaln (Numeric:D $x where * > 0) {
   state @cof =
      57.1562356658629235,     -59.5979603554754912,
      14.1360979747417471,     -0.491913816097620199,
      .339946499848118887e-4,  .465236289270485756e-4,
      -.983744753048795646e-4, .158088703224912494e-3,
      -.210264441724104883e-3, .217439618115212643e-3,
      -.164318106536763890e-3, .844182239838527433e-4,
      -.261908384015814087e-4, .368991826595316234e-5;

   my $tmp = $x + 5.24218750000000000;
   $tmp = ($x + 0.5) * log($tmp) - $tmp;

   my $y   = $x;
   my $ser = 0.999999999999997092;
   $ser += $_ / ++$y for |@cof;

   return $tmp + log(2.5066282746310005 * $ser / $x);
} ## end sub gammaln ($x)
```

It's interesting that the outputs are a little different, I guess that
this is because they treat precision in a different way:

```
$ perl perl/ch-2.pl 3 5 7
3 -> 2
5 -> 24
7 -> 720

$ raku raku/ch-2.raku 3 5 7
3 -> 2.0000000000000018
5 -> 24.000000000000014
7 -> 720.0000000000008
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#167]: https://theweeklychallenge.org/blog/perl-weekly-challenge-167/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-167/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Lanczos approximation]: https://en.wikipedia.org/wiki/Lanczos_approximation
[Numerical Recipes]: http://www.numerical.recipes/
[the book]: http://numerical.recipes/book/book.html
