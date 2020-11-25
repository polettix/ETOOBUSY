---
title: PWC088 - Array of Product
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-11-26 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#088][]. Enjoy!

# The challenge

> You are given an array of positive integers `@N`. Write a script to return
> an array `@M` where `$M[i]` is the product of all elements of `@N` except
> the index `$N[i]`.

# The questions

The only non-trivial question that comes to mind in this case is about the
dynamic of the integers we are allowed to use and whether the product of
*all* integers in the sequence is going to fit.

In lack of an answer, I'll assume that each valid item in the output list is
indeed an allowed integer value, while the product of all of them might not
be.

# The solution

The level-0 solution is pretty... sloppy to be honest. I would involve
iterating over each index in the input array, then doing another nested loop
to multiply all items *except* that at the specific index from the outer
loop:

```perl
sub array_of_product_sloppy (@N) {
   return map {
      my $p = 1;
      $p *= $_ for @N[0 .. $_ - 1, $_ + 1 .. $#N];
      $p;
   } 0 .. $#N;
}
```

Alas, this has $O(n^2)$ complexity and *we can definitely do better*.

I guess that the key insight here is somehow related to those optical
illusions where you can't decide what you're actually looking at:

![Rubin's vase](https://upload.wikimedia.org/wikipedia/commons/b/b5/Rubin2.jpg)
![Duck or rabbit?](https://upload.wikimedia.org/wikipedia/commons/4/45/Duck-Rabbit_illusion.jpg)

So let's turn to the *negative space* and observe that we might
pre-calculate the product of all elements in one single sweep, and then
divide this super-product for each element at a time (in another sweep):

```
sub array_of_product_overflowing (@N) {
   my $p = 1;
   $p *= $_ for @N;
   return map {$p / $_ } @N;
}
```

And yet... as the name hints, the `$p` we are calculating here *might* go
beyond the allowed space for integers, because it contains the product for
*all* items, which we are not actually requested to calculate.

Anyway, it's an easy twist at this point: if we know the $(i - 1)$-th
product, it's easy to calculate the $i$-th:

$$P_i = N_{i - 1} \cdot \frac{P_{i - 1}}{N_i}$$

This allows us to pass from allowed value to allowed value without having to
overflow but still with a linear sweep.

Practically speaking, we calculate the *last* element first, and leverage
the fact that an array in [Perl][] can be indexed with negative integers to
get elements from the *end* to just iterate from `0` up to the final index:

```perl
sub array_of_product (@N) {
   my $p = 1;
   $p *= $_ for @N[0 .. $#N - 1];
   return map {$p = $N[$_ - 1] * ($p / $N[$_]) } 0 .. $#N;
}
```

As anticipated, we pre-calculate the *last* element and store it in `$p`.
Afterwards, we iterate over the indexes in the input array, and apply the
formula above. The only care we have to take here is to do the division
*before* the multiplication, so that we don't risk overflowing!

Note that in the very first iteration:

- the value in `$p` is the product of all elements except the last one, i.e.
  it is $P_k$ (where $k$ is the last index in the input array);
- the value in `$_` is `0`, which means that
   - `$N[$_ - 1]` is actually `$N[-1]`, i.e. the last element in `@N`;
   - `$N[$_]` is actually `$N[0]`, i.e. the first element in `@N`

so it actually calculates $P_0$. From there on... it's much more intuitive I
hope 😅

# So we're done here...

I guess we have arrived at the end of this post, where I usually share the
whole code if you want to take a more comprehensive look and experiment a
bit:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub array_of_product (@N) {
   my $p = 1;
   $p *= $_ for @N[0 .. $#N - 1];
   return map {$p = $N[$_ - 1] * ($p / $N[$_]) } 0 .. $#N;
}

sub array_of_product_sloppy (@N) {
   return map {
      my $p = 1;
      $p *= $_ for @N[0 .. $_ - 1, $_ + 1 .. $#N];
      $p;
   } 0 .. $#N;
}

sub array_of_product_overflowing (@N) {
   my $p = 1;
   $p *= $_ for @N;
   return map {$p / $_ } @N;
}

sub print_array (@A) { local $" = ', '; say "(@A)" }

print_array(array_of_product(@ARGV ? @ARGV : (5, 2, 1, 4, 3)));
print_array(array_of_product_sloppy(@ARGV ? @ARGV : (5, 2, 1, 4, 3)));
print_array(array_of_product_overflowing(@ARGV ? @ARGV : (5, 2, 1, 4, 3)));
```

And until next time... have fun and stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#088]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-088/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-088/#TASK1
[Perl]: https://www.perl.org/
