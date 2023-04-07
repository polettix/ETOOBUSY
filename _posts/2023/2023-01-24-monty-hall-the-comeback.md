---
title: Monty Hall - the comeback!
type: post
tags: [ maths, perl ]
comment: true
date: 2023-01-24 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Additional twists on [The Monty Hall problem][].

It starts from a [toot by Ovid][toot]:

> One of my favorite logic puzzles, and one people get wrong all the
> time.
>
> You're given three doors, A, B, and C. There is a prize behind one. If
> you choose the right door, you win the prize.
>
> You choose a door and the host opens a door you didn't choose and
> shows there's no prize. You're given a chance to change your mind and
> switch your choice to the remaining unopened door.
>
> Do you change your mind or not? Why or why not?

It immediately struck me that there's no mention about *how* the host
opends one of the doors that were not chosen, and I was about to ask
about it. Only to find that it had already been discussed in the thread.

So I asked them to *implement* their ideas, so that we can talk about
some code where things are expressed very precisely. Just to remember
that... *I already did this in [The Monty Hall problem][]!*

Except that I never implemented the *totally random host*, so here we go
with an update, where the host is also allowed to reveal the big prize:

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
say "What a season! $player_class won $percentage of times!";


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
   say "Look at this! A $prize_behind{$_} behind $_!"
      for $revealed->@*;

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

package TotallyRandomMontyHall;
use List::Util 'shuffle';
use parent -norequire => 'MontyHall';
sub reveal ($self, $scenario, $player_choice, $alternatives) {
   say "alternatives($alternatives->@*) $player_choice";
   my @revealed = grep { $_ ne $player_choice } $alternatives->@*;
   my $unrevealed = splice @revealed, rand(2), 1;
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

You might notice that I always return an array reference for *revealed*
doors and a single unrevealed door back. This is *peculiar* in the
regular Monty Hall problem, of course, as there are only two doors that
the host can choose from; it can help generalize the problem to much
more doors, though.

Anyway, here's the two modifications from the previous implementations:

1. there's a new host `TotallyRandomMontyHall`, which does not care
what's behind the door they're going to open (which is still chosen
randomly):

```perl
package TotallyRandomMontyHall;
use List::Util 'shuffle';
use parent -norequire => 'MontyHall';
sub reveal ($self, $scenario, $player_choice, $alternatives) {
   say "alternatives($alternatives->@*) $player_choice";
   my @revealed = grep { $_ ne $player_choice } $alternatives->@*;
   my $unrevealed = splice @revealed, rand(2), 1;
   return(\@revealed, $unrevealed);
}
```

2. because the host can reveal the big prize, we have to change the
chronicles code a bit inside `monty_hall_round`:

```perl
say "Look at this! A $prize_behind{$_} behind $_!"
    for $revealed->@*;
```

So... how did it go?

```
# MathPlayer always changes idea
$ perl mh.pl MathsPlayer TotallyRandomMontyHall
...
What a season! MathsPlayer won 32.2% of times!

# StubbornPlayer never changes idea
$ perl mh.pl StubbornPlayer TotallyRandomMontyHall
...
What a season! StubbornPlayer won 32.4% of times!


# RandomPlayer changes idea by flipping a coin
$ perl mh.pl RandomPlayer TotallyRandomMontyHall
...
What a season! RandomPlayer won 33.2% of times!

# ABCPlayer tries some magic
$ perl mh.pl ABCPlayer TotallyRandomMontyHall
...
What a season! ABCPlayer won 32.4% of times!
```

There you go folks... if the host does not know what's behind the door
they're going to reveal, whatever your strategy you're just getting
$\frac{1}{3}$ probability to win the big prize on average.

This makes sense:

- if the host reveals the big prize, whatever you do you are getting a
  goat. So you're going to lose *at least* $\frac{1}{3}$ of the times on
  average
- otherwise, half of the times you already have the prize and half of
  the times you don't. Which means... you win with probability
  $\frac{1}{3}$ overall.

Cheers!

[toot]: https://fosstodon.org/@ovid/109745522656272671
[Perl]: https://www.perl.org/
[The Monty Hall problem]: {{ '/2022/03/12/monty-hall-problem/' | prepend: site.baseurl }}
