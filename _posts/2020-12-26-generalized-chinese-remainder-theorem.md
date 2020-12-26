---
title: Generalized Chinese Remainder Theorem
type: post
tags: [ perl, maths, cglib ]
comment: true
date: 2020-12-26 13:20:07 +0100
mathjax: true
published: true
---

**TL;DR**

> A second take at the [Chinese Remainder Theorem][], after using the
> **strict** version in [Advent of Code 2020 - Day 13][].

That previous post introduced a small implementation of the gist of the
[Chinese Remainder Theorem][], namely:

```perl
sub crt ($n1, $r1, $n2, $r2) {
   my ($gcd, $x, $y) = egcd($n1, $n2);
   die "not coprime! <$n1> <$n2>" if $gcd != 1;
   my $N = $n1 * $n2;
   my $r = ($r2 * $x * $n1 + $r1 * $y * $n2) % $N;
   return [$N, $r];
}
```

That was good for that day's puzzle - after all, the input I was given
(well, this was valid for everyone else too) indeed had only *coprime*
values for the bus numbers, so the `die` line was actually not needed at all
(it's there to make sure of that and leaving it does not harm anyway, acting
as a sort of reminder).

But *that's not the whole story*.

And *I knew it*.

And *it came to haunt me just like the Ghost of Christmas Yet to Come*.

It's indeed possible to apply the theorem, or better a slight generalization
of it, also to cases when the *coprimeness* (is this a word? 🧐) requirement
is failed, namely (adapting from [Chinese Remainder Theorem][]):

> If $r_1 \equiv r_2 \pmod{gcd(n_1, n_2)}$ then this system of equations has a
> unique solution modulo $\frac{n_1 \cdot n_2}{gcd(n_1, n_2)}$. Otherwise,
> it has no solutions. 

Honestly, as it often happens, it both makes a lot of sense and it's not
very scaring to implement at all. So I decided to adapt the implementation
with this generalization, and also to accept a generic number of pairs of
*modulus and remainder*, resulting in this:

```perl
sub chinese_remainder_theorem {
   die "no inputs" unless scalar @_;
   die "need an even number of inputs" if scalar(@_) % 2 == 1;
   my ($N, $R) = splice @_, 0, 2;
   while (@_) {
      my ($n, $r) = splice @_, 0, 2;
      my ($gcd, $x, $y) = egcd($N, $n);
      if ($gcd != 1) {
         die "cannot combine: {x ~ $R (mod $N)} with {$x ~ $r (mod $n)}"
            unless ($R % $gcd) == ($r % $gcd);
         $_ /= $gcd for ($N, $n);
      }
      my $P = $N * $n;
      ($N, $R) = ($P, ($r * $x * $N + $R * $y * $n) % $P);
   }
   return ($N, $R);
}
```

As there are a lot of multiplications, integers can explode very fast and
yield wrong results due to representation issues. For this reason, you might
want to use the *big integers* version instead:

```perl
sub chinese_remainder_theorem_bi {
   require Math::BigInt;
   return chinese_remainder_theorem(map { Math::BigInt->new($_) } @_);
}
```

It's just a thin wrapper around the other function, making sure to feed it
with [Math::BigInt][] objects instead of plain [Perl][] integers, so that
nothing will be lost on the way.

Well, some *time* might be lost, probably. But it's for the right cause of
correctness 😅.

Both functions [ended][] [up][] in [cglib][] of course, because... why not?
There might be a puzzle in the future that can use some copy-and-paste love
🙄


[Chinese Remainder Theorem]: https://en.wikipedia.org/wiki/Chinese_remainder_theorem
[Wikipedia]: https://en.wikipedia.org/wiki/Main_Page
[Advent of Code 2020 - Day 13]: {{ '/2020/12/17/aoc-day-13/' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[Math::BigInt]: https://metacpan.org/pod/Math::BigInt
[cglib]: https://github.com/polettix/cglib-perl
[ended]: https://github.com/polettix/cglib-perl/blob/master/Numbers.pm#L34
[up]: https://github.com/polettix/cglib-perl/blob/master/Numbers.pm#L52
