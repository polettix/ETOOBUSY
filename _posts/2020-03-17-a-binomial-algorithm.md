---
title: A binomial algorithm
type: post
tags: [ maths, algorithm, perl ]
comment: true
date: 2020-03-17 23:57:31 +0100
published: true
mathjax: true
---

**TL;DR**

> A simple implementation of the binomial function that tries hard to avoid
> overflows.

My [cglib][] library of [Perl][] functions for [CodinGame][] sometimes has
some surprises... even for me. I was looking at this implementation of the
binomial function $n \choose k$ (read as *n choose k*):

```perl
sub binomial {
   my ($n, $k, $n_k, $r) = (@_[0, 1], $_[0] - $_[1], $_[0] - $_[0] + 1);
   ($k, $n_k) = ($n_k, $k) if $k > $n_k;
   my @den = (2 .. $k);
   while ($n > $n_k) {
      ($n, my $f) = ($n - 1, $n);
      for (@den) {
         next if $_ == 1 || (my $gcd = gcd($_, $f)) == 1;
         ($_, $f) = ($_ / $gcd, $f / $gcd);
         last if $f == 1;
      }
      $r *= $f if $f > 1;
   }
   return $r;
}
```

The rationale is this:

- start with variables for $n$ (`$n`), $k$ (`$k`), $n - k$ (`$n_k`), and the
  result (`$r`) initialized to 1
- swap `$k` and `$n_k` to make `$n_k` bigger. The binomial is symmetric and
  this swap does not change the result
- the denominator of the binomial function is $k \cdot ($n - $k)$. We can
  get rid of $n - k$ implicitly, by removing all the correspondent terms
  from the numerator too, i.e. considering only the product $n \cdot (n - 1)
  \cdot ... \cdot (n - k + 1)$, so we remain with a denominator that has $k$
  only (which is also the smaller between the original $k$ and $n - k$)
- we iterate over the factors for the numerator (`while ($n > $n_k)`) and
  update the result with a factor (`$f`). This factor is initialized with
  the number from the (truncated) factorial formula, but is simplified with
  items in the denominator (`for` loop over `@den`), so that we ensure to
  multiply only by factors that *really* belong to the final result,
  gradually removing denominator factors along the way.

This should ensure that we never overflow if the result is not overflowing
itself.

# What's with the initialization of `$r`?!?

You might have noticed that the initialization of the result variable `$r`
is something equivalent to this:

```perl
my $r = $_[0] - $_[0] + 1;
```

Why is that? Why not initialize it to `1` directly?

The answer lies a couple lines below the end of the `binomial`
implementation:

```perl
sub binomial_bi {
   require Math::BigInt;
   return binomial(Math::BigInt->new($_[0]), $_[1]);
}
```

We implemented a [Math::BigInt][] version of the function, leveraging the
same exact implementation. Here, we initialize the first argument (`$_[0]`
inside `binomial`) to a [Math::BigInt][] object, so the expression for
initializing `$r` above takes the value of 1, *but as a [Math::BigInt][]
object*, not as a simple [Perl][] integer.

> Remember: [cglib][] is optimized for code compactness, not much for
> readability 😇

And I think that's all for now!

[Numbers.pm]: https://github.com/polettix/cglib-perl/blob/master/Numbers.pm
[cglib]: https://github.com/polettix/cglib-perl/
[Perl]: https://www.perl.org/
[CodinGame]: https://www.codingame.com/
[Math::BigInt]: https://metacpan.org/pod/Math::BigInt
