---
title: PWC149 - Fibonacci Digit Sum
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-01-26 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#149][]. Enjoy!

# The challenge

> Given an input `$N`, generate the first `$N` numbers for which the sum
> of their digits is a Fibonacci number.
>
> **Example**
>
>     f(20)=[0, 1, 2, 3, 5, 8, 10, 11, 12, 14, 17, 20, 21, 23, 26, 30, 32, 35, 41, 44]

# The questions

Well... this is nitpicking, I'll read "numbers" as "positive integers".

# The solution

We'll start with [Raku][]:

{% raw %}
```raku
#!/usr/bin/env raku
use v6;

class FibonacciSumming { ... }

sub MAIN ($N = 20) {
   my $fs = FibonacciSumming.new;
   $fs.next.put for ^$N;
}

class FibonacciSumming {
   has %!fibo = 0 => 1;
   has $!f =  0;
   has $!s = -1;
   method next () {
      while True {
         ++$!s;
         my $sum = $!s.comb(/\d/).sum;
         ($!f, %!fibo{%!fibo{$!f}}) = %!fibo{$!f}, $!f + %!fibo{$!f}
            while $!f < $sum;
         return $!s if %!fibo{$sum}:exists;
      }
   }
}
```
{% endraw %}

We use an object to keep track of generating the outputs. There are
three member variables:

- `%!fibo` keeps track of the "following" number of Fibonacci numbers. I
  know that `1` has two successors, but it's still working to indicate
  what is a Fibonacci number and what is not;
- `$!f` is the companion to the hash above, keeping track of the latest
  key put in `%!fibo`, so that we can generate more;
- `$!s` is a candidate result.

The main method `next` iterates until a suitable value is found in
`$!s`. The `$sum` is calculated according to the rules, then it is
checked against the Fibonacci numbers. The inner loop makes sure that
there are enough Fibonacci numbers to check for presence of `$sum`

The [Perl][] version is *a sort* of translation, only we're opting for
an iterator function here instead of a full-fledged object:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use List::Util 'sum';

my $it = fibonacci_summing();
say $it->() for 1 .. (shift || 20);

sub fibonacci_summing {
   my %fibo = (0 => 1);
   my $f = 0;
   my $s = -1;
   return sub {
      while ('necessary') {
         ++$s;
         my $sum = sum split m{}mxs, $s;
         ($f, $fibo{$fibo{$f}}) = ($fibo{$f}, $f + $fibo{$f})
            while $f < $sum;
         return $s if exists $fibo{$sum};
      }
   };
}
```

The returned `sub` closes over `%fibo`, `$f`, and `$s`, which have the
same exact role as in the [Raku][] version.

I guess this is all... until next time stay safe folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#149]: https://theweeklychallenge.org/blog/perl-weekly-challenge-149/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-149/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
