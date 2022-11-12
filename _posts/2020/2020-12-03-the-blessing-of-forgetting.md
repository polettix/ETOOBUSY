---
title: The blessing of forgetting
type: post
tags: [ perl, coding, algorithm ]
comment: true
date: 2020-12-03 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Where I rediscover an old piece of code and remember something about
> [Fibonacci numbers][wikifib].

**Updates**: thanks to [Andrew Solomon][] for pointing out that functions
`fib1` should actually ercurse to `fib1` itself, not to `fib`. Thanks!

# Fibonacci numbers?

If you don't know what a *Fibonacci number* is, the [Wikipedia page on
them][wikifib] can be a good starting point. We will adopt the same
convention as that page, i.e.:

$$
F_0 = 0 \\
F_1 = 1 \\
F_n = F_{n - 2} + F_{n - 1} \quad (n > 1)
$$

Fibonacci numbers are often used to explain some concepts in programming. I
guess this comes from the fact that the generic formula is *recursive* (note
the third line above, each item is defined in terms of the two previous
ones), so it can be a good example for a recursive implementation.

# Those who forget history are condemned to recode it

Let's look at a naïve implementation in [Perl][]:

```perl
sub fib1 ($n) {
    return $n if $n < 2;
    return fib1($n - 2) + fib1($n - 1);
}
```

This is pretty much a *direct translation* of the definition, so how come it
is marked as *naïve*? Well... from a computational point of view, we're
calculating some of the items *too many times*. As an example, let's look at
what happens when we calculate $F_4$:

```
  F(4) --+-- F(3) --+-- F(2) --+-- F(1)
         |          |          |
         |          |          +-- F(0)
         |          |          
         |          +-- F(1)
         |
         +-- F(2) --+-- F(1)
                    |
                    +-- F(0)
```

We're calling the function a lot of times, and calculating the same values
over and over (e.g. $F_2$ is calculated twice).

# So let's remember

This is something that *memoization* can usually address pretty effectively,
and [Perl][] has a *core* module to do this, [Memoize][]:

```perl
use Memoize;
memoize('fib1');
sub fib1 ($n) {
    return $n if $n < 2;
    return fib1($n - 2) + fib1($n - 1);
}
```

This dramatically reduces the number of calls, because it will reuse results
as they are alredy available:

```
  F(4) --+-- F(3) --+-- F(2) --+-- F(1)
         |          |          |
         |          |          +-- F(0)
         |          |          
         |          +-- F(1)[cached]
         |
         +-- F(2)[cached]
```

This still requires calculating all values from $F_0$ up to $F_n$ though, so
an iterative solution is probably even more readable at this point:

```perl
sub fib2 ($n) {
    my ($prev, $succ) = (0, 1);
    ($prev, $succ) = ($succ, $prev + $succ) while $n-- > 0;
    return $prev;
}
```

At each iteration, the successor is calculated as the currently available
two values, and the curren value becomes the previous one. Maybe a tad
*idiomatic* but I'd say it's pretty readable even if you're not much into
[Perl][].

# Where's the blessing then?

Looking inside [cglib][], I noticed a module [Fibonacci.pm][]. OK, I
thought, I wonder *why* I wasted my time on this sim**HOLY COW!**.

There's a `fibonacci_multiply` sub. There's a `fibonacci_power` sub. They
are *used* to calculate the actual value for Fibonacci numbers by sub
`fibonacci_nth`.

And then it hit me: Fibonacci numbers can be calculated with a suitable
power of a basic matrix, as the [Wikipedia page][wikifib] itself points
out:

$$
\left( \begin{matrix}
1 & 1 \\
1 & 0
\end{matrix} \right)^n = \left( \begin{matrix}
F_{n + 1} & F_n \\
F_n       & F_{n - 1}
\end{matrix} \right)
$$

So there you have it, I was blessed of forgetting about this cool fact...
because I could *discover it again*!

So how does this help, you might ask?

Let's consider how we can calculate the $n$-th power of an integer $i$. We
might just apply the definition:

$$ i^n = i \cdot i \cdot ... \cdot i $$

