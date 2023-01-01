---
title: PWC170 - Primorial Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-06-22 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#170][]. Enjoy!

# The challenge

> Write a script to generate first 10 Primorial Numbers.
>
>> Primorial numbers are those formed by multiplying successive prime numbers.
>
> For example,
>
>     P(0) = 1    (1)
>     P(1) = 2    (1x2)
>     P(2) = 6    (1x2×3)
>     P(3) = 30   (1x2×3×5)
>     P(4) = 210  (1x2×3×5×7)

# The questions

I would only ask what does it mean to generate the *first 10* of the
lot. Is `P(0)` to be considered the *first one*, so that we should stop
at `P(9)`? Or is `P(1)` the real *first* primorial number, because it's
the one involving the first prime?

Well, our fine host took the effort to put `P(0)` in the example, so
I'll assume it's also the *first one*.

# The solution

I **knew** that there was some sleight of hand to do this very compactly
in [Raku][], and I found *one way*. I'm curious to read more solution in
the days to come.

Let's go step-wise. I know how to generate a (lazy) infinite list of
positive integers:

```raku
1 .. *
```

and this can be filtered for `1` or primes, keeping the laziness intact:

```raku
(1 .. *).grep({$_ == 1 || .is-prime})
```

Now, though, we have to do the products. If we were to calculate *any
single primorial*, we might first isolate the terms of interest with
some slicing:

```raku
# $n leads to the $n-th primorial P($n - 1)
(1 .. *).grep({$_ == 1 || .is-prime})[^$n]
```

Then we might apply the hyperoperator `[*]` to this slice and get our
primorial:

```raku
my $nth-primorial = [*] (1 .. *).grep({$_ == 1 || .is-prime})[^$n]
```

Alas, we have to *produce* a new sequence here...

Sorry, I meant that we have to [produce][] a new sequence here:

> \[produce\] is similar to reduce, but returns a list with the
> accumulated values instead of a single result.

So we first [produce][], *then* we slice to the amount of items that we
need:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $n where * > 0 = 10) {
   .put for (1 .. *).grep({$_ == 1 || .is-prime}).produce(&[*]).[^$n];
}
```

Let's get to [Perl][] now. There's none of this laziness craziness,
hyperstuff or so, but we have our old friends iterators and some basic
golfing capabilities to make the readers scratch their heads a bit:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use ntheory 'next_prime';

my $it = primorial_it();
say $it->() for 1 .. shift || 10;

sub primorial_it ($n = 1, $p = 1) {
   sub { (($p, $n) = ($p * $n, next_prime($n)))[0] };
}
```

In the iterator sub we use two variables (which are defined as
arguments, just to spare a line of code... sorry!), one is `$p` which
keeps the ever-growing **p**roduct, and one is `$n` which keeps track of
the **n**ext prime to use.

The fun thing is that the list assignment *first* calculates the list on
the right hand side, *then* it does the assignment. Hence, the
assignment between the two lists actually means the same as:

```
$p = $p * $n;
$n = next_prime($n);
```

and returns `($p, $n)`. As we're interested into returning `$p`, why not
return the first element of this small list?

You know, this can be golfed a bit **and** gain in readability:

```perl
sub primorial_it ($n = 1, $p = 1) {
 # sub { (($p, $n) = ($p * $n, next_prime($n)))[0] };
   sub { ($p, $n) = ($p * $n, next_prime($n)); $p };
}
```

It's now clear that we want to return `$p`, yay!

Last considerations:

- [ntheory][] just rocks, thanks [DANAJ][];
- I know the product is going to become a non-integer quite soon and I
  would need to use big integers... but we're requested to cope with the
  first 10 items, and the stock integers are fine for this.

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#170]: https://theweeklychallenge.org/blog/perl-weekly-challenge-170/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-170/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[produce]: https://docs.raku.org/routine/produce
[ntheory]: https://metacpan.org/pod/ntheory
[DANAJ]: https://metacpan.org/author/DANAJ
