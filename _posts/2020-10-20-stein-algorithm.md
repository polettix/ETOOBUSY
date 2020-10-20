---
title: Stein's algorithm for GCD
type: post
tags: [ perl, algorithm, maths ]
comment: true
date: 2020-10-20 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> I [read][abigail-post] about [Stein's algorithm][] for calculating the
> greatest common divisor between two integers. Interesting.

So it seems that finding the greatest common divisor is a hot topic in
this blog, considering that I already wrote about it in [The extended
Euclid's algorithm][]. Go figure.

The algorithm is rooted in a few equivalences, which are fine. The most
challenging might be considered the last one, i.e.:

> $g = gcd(u, v) = gcd(\|u − v\|, min(u, v))$ if $u$ and $v$ are both odd.

When you think about it, anyway, it's pretty obvious: an integer $g$
that divides both $u$ and $v$ must also divide their difference and its
absolute value. The contrary also applies, which accounts for reading
the equivalence in the reverse direction.

Here's a possible iterative implementation (you know I'm fond of them):

```perl
sub stein ($u, $v) {
   die 'the greatest common divisor for (0, 0) is undefined)'
      unless $u || $v;

   # cope with edge cases, insist on using positive integers only
   $u = -$u if $u < 0;
   return $u unless $v;
   $v = -$v if $v < 0;
   return $v unless $u;

   # we have to go into the rabbit hole here...
   my $retval = 1;

   # first phase, find out the contributing power of 2, if any
   while (($u % 2 == 0) && ($v % 2 == 0)) {
      $retval <<= 1;
      $v >>= 1;
      $u >>= 1;
   }

   # second phase, from now on either u and v will be odd
   while ('necessary') {
      $v >>= 1 while $v % 2 == 0; # we don't need evens here
      $u >>= 1 while $u % 2 == 0; # ditto
      return $retval * $u if $v == $u;
      ($u, $v) = $u < $v ? ($v - $u, $u) : ($u - $v, $v);
   }
}
```

Aside question: why $u$ and $v$ instead of $n$ and $m$? I guess it was a
personal preference of Stein...

[abigail-post]: https://programmingblog910557004.wordpress.com/2020/10/14/perl-weekly-challenge-082-part-1/
[Stein's algorithm]: https://github.polettix.it/ETOOBUSY/2020/10/18/pwc082-interleave-string-again/
[The extended Euclid's algorithm]: {{ '/2020/01/08/extended-euclid' | prepend: site.baseurl }}
