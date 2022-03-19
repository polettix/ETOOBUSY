---
title: 'The Monty Hall problem - ABCPlayer'
type: post
tags: [ maths, perl ]
comment: true
date: 2022-03-19 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Additional reflections about the [Monty Hall problem][].

In previous post [The Monty Hall problem][] I took a look at the [Monty
Hall problem][], with a [Perl][] twist.

[E7....][] user in Twitter was so nice to play a bit with it and had an
interesting [consideration][]:

> When "ABCPlayer" plays against "RandomMontyHall", the player wins ~50%
> of times.

I already observed this phenomenon, and tought that it had to be related
to the fact that the `ABCPlayer` does indeed swap sometimes, so it's
probably equivalent to a random swap for enough runs of the simulation:

```perl
package ABCPlayer;
use parent -norequire => 'Player';
sub swaps_with ($self, $unrevealed) {
   for my $alternative ($self->{alternatives}->@*) {
      next if $alternative eq $self->{initial};
      return $alternative eq $unrevealed;
   }
}
```

But of course at this point I had to brush off my lazyness and do some
better analysis.

There are a total of 9 possible random arrangements of the prizes behind
the door and player's initial choices, indicated with round parentheses:

```
 A   B   C
-----------
(W)  L   L

 W  (L)  L

 W   L  (L)

(L)  W   L

 L  (W)  L

 L   W  (L)

(L)  L   W

 L  (L)  W

 L   L  (W)
```

The winning prize can be behind door `A`, `B`, or `C` and for each of
these three possibilities the initial player's choice can be, again,
door `A`, `B`, or `C`.

The `RandomMontyHall` host will choose deterministically if the player
has a losing door, and randomly otherwise. To account for both
possibilities of this random choice, it makes sense to double all these
possibilites and indicate the opened door with square brackets:

```
 A   B   C                A   B   C
-----------              -----------
(W) [L]  L               (W)  L  [L]

 W  (L) [L]               W  (L) [L]

 W  [L] (L)               W  [L] (L)

(L)  W  [L]              (L)  W  [L]

[L] (W)  L                L  (W) [L]

[L]  W  (L)              [L]  W  (L)

(L) [L]  W               (L) [L]  W

[L] (L)  W               [L] (L)  W

[L]  L  (W)               L  [L] (W)
```

As expected, the opened door always reveals a losing prize. Pairs on the
same line are equal, except for the cases where a random choice is done
by the host, in which case we show both alternatives.

Now we can apply the `ABCPlayer`'s tactic to mark which cases yield a
swap and which don't:

```
 A   B   C                A   B   C
-----------              -----------
(W) [L]  L   keep        (W)  L  [L]  swap

 W  (L) [L]  swap         W  (L) [L]  swap

 W  [L] (L)  swap         W  [L] (L)  swap

(L)  W  [L]  swap        (L)  W  [L]  swap

[L] (W)  L   keep         L  (W) [L]  swap

[L]  W  (L)  keep        [L]  W  (L)  keep

(L) [L]  W   keep        (L) [L]  W   keep

[L] (L)  W   keep        [L] (L)  W   keep

[L]  L  (W)  keep         L  [L] (W)  swap
```

As expected, there are 9 `swap`s and 9 `keep`s. Let's also add the
player's outcome:

```
 A   B   C                A   B   C
-----------              -----------
(W) [L]  L   keep W      (W)  L  [L]  swap L

 W  (L) [L]  swap W       W  (L) [L]  swap W

 W  [L] (L)  swap W       W  [L] (L)  swap W

(L)  W  [L]  swap W      (L)  W  [L]  swap W

[L] (W)  L   keep W       L  (W) [L]  swap L

[L]  W  (L)  keep L      [L]  W  (L)  keep L

(L) [L]  W   keep L      (L) [L]  W   keep L

[L] (L)  W   keep L      [L] (L)  W   keep L

[L]  L  (W)  keep W       L  [L] (W)  swap L
```

Again, as expected there are 9 wins and 9 losses, which also accounts
for the ~50% of player's wins in the long run.

Please stay safe!


[Perl]: https://www.perl.org/
[Monty Hall problem]: https://en.wikipedia.org/wiki/Monty_Hall_problem
[lmad]: https://en.wikipedia.org/wiki/Let%27s_Make_a_Deal
[Game Show Problem]: https://web.archive.org/web/20130121183432/http://marilynvossavant.com/game-show-problem/
[Marilyn vos Savant]: https://en.wikipedia.org/wiki/Marilyn_vos_Savant
[The Monty Hall problem]: {{ '/2021/03/12/monty-hall-problem/' | prepend: site.baseurl }}
[consideration]: https://twitter.com/e7_87/status/1502920960969932800
[E7....]: https://twitter.com/e7_87
