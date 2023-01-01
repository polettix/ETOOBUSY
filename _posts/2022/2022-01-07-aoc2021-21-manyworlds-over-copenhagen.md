---
title: 'AoC 2021/21 - Many-Worlds over Copenhagen'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-01-07 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 21][puzzle] from [2021][aoc2021]:
> Many-Worlds, it seems, instead of the Copenhagen interpretation!

This day's puzzle starts relatively simple with a game of counting,
which can be easily (and *clearly*, I daresay) addressed with some
object-oriented programming:

```raku
class Player {
   has $!position is required is built;
   has $!score                is built = 0;

   method TWEAK (:$!position) { --$!position }

   method advance ($amount) {
      $!position = ($!position + $amount) % 10;
      $!score    += 1 + $!position;
   }

   method score () { $!score }
}

class DeterministicDie {
   has $!current is built = 99;
   has $!count            = 0;
   method roll () {
      ++$!count;
      $!current = ($!current + 1) % 100;
      return $!current + 1;
   }
   method roll3 () { (1..3).map({self.roll}).sum }
   method count () { $!count }
}

sub part1 ($inputs) {
   my @players = $inputs.map: { Player.new(position => $_) };
   my $die = DeterministicDie.new();
   my $target = 1000;
   my $current = 0;
   loop {
      @players[$current].advance($die.roll3);
      last if @players[$current].score >= $target;
      $current = 1 - $current;
   }
   return @players[1 - $current].score * $die.count;
}
```

Class `Player` takes care to track the position... *carefully*,
offsetting it by one and re-adding the lost position when necessary
(i.e. when scoring).

The `DeterministicDie` class is just the implementation of the
description in the puzzle. The `roll` method takes one value out, while
`roll3`... takes 3 and sums them.

I hope I didn't mess with the private member variables.

The second part of the puzzle is a totally different beast because it
asks us to play *all possible different games* and count the
winning/losing outcome for the two players. Just good, ol'
combinatorics, right?

It's worth noting that the puzzle tells us *explicitly* that the
universe splits at every roll of the dice, so it's clearly favoring the
Many-Worlds interpretation as opposed to the Copenhagen interpretation.
Whoever built this submarine probably knew one thing or two.

Anyway, simulating *all* possible matches with the brute force is a bit
*too much* here. My solution is in the order of $10^{14}$, which is a
tad too much for my limited resources.

In my solution, I assume I can compute the "moves to win" for the
players and use it to do the calculation:

```raku
sub part2 ($inputs) {
   my @mtws = $inputs.map: {moves-to-win($_)};

   my @wins;
   for 0, 1 -> $pid {
      my $player = @mtws[$pid];
      my $other  = @mtws[1 - $pid];
      my $n-wins = 0;
      for $player.kv -> $n-moves, $outcome {
         my $wins = $outcome<wins> or next;
         my $other-go-on = $other{$n-moves - 1 + $pid}<go-on>;
         $n-wins += $wins * $other-go-on;
      }
      push @wins, $n-wins;
   }

   return @wins.max;
}
```

The `moves-to-win()` function takes the starting score of a player and
provides back a statistic of how many moves are needed to win under the
different circumstances, i.e. possible outcomes of the *splitting die*.

The two starting positions will lead to different statistics, stored in
array `@mtws`.

At this point, we can compare the two, remembering that the first
player... *moves first*, but otherwise comparing the *moves to win* for
the two players and calculating the number of wins along the way (for a
player to win with $n$ moves, the other player must be in the situation
where it has *not* won yet).

So we're left with implementing `moves-to-win()`, right?

```raku
sub moves-to-win ($start) {
   my %factor-for;
   for (1..3) X (1..3) X (1..3) -> $tuple {
      %factor-for{$tuple.sum}++;
   }

   my %mtw;
   my $target = 21;
   my @stack = {position => $start - 1, score => 0, factor => 1, rolls => [3 .. 9]},;
   while (@stack) {
      my $top = @stack[* - 1];
      if ($top<rolls>.elems == 0) {
         @stack.pop;
         next;
      }

      my $roll = $top<rolls>.pop;
      my $position = ($top<position> + $roll) % 10;
      my $score = $top<score> + 1 + $position;
      my $factor = $top<factor> * %factor-for{$roll};
      if $score >= $target {
         %mtw{@stack.elems}<wins> += $factor;
         next; # no "recursion"
      }

      push @stack, {
         position => $position,
         score    => $score,
         factor   => $factor,
         rolls    => [3 .. 9];
      };
   }

   my $n = 1;
   my $residuals = 1;
   my $max-moves = %mtw.keys».Int.max;
   while $residuals > 0 {
      die if $n > $max-moves;
      my $wins = %mtw{$n}<wins> //= 0;
      $residuals = %mtw{$n}<go-on> = $residuals * 27 - $wins;
      ++$n;
   }

   return %mtw;
}
```

In the first part we calculate the statistic of the outcomes of rolling
three dice. As an example, a $3$ can come out only when the three dice
are all equal to 1, while e.g. $7$ can come out in many more different
ways (e.g. $1$, $3$, and $3$, among all of them).

From a single player's point of view, it's worth calculating the number
of wins with exactly $n$ moves only if the $n - 1$ moves before did not
lead to a victory (i.e. scoring the target value). We adopt a
stack-based approach to calculate all cases for the given number of
rolls, which is actually the explicit implementation of a recursion.

After data collection, it's counting time. The `$residuals` variable
tracks how many residual ways of going on are left, and it will
eventually go to 0 because the target is finite and the game always
moves pawns ahead anyway.

Just for fun, I also implemented a recursive solution that I read among
other solutions:

```raku
sub part2-play ($inputs) { return play2($inputs[0], $inputs[1], 0, 0).max }

sub play2 (*@args) {
   state %cache;
   state @die = (3,1), (4,3), (5,6), (6,7), (7,6), (8,3), (9,1);
   state &calc = sub ($p1, $p2, $s1, $s2) {
      return 0, 1 if $s2 >= 21;
      my ($w1, $w2) X= 0;
      for @die -> ($d, $n) {
         my $np1 = ($p1 + $d) % 10 || 10;
         my ($v2, $v1) = play2($p2, $np1, $s2, $s1 + $np1);
         ($w1, $w2) = $w1 + $v1 * $n, $w2 + $v2 * $n;
      }
      return $w1, $w2;
   };
   my $key = @args.join(',');
   return %cache{$key} //= &calc(|@args);
}
```

This time it's a real recursion... that takes a bit more time, but it's
probably easier on the reader. Here we are also compacting things a bit,
like defining the `@die` state variable to store the same dice outcome
statistic that we previously computed dynamically.

Calling `play2` recursively requires some attention and is extremely
easy to get wrong. Well, for me at least! Anyway, the principle is the
same as before: move on playing as long as the target hasn't been
reached by either player. At each stage, the number of wins is
multiplied by the number of occurrences of each roll outcome and the
result of the previous recursion.

This alternative solution has the merit of being *extremely* compact,
although it took me some time to implement it *right*. So it's not been
quick for me!

OK, enough for this day... stay safe folks!

[puzzle]: https://adventofcode.com/2021/day/21
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
