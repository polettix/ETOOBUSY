---
title: PWC147 - Pentagon Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-01-13 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#147][].
> Enjoy!

# The challenge

> Write a sript to find the first pair of `Pentagon Numbers` whose sum
> and difference are also a `Pentagon Number`.
>
>> Pentagon numbers can be defined as P(n) = n(3n - 1)/2.
>
> **Example**
>
>     The first 10 Pentagon Numbers are:
>     1, 5, 12, 22, 35, 51, 70, 92, 117 and 145.
>
>     P(4) + P(7) = 22 + 70 = 92 = P(8)
>     but
>     P(4) - P(7) = |22 - 70| = 48 is not a Pentagon Number.

# The questions

I guess this is a slight variation on [Project Euler 44][], although a
bit more *hairy*.

One question is about the input for the formula. It's only from the
examples that we see that the inputs are only positive integers. To be
fair, this is also in the original formulation.

The difference here is in what to find exactly. While puzzle at [Projece
Euler 44][] asks for a precise condition, here we're required to find
the *first pair* to satisfy the conditions. I see this as an act of
kindness, because a lot of solutions around actually arrive to the right
"optimal" solution only because it's also the first one to be found (at
least with the approach many have adopted).

# The solution

Whatever, I decided to go for a real, *validated* solution for [Project
Euler 44][] too, so the solution below makes sure that the first
solution found is also optimal.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

$|++;
my ($delta, $X, $Y, $sum) = lowest_difference_superpentagonals();
say '';
my @n = map { invert_pentagonal($_) } ($delta, $X, $Y, $sum);

say "delta<$delta> ($n[0])";
say "    X<$X> ($n[1])";
say "    Y<$Y> ($n[2])";
say "  sum<$sum> ($n[3])";

say " Y - X - delta = @{[$Y - $X - $delta]}";
say " Y + X - sum   = @{[$Y + $X - $sum]}";

#
#  X < Y are our candidates.
#  delta = Y - X  -->   Y =  X + delta
#  sum   = Y + X  --> sum = 2X + delta
#
sub lowest_difference_superpentagonals {
   my ($delta, $n_delta) = (0, 0);
   my @upper;
   while ('necessary') {
      $delta += 3 * $n_delta++ + 1; # we have to find the minimum delta
      print "\r$n_delta ($delta)";
      return @upper if @upper && $upper[0] <= $delta;

      # X = P(n_X)   and P(n_X + 1) - X = 3 * n_X + 1
      #
      # This means that delta MUST be greater than 3 * n_X + 1, otherwise
      # it will not "allow" X to reach any of the following pentagonal
      # number. This means:
      #
      # delta >= 3 * n_X + 1  => n_X <= (delta - 1) / 3
      my $max_n_X = int(($delta - 1) / 3);

      # X *might* be less than delta, of course, but we will check this
      # on the way, so we will only consider values of X greater than that
      my $X = $delta;
      for my $n_X ($n_delta + 1 .. $max_n_X) {
         $X += 3 * $n_X - 2;
         my $Y = $X + $delta; # this does not change inverting roles
         invert_pentagonal($Y) or next;

         # now let's consider delta < X  --> $sum = $Y + $X
         my $sum = $Y + $X;
         return ($delta, $X, $Y, $sum) if invert_pentagonal($sum);

         # now let's consider X < delta and swap their roles...
         $sum = $Y + $delta;
         if (my $n_sum = invert_pentagonal($sum)) {

            # we just record that we have an upper limit for delta here,
            # but still there might be some better delta in between
            @upper = ($X, $delta, $Y, $sum)
               if !@upper || $X < $upper[0];

            say "  current candidate @upper";
         }
      }
   }
}

sub invert_pentagonal ($P) {
   my $root = int sqrt(my $maybe_square = 1 + 24 * $P);
   return unless $root * $root == $maybe_square;
   return if ++$root % 6;
   return $root / 6;
}
```

We will call the two pentagonal numbers in the pair that we are looking
for $X$ and $Y$, with $X < Y$. So we have that also:

$$
\Delta = Y - X \\
\Sigma = Y + X
$$

must both be pentagonal too.

From these definitions, we also have that one of the following chains of
inequalities is true:

$$
\Delta < X < Y < \Sigma \\
X < \Delta < Y < \Sigma
$$

So I thought it easier to iterate through possible values of $\Delta$
and $X$, and find the other to accordingly:

$$
Y = X + \Delta \\
\Sigma = Y + X = 2X + \Delta
$$

The uncertainty about which between $X$ and $\Delta$ is bigger might
lead to double checking some configurations, so for each pair we
actually test them in order (i.e. setting $\Delta$ to the smaller one)
or in reverse (i.e. setting $X$ to the smaller one).

If the first case yields a solution, it's a really optimal solution as
long as we start from the smallest possible $\Delta$ and we increase it
gradually.

In the second case, we cannot say we have an optimal solution from the
beginning, because in this case $\Delta$ is the bigger number and there
might be a better difference in between. In any case, this can become
our best candidate for a solution, i.e. an upper limit that we can print
as soon as we have it (and we do).

The [Raku][] alternative is... pretty much the same:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   my ($delta, $X, $Y, $sum) = lowest-difference-superpentagonals();
   put '';
   my @n = ($delta, $X, $Y, $sum).map: { invert-pentagonal($_) };

   put "delta<$delta> ({@n[0]})";
   put "    X<$X> ({@n[1]})";
   put "    Y<$Y> ({@n[2]})";
   put "  sum<$sum> ({@n[3]})";

   put " Y - X - delta = {$Y - $X - $delta}";
   put " Y + X - sum   = {$Y + $X - $sum}";
}

sub lowest-difference-superpentagonals {
   my ($delta, $n-delta) = 0, 0;
   my @upper;
   loop {
      $delta += 3 * $n-delta++ + 1;
      print "\r$n-delta ($delta)";
      return @upper if @upper && @upper[0] <= $delta;

      my $max-n-X = (($delta - 1) / 3).Int;
      my $X = $delta;
      for $n-delta ^.. $max-n-X -> $n-X {
         $X += 3 * $n-X - 2;
         my $Y = $X + $delta;
         invert-pentagonal($Y) or next;

         my $sum = $Y + $X;
         return [$delta, $X, $Y, $sum] if invert-pentagonal($sum);

         $sum = $Y + $delta;
         next unless invert-pentagonal($sum);
         @upper = $X, $delta, $Y, $sum if (! @upper) || $X < @upper[0];
         say "  current candidate {@upper}";
      }
   }
}

sub invert-pentagonal ($P) {
   my $maybe-square = 1 + 24 * $P;
   my $root = $maybe-square.sqrt.Int;
   return unless $root * $root == $maybe-square;
   return unless ++$root %% 6;
   return $root / 6;
}
```

These solutions... can use some optimization, but are at least correct!

Stay safe folks, and have fun!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#147]: https://theweeklychallenge.org/blog/perl-weekly-challenge-147/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-147/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Project Euler 44]: https://projecteuler.net/problem=44
