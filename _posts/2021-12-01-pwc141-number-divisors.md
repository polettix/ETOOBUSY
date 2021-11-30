---
title: PWC141 - Number Divisors
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-12-01 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#141][]. Enjoy!

# The challenge

> Write a script to find lowest 10 positive integers having exactly 8
> divisors.
>
> **Example**
>
>     24 is the first such number having exactly 8 divisors.
>     1, 2, 3, 4, 6, 8, 12 and 24.

# The questions

I can't think of any.


# The solution

Oh, the joys of has *so much* space for being *maximally overkill*!!!

There's a slightly boring demonstration why positive integers having
*exactly* 8 divisors MUST be only in exactly one of three possible
forms:

$$
p_1^7 \\
p_1^3 p_2 \\
p_1 p_2 p_3
$$

The first form is the easier to generate: just take primes in increasing
value, and get their 7th power.

The second and third forms are trickier to generate in ascending order.
As an example... $2^3 7$ and $2 3^3$ are quite close to one another, so
we have to be careful to generate them in order. But hey! We can always
borrow the `BasicPriorityQueue` from the last week's challenge, and feed
it with multiple candidates, so that we can extract the best, right?

For the second case, we will keep two parallel tracks, one for
generating values where $ p\_1 < p\_2 $, the other one - you guess? - for
$ p\_1 > p\_2 $. Then, we will always proceed like this when we "use" the
best value from the lot:

- always produce one "next" item with the higher number increasing to
  the following prime;
- also produce another item with the lower number increasing to the
  following prime if this the previous prime of the higher one.

In practice:

- if we start from $(2, 3)$ we just generate $(2, 5)$
- from $(2, 5)$ we generate $(2, 7)$ *and* $(3, 5)$ (because 3 comes
  after 2, and is immediately before 5 as a prime)
- from $(2, 7)$ we generate just $(2, 11)$

You can easily convince yourself that this is a good way to go.

Something similar can be done with the third form too. This time,
though, it's easier to always try to increase any of the three numbers,
filtering out the cases where values might get on each other's way. In
practice, our candidates from $(A, B, C)$ will be the following three:

$$
(A, B, succ(C)) \\
succ(B) < C \Rightarrow (A, succ(B), C) \\
succ(A) < B \Rightarrow (succ(A), B, C)
$$

Again, a `BasicPriorityQueeu` will help us figure out the best candidate
as we move on.

Last, we consider these three sources of positive integers, and get the
best (i.e. lower one) at each round, "advancing" only the source where
we take the item from.

So... [Raku][] time!

```raku
#!/usr/bin/env raku
use v6;

sub next-prime-after ($p) { # $p is prime
   state %nxt = 2 => 3, 3 => 5, 5 => 7, 7 => 11;
   state $max= 7;
   while ($p > $max) {
      $max= %nxt{$max};
      %nxt{$max} = $max+ 2;
      %nxt{$max} += 2 until %nxt{$max}.is-prime;
   }
   return %nxt{$p};
}

class BasicPriorityQueue {
   has @!items;
   has &!before;

   submethod BUILD (:&!before = {$^a < $^b}, :@items) {
      @!items = '-';
      self.enqueue($_) for @items;
   }

   #method dequeue ($obj) <-- see below
   method elems { @!items.end }
   # method enqueue ($obj) <-- see below
   method is-empty { @!items.elems == 1 }
   method size  { @!items.end }
   method top { @!items.end ?? @!items[1] !! Any }

   method dequeue () { # includes "sink"
      return unless @!items.end;
      my $r = @!items.pop;
      ($r, @!items[1]) = (@!items[1], $r) if @!items.end >= 1;
      my $k = 1;
      while (my $j = $k * 2) <= @!items.end {
         ++$j if $j < @!items.end && &!before(@!items[$j + 1], @!items[$j]);
         last if &!before(@!items[$k], @!items[$j]);
         (@!items[$j, $k], $k) = (|@!items[$k, $j], $j);
      }
      return $r;
   }

   method enqueue ($obj) { # includes "swim"
      @!items.push: $obj;
      my $k = @!items.end;
      (@!items[$k/2, $k], $k) = (|@!items[$k, $k/2], ($k/2).Int)
         while $k > 1 && &!before(@!items[$k], @!items[$k/2]);
      return self;
   }
}

class A7 {
   has Int $!A = 2;
   method current () { $!A ** 7 }
   method move-on () { $!A = next-prime-after($!A) }
}

class A3B1 {
   has $!queue = BasicPriorityQueue.new(
      before => {$^a[2] < $^b[2]},
      items  => [[2, 3, 24, 0], [2, 3, 54, 1], ],
   );
   method current () { return $!queue.top[2] }
   method move-on () {
      my ($A, $B, $value, $twist) = $!queue.dequeue.Slip;
      my $next-B = next-prime-after($B);
      my @new = [$A, $next-B],; # this always appears
      my $next-A = next-prime-after($A);
      @new.push: [$next-A, $B]
         if $next-A < $B && next-prime-after($next-A) == $B; # fork!
      for @new -> $item {
         ($A, $B) = $item.Slip;
         $item.push: $twist ?? ($A * $B ** 3) !! ($A ** 3 * $B);
         $item.push: $twist;
         $!queue.enqueue($item);
      }
   }
}

class A1B1C1 {
   has $!queue = BasicPriorityQueue.new(
      before => {$^a[3] < $^b[3]},
      items  => [[2, 3, 5, 30], ]
   );
   method current() { return $!queue.top[3] }
   method move-on() {
      my ($A, $B, $C, $value) = $!queue.dequeue.Slip;
      my ($n-A, $n-B, $n-C) = ($A, $B, $C).map: {next-prime-after($^a)};
      my @new = [$A, $B, $n-C], ;
      @new.push: [$A, $n-B, $C] if $n-B < $C;
      @new.push: [$n-A, $B, $C] if $n-A < $B;
      for @new -> $item {
         ($A, $B, $C) = $item.Slip;
         $item.push: $A * $B * $C;
         $!queue.enqueue($item);
      }
   }
}

class EnumerateEighters {
   has $!a7     = A7.new();
   has $!a3b1   = A3B1.new();
   has $!a1b1c1 = A1B1C1.new();
   method get() {
      my $A = $!a7.current;
      my $B = $!a3b1.current;
      my $C = $!a1b1c1.current;
      my $retval = ($A, $B, $C).min;
      if ($retval == $A) { $!a7.move-on }
      elsif ($retval == $B) { $!a3b1.move-on }
      else { $!a1b1c1.move-on }
      return $retval;
   }
}

sub MAIN (Int $n = 10) {
   my $x = EnumerateEighters.new;
   $x.get.put for 1 .. $n;
}
```

This was *fun*, but it took me a lot and I wasn't even *too* sure it was
working. So, for the [Perl][] implementation, I opted for the easy route
of going *brute force*:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub count_divisors ($n) {
   my $c = 2; # 1, $n
   for my $d (2 .. $n / 2) {
      ++$c unless $n % $d;
   }
   return $c;
}

sub number_divisors ($n) {
   my $i = 1;
   my @retval;
   while ($n > 0) {
      if (count_divisors($i) == 8) {
         push @retval, $i;
         --$n;
      }
      ++$i;
   }
   return @retval;
}

say for number_divisors(shift // 10);
```

It sticks to the definition: we iterate over integers, checking for
compliance to our requirement about the number of divisors, until we
have enough of them.

*Incredibly*... the two programs print out the same list of numbers!
Isn't this *awesome*?!?

Stay safe people!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#141]: https://theweeklychallenge.org/blog/perl-weekly-challenge-141/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-141/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
