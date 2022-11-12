---
title: PWC084 - Reverse Integer
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-10-28 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#084][]. Enjoy!

# The challenge

> You are given an integer `$N`. Write a script to reverse the given
> integer and print the result. Print 0 if the result doesn’t fit in
> 32-bit signed integer. The number `2,147,483,647` is the maximum
> positive value for a 32-bit signed binary integer in computing.

# The questions

I think that there can be a few questions, apart from the *obvious ones*
regarding what to do with invalid inputs.

The most important, in my opinion, is what to do if the input integer
does not *itself* fit in 32 bits. For example, what should we do when
presented with `7,463,847,412`? The reverse is *exactly* the maximum
value for an alloweable integer... is this still OK?

# The solution

I've come with a solution that *should* work, although it does a lot of
work and there are surely better ways to do it. Anyway, I call the job
done.

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub reverse_integer ($N) {
   state $max_int = 0x7fffffff;
   my ($s, $x) = $N > 0
      ? ('', scalar reverse("$N"))
      : ('-', scalar reverse(''.(-$N)));
   $x =~ s{0+\z}{}mxs;
   my ($lx, $lm) = (length($x), length($max_int));
   return $s . $x
      if ($lx < $lm)
      || ($lx == $lm) && (substr($x, 0, 1) < 2);
   return 0
      if ($lx > $lm) # too long
      || substr($x, 0, 1) > 2; # highest digit too high
   # same length, first digit is 2...
   return $s
      ? ($x <= $max_int + 1 ? $s . $x : 0)
      : ($x <= $max_int     ?      $x : 0);
}

my $x = shift || -1234;
say reverse_integer($x);
```

The solution basically divides the analysis into three macroscopic possibilities:

- the input is *short* enough (when considered as a string) to fit the
  32 bits, i.e. its length is shorter than the biggest representible
  32-bit integer. In this case, we can indeed `reverse` it;
- on the flip side, if the input is *longer*, there's no way that the
  reverse will fit, so it's a plain refusal.
- In the middle, we have a length that is the same. So, we do a little
  of additional checks to see if the number fits or not, and return a
  value accordingly.

I think it's all!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#084]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-084/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-084/#TASK1
