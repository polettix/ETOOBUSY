---
title: The Monty Hall problem
type: post
tags: [ maths, perl ]
comment: true
date: 2022-03-12 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Some reflections about the [Monty Hall problem][].

The [Monty Hall problem][] is a nice "paradox" that isn't. It's easy to
fall and fail, and it's easy to also get it wrong in *explaining* how it
works.

This is one of the most common formulations (from [Wikipedia][Monty Hall
problem], which comes from [Game Show Problem][] by [Marilyn vos
Savant][]):

> Suppose you're on a game show, and you're given the choice of three
> doors: Behind one door is a car; behind the others, goats. You pick a
> door, say No. 1, and the host, who knows what's behind the doors,
> opens another door, say No. 3, which has a goat. He then says to you,
> "Do you want to pick door No. 2?" Is it to your advantage to switch
> your choice?

The host *knows what's behind the doors* and always opens a door with a
goat. It's always possible, because there are two doors left by the
player and there's only one car, so one of the two doors MUST have a
goat behind.

There is a definite advantage in switching the choice, which leads to a
win in 2 out of 3 times (odds 2:1), so the answer to the question is a
**yes**. Many people think that, after the revelation, it's a 1:1 odds
situation though.

My no-brainer go-to solution to this apparent paradox is this
alternative game: there are two players, the first can pick whatever
door they want, the other player takes *all of the remaining*. There is
no switching. Which player would you like to be?

Your answer, I think, will be the second player. They get **two** doors
instead of **one**, so double the chances to a win, right? OK, unless
you're a magician and know what's behind the doors, of course.

In picking the two-doors alternative, anyway, you already know
*fore sure* that *at least* one of them is a goat. Again, you have two
doors and there's only one car, so one of the doors MUST have a goat
behind.

At this point, the host of the show starts opening your doors, revealing
the goat that you know is somewhere (and the host knows *where* it is).
Is your situation any worse than before? No! Because you already knew
that there was (at least) one goat on your side, the host only told you
which door it was out of the two.

If you're more [Perl][] inclined, [Let's Make a Deal][lmad]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'shuffle';

our $WIN = 'car';
our $LOSE = 'goat';

my ($player_class, $monty_class) = @ARGV;
my $player = $player_class->new;
my $monty  = $monty_class->new;
my $total = 1_000;
my $wins = 0;
for (1 .. $total) {
   $wins++ if monty_hall_round($player, $monty);
}
my $percentage = sprintf '%.1f%%', 100 * $wins / $total;
say "What a season! Players won $percentage of times!";


sub monty_hall_round ($player, $monty) {
   my @door_names = ('Door A', 'Door B', 'Door C');

   # build a scenario
   my %prize_behind;
   @prize_behind{@door_names} = shuffle($WIN, $LOSE, $LOSE);

   # let the player choose
   my $player_choice = $player->initial_choice(\@door_names);
   say "Well! Player chose $player_choice...";

   my ($revealed, $unrevealed) = $monty->reveal(
      \%prize_behind, $player_choice, \@door_names);
   say "Look at this! A $LOSE behind $_!" for $revealed->@*;

   if ($player->swaps_with($unrevealed)) {
      say "Player swaps $player_choice with $unrevealed!";
      $player_choice = $unrevealed;
   }
   else {
      say "Player keeps $player_choice!";
   }
   say '';

   return $prize_behind{$player_choice} eq $WIN;
} ## end sub monty_hall_round

package Player;
sub new { bless {}, shift }
sub initial_choice ($self, $alternatives) {
   my @alts = $alternatives->@*;
   $self->{alternatives} = \@alts;
   $self->{initial} = @alts[rand @alts];
}
sub swaps_with ($self, $unrevealed) { ... }

package StubbornPlayer;
use parent -norequire => 'Player';
sub swaps_with ($self, $unrevealed) { return 0 } # never swaps

package MathsPlayer;
use parent -norequire => 'Player';
sub swaps_with ($self, $unrevealed) { return 1 } # always swaps

package RandomPlayer;
use parent -norequire => 'Player';
sub swaps_with ($self, $unrevealed) { return int rand 2 }

package ABCPlayer;
use parent -norequire => 'Player';
sub swaps_with ($self, $unrevealed) {
   for my $alternative ($self->{alternatives}->@*) {
      next if $alternative eq $self->{initial};
      return $alternative eq $unrevealed;
   }
}


package MontyHall;
sub new { bless {}, shift }
sub unchosen ($self, $scenario, $player_choice, $alternatives) {
   my (@wins, @loses);
   for my $alternative ($alternatives->@*) {
      next if $alternative eq $player_choice;
      if ($scenario->{$alternative} eq $WIN) {
         push @wins, $alternative;
      }
      else {
         push @loses, $alternative;
      }
   }
   return (\@loses, \@wins);
}
sub reveal ($self, $scenario, $player_choice, $alternatives) { ... }