i.e. multiply $i$ by itself $n$ times, or (for example) observe that we
can express $n$ in some fancy way and do some exponent manipulation. As an
example, let's consider $n = 8$; in this case:

$$ i^8 = (i^4)^2 = ((i^2)^2)^2 $$

which means that we can do much less than 7 multiplications:

$$
i^2 = i \cdot i \\
i^4 = i^2 \cdot i^2 \\
i^8 = i^4 \cdot i^4
$$

The same trick can be applied to the multiplications of the matrix for
Fibonacci numbers, which leads to the code in [Fibonacci.pm][]:

```perl
sub fibonacci_multiply {
   my ($x, $y) = @_;
   @$x = (
      $x->[0] * $y->[0] + $x->[1] * $y->[2],
      $x->[0] * $y->[1] + $x->[1] * $y->[3],
      $x->[2] * $y->[0] + $x->[3] * $y->[2],
      $x->[2] * $y->[1] + $x->[3] * $y->[3],
   );
} ## end sub _multiply

sub fibonacci_power {
   my ($q, $n, $q0) = (@_[0, 1], $_[2] || [@{$_[0]}]);
   return $q if $n < 2;
   fibonacci_power($q, int($n / 2), $q0);
   fibonacci_multiply($q, $q);
   fibonacci_multiply($q, $q0) if $n % 2;
   return $q;
} ## end sub _power
```

Here the matrix is represented by an array of four elements; this is OK in
this case because the matrix is so little that we can code the
multiplication explicitly in `fibonacci_multiply`.

The power function `fibonacci_power` applies our insight by recursing into
the power calculation by always dividing the exponent by $2$, taking care to
"account for the rest" in case $n$ is not a power of $2$. Annoying details,
I know.

# There's more [Perl][] to it

The module was a real (re)discovery anyway. Most probably I needed to
calculate *very big* Fibonacci numbers, so bit that they did not fit in
[Perl][]'s basic integer type.

Easy to address: use [Math::BigInt][].

Well... not so fast. Using it means gaining *a lot* in terms of how big our
integers can be, but losing in speed. I don't want big numbers if I don't
need big numbers! Hence, there are *two* functions to calculate the $n$-th
Fibonacci number: `fibonacci_nth`, for everyday needs, and
`fibonacci_nth_bi`, for heavy duty needs. The latter is simple:

```perl
sub fibonacci_nth_bi {
   require Math::BigInt;
   return fibonacci_nth($_[0], Math::BigInt->new(1));
}
```

It calls the *everyday* one but provides... a specific definition for what
we should consider for number $1$, i.e. what [Math::BigInt][] considers for
a $1$.

This also makes it clear why the argument unpacking in `fibonacci_nth` seems
so overly complicated:

```perl
sub fibonacci_nth {
   my ($n, $one, $zero) = ($_[0], $_[1] || 1, ($_[1] || 1) - ($_[1] || 1));
   return
       $n < 1 ? $zero
     : $n < 3 ? $one
     :          fibonacci_power([$one, $one, $one, $zero], $n - 1)->[0];
} ## end sub nth
```

At first glance, you might think that I've gone mad by defining a value for
`$one` and `$zero`, but now it's clear! If I get passed what $1$ is, I'll
use it (via `$one`) and also define what $0$ is through it (this is easy:
just subtract whatever we consider for $1$ from itself).

So, from now on we're working only with [Math::BigInt][] objects... and
everything goes to its place!

# Conclusions

I *know* I merely scratched the surface. There is *so much* about it, just
look for it!

[wikifib]: https://en.wikipedia.org/wiki/Fibonacci_number
[Perl]: https://www.perl.org/
[Memoize]: https://metacpan.org/pod/Memoize
[Math::BigInt]: https://metacpan.org/pod/Math::BigInt
[cglib]: https://github.com/polettix/cglib-perl
[Fibonacci.pm]: https://github.com/polettix/cglib-perl/blob/master/Fibonacci.pm
[Andrew Solomon]: https://disqus.com/by/geekuni/
