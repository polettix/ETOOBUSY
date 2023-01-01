---
title: PWC175 - Perfect Totient Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-07-28 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#175][].
> Enjoy!

# The challenge

> Write a script to generate first `20 Perfect Totient Numbers`. Please
> checkout [wikipedia page][wp] for more informations.
>
> **Output**
>
>     3, 9, 15, 27, 39, 81, 111, 183, 243, 255, 327, 363, 471, 729,
>     2187, 2199, 3063, 4359, 4375, 5571

# The questions

I guess the reference to the [Wikipedia page][wp] says it all.
Although... I can't help noting that both $0$ and $1$ might somehow
qualify. Anyway.

# The solution

This is finally the time that I complicate bread. The gist of this
challenge is to code some `is_perfect_totient_number`, which in turn
begs for implementing some `totient_supersum` that calculates the
iterative sum of totient values.

```perl
use ntheory 'euler_phi';
sub is_perfect_totient_number ($n) { $n == totient_supersum($n) }
sub totient_supersum ($n) {
   state $cache = {0 => 0, 1 => 1, 2 => 1};

   # first "recurse" up to the point where we have something
   # in cache
   my @stack = $n;
   push @stack, $n = euler_phi($n) while ! exists $cache->{$n};

   # then go back down to calculate all new needed values
   $n = pop @stack;
   my $pred = $cache->{$n};
   while (@stack) {
      ($n, my $phi) = (pop(@stack), $n);
      $pred = $cache->{$n} = $phi + $pred;
   }

   # whatever is left is what we were after in the first place
   return $pred;
}
```

And now we have our usual brute forcing the way up to the needed number
of items.

Well, this is it. This must end *now*.

So, instead of this:

```perl
# WARNING: UNTESTED CODE
my $n = shift // 20;
my $candidate = 2;
while ($n > 0) {
    if (is_perfect_totient_number($candidate)) {
        say $candidate;
        --$n;
    }
    ++$candidate;
}
```

I decided to go for this:

```perl
my $n_items = shift // 20;
say
  for BruteCheck::brutechecker(
   iterator => BruteCheck::int_iterator('2..'),
   ender    => BruteCheck::max_size($n_items),
   checker  => sub ($n) { return totient_supersum($n) == $n },
  );

# ...

package BruteCheck;

sub max_size ($n) { sub ($aref) { $aref->@* >= $n } }

sub int_iterator ($spec) {
   my ($start, $stop, $step) = $spec =~ m{
      \A
         ([1-9]\d*|0|)
         \.\.
         ([1-9]\d*|0|)
         (?: / (-?[1-9]\d*))?
      \z
   }mxs;
   $start ||= 0;
   $step  ||= 1;

   my $i = $start;
   return sub {
      return
        if length($stop)
        && (($step > 0 && $i > $stop) || ($step < 0 && $i < $stop));
      my $retval = $i;
      $i += $step;
      return $retval;
   };
} ## end sub int_iterator ($spec)

sub brutechecker (%args) {
   my ($checker, $iterator, $ender) = @args{qw< checker iterator ender >};
   $iterator //= int_iterator('..');
   $ender //= sub { 0 };
   my @retval;
   while (!$ender->(\@retval) && defined(my $candidate = $iterator->())) {
      push @retval, $candidate if $checker->($candidate);
   }
   return @retval;
} ## end sub brutechecker (%args)
```

So we get:

- a wonderfully overkill iterator generator which parses strings like
  `..` (from 0 to infinity), `2..` (from 2 up to infinity), `2..10`
  (from 2 to 10), `2..10/2` (two by two), ...
- a definitely overkill wrapper for checking when an array has a
  specific size, or more;
- a brute force generalization that will surely fail me the next time I
  need it.

Anyway, the [Raku][] alternative made me come to compromises. I gave up
on the parsing of a string and went for an explicit expression for the
start/stop/step values.

```raku
#!/usr/bin/env raku
use v6;

class IntIterator { ... }
class BruteCheck { ... }
sub MAIN (Int:D $n where * > 0 = 20) {
   $*OUT.out-buffer = False;
   .put for BruteCheck.new(
      iterator => IntIterator.new(start => 2),
      ender    => -> @x { @x.elems == $n },
      checker  => sub ($n) { $n == totient-supersum($n) },
   ).run();
}

sub totient-supersum ($n is copy) {
   state %cache = <0 0 1 1 2 1>;

   my @stack = $n,;
   @stack.push($n = euler-phi($n)) while %cache{$n}:!exists;

   $n = @stack.pop;
   my $pred = %cache{$n};
   while @stack {
      ($n, my $phi) = @stack.pop, $n;
      $pred = %cache{$n} = $phi + $pred;
   }

   return $pred;
}

sub euler-phi ($n) {
   state %cache = <0 0 1 1 2 1>;
   return %cache{$n} //= (1 ..^ $n).grep({($_ gcd $n) == 1}).elems;
}

class IntIterator {
   has $.start is readonly is built = 0;
   has $.stop is readonly is built = Inf;
   has $.step is readonly is built = 1;
   has $!current;
   submethod TWEAK() {
      $!current = $!start;
      $!stop = -Inf if $!stop == Inf && $!step < 0;
   }
   method pull-one {
      return Nil
         if ($!step > 0 && $!current > $!stop)
         || ($!step < 0 && $!current < $!stop);
      my $retval = $!current;
      $!current += $!step;
      return $retval;
   }
};

class BruteCheck {
   has &.checker;
   has &.ender is built = sub (@r) { False };
   has $.iterator is built = IntIterator.new();
   method run {
      my @rval;
      while (! &!ender(@rval) && defined(my $c = $!iterator.pull-one())) {
         @rval.push: $c if &!checker($c);
      }
      return @rval;
   }
}
```

And with all these unneeded lines of code... it's time to say goodbye
until next time!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#175]: https://theweeklychallenge.org/blog/perl-weekly-challenge-175/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-175/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wp]: https://en.wikipedia.org/wiki/Perfect_totient_number