package RandomMontyHall;
use List::Util 'shuffle';
use parent -norequire => 'MontyHall';
sub reveal ($self, $scenario, $player_choice, $alternatives) {
   my $n_unchosen = $alternatives->@* - 1;
   my ($unchosen_loses, $unchosen_wins) =
      $self->unchosen($scenario, $player_choice, $alternatives);
   my @loses = shuffle($unchosen_loses->@*);

   # reveal exactly n-1 of the unchosen doors!
   my @revealed = splice @loses, 0, $n_unchosen - 1;
   my ($unrevealed) = (@loses, $unchosen_wins->@*);
   return(\@revealed, $unrevealed);
}

package OrderedMontyHall;
use parent -norequire => 'MontyHall';
sub reveal ($self, $scenario, $player_choice, $alternatives) {
   my $n_unchosen = $alternatives->@* - 1;
   my ($unchosen_loses, $unchosen_wins) =
      $self->unchosen($scenario, $player_choice, $alternatives);
   my @loses = $unchosen_loses->@*; # NO SHUFFLING HERE!!!

   # reveal exactly n-1 of the unchosen doors!
   my @revealed = splice @loses, 0, $n_unchosen - 1;
   my ($unrevealed) = (@loses, $unchosen_wins->@*);
   return(\@revealed, $unrevealed);
}
```

This program implements different strategies on the player and on the
host side. There are four players:

- `StubbornPlayer`: they *always* stick to their initial choice;
- `MathsPlayer`: they *always* switch;
- `RandomPlayer`: they switch half of the times, randomly;
- `ABCPlayer`: they adopt a strategy to switching.

There are two hosts:

- `RandomMontyHall`: if one of the two *unchosen* door contain a car,
  they reveal the other one; if they both contain a goat, they reveal
  either one randomly;
- `OrderedMontyHall`: if one of the two *unchosen* doors contain a car,
  they reveal the other one; if the both contain a goat, they reveal the
  "first" one in door order.

It's easy to see, in the code, that the initial choice of the player is
always out of three doors, so their odds of taking the car is 1:2 (1 in
3 chances). This does not change whatever the host that is chosen,
because the array of *unchosen* alternatives is scanned to make sure
that only goats are revealed. Hence, what remains at the end is the
*distillation* of unchosen possibilities.

Running the simulation with the stubborn and the maths inclined players
and a truly random Monty Hall confirms our initial guess: switching is
beneficial:

```
$ ./monty-hall.pl StubbornPlayer RandomMontyHall
...
What a season! Players won 35.8% of times!

$ ./monty-hall.pl MathsPlayer RandomMontyHall
...
What a season! Players won 68.2% of times!
```

People that think that odds have gone down to 1:1 after the revelation
are "rightish" in the sense that a random choice between the two doors
yields a car half of the times:

```
$ ./monty-hall.pl RandomPlayer RandomMontyHall
...
What a season! Players won 50.2% of times!
```

This happens because at that point there are only two doors, one with a
car and one with a goat (by construction), so a random 1:1 choice
between them gives a car 1:1. I'd argue that this is throwing away all
the information that we have that lead to *how* these two doors were
actually selected to be closed at the end, which is a shame because this
information can definitely give an edge.

Last, it's important that the choice of the door to open by the host
when the player chose the car is *random*. If the host decides to always
open the "first" one (whatever order can be given to the doors), then
the player might use this information the their advantage and choose to
switch whenever this reveals something:

```
$ ./monty-hall.pl ABCPlayer OrderedMontyHall
...
What a season! Players won 67.4% of times!
```

Contrarily to the other case, in this case the player only switches in 1
out of 3 cases when they're sure about the car position, and keeps in
the other two so, in a sense, they're more *stubborn* than inclined to
change. BUT they know exactly when it's best to change, shifting the
odds in their favor by taking advantage of the *deterministic* way of
choosing the door to open by the host.

Well... this is my take on the [Monty Hall problem][], and I've
expressed in code so there is no ambiguity as to what I mean about the
actions of the different actors!


[Perl]: https://www.perl.org/
[Monty Hall problem]: https://en.wikipedia.org/wiki/Monty_Hall_problem
[lmad]: https://en.wikipedia.org/wiki/Let%27s_Make_a_Deal
[Game Show Problem]: https://web.archive.org/web/20130121183432/http://marilynvossavant.com/game-show-problem/
[Marilyn vos Savant]: https://en.wikipedia.org/wiki/Marilyn_vos_Savant
