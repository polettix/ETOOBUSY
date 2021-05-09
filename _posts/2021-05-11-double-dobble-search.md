---
title: Quest for Double Dobbles
type: post
tags: [ maths, dobble, double dobble ]
series: Double Dobble
comment: true
date: 2021-05-11 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Let's start searching for [Double Dobble][]!

In previous post [Double Dobble - constraints][] we touched upon the
relation between the number $k$ of symbols on a card (well... *in a block*),
the number $N$ of cards and the number $N$ of symbols over all cards.

In this post we will take  a look at implementing some logic to actually
find valid arrangements. Let's face it: the lack of code in [Double
Dobble][] is annoying. To me, at least.

# A few caveats

It's important at this point to remember that I made the assumption that
both the number of cards and the number of symbols are the same (i.e.
$N$), but I have no proof to offer that this MUST be the case for
[Double Dobble][] too.

Another thing to observe is that we will take the same approach
explained in [Double Dobble][]: find out a *displacement pattern* in the
circular arrangement of the blocks/cards that allows us to meet our
goal.

While this can work - and *indeed* it leads to successful arrangements -
I have no proof that a lack of proper arrangements of this type is
sufficient to rule out that a certain number $k$ of symbols on a card
has no valid solution. We can only say that this approach does not
produce a result for that $k$.

# Enough! Let's look for some Double Dobbles!

Each arrangement in the circle can be seen as choosing $k$ places out of
the $N$ available. This leads us to $N \choose k$ possible arrangements.

We can further chop this number down by observing that we should
*always* include the first position in the arrangement we check. Any
valid combination can be *translated* back to one including the first
position, so why bother looking? This means that we are left with ${N -
1} \choose {k - 1}$ combinations.

To get the valid combinations we will just... *count*, making sure that
for each position we only consider indexes greater than the selections
in the previous slots.

Suppose we have an arrangement, represented by the *indexes* in the
circular arrangement of $N$ symbols, in a range from $0$ up to $N - 1$:

$$A = (0, i_1, i_2, ...)$$

We can define the *opposite* of this arrangement the one where each
index is mapped onto its opposite in the circle with respect to index
$0$, that is:

$$A' = (0, N - i_1, N - i_2, ...)$$

The index $0$ is its self-opposite, just like counting in the group of
remainders modulo $N$.

An arrangement $A$ is acceptable if, and only if, its opposite $A'$ is
acceptable too - so in theory we might avoid checking arrangement that
are opposite of ones we already checked.

# Enough! Show me the code!

In coding our quest we will not consider the insight about skipping
*opposite* arrangement, for sake of simplicity.

As we don't know in anticipation $k$, we will turn to our old friend
`NestedLoops` in [Algorithm::Loop][], building an iterator for our
candidate arrangements:

```perl
my $it = NestedLoops(
   [
      [0],
      map {
         my $end = $N - 1 - ($k - 1) + $_;
         sub { [($_ + 1) .. $end] },
      } (1 .. $k - 1)
   ]
);
```

Now we can generate the arrangements and check until we find one that
provides us with a [Double Dobble][]:

```perl
while (my @seq = $it->()) {
   next unless check_double_dobble(@seq);
   say "(@seq)";
   last;
}

sub check_double_dobble (@seq) {
   my $k = @seq;
   my $N = 1 + $k * ($k - 1) / 2;
   my $max_delta = $N % 2 ? ($N - 1) / 2 : $N / 2;
   my (%one, %two);
   for my $i (0 .. $#seq - 1) {
      for my $j ($i + 1 .. $#seq) {
         my $delta = $seq[$j] - $seq[$i];
         $delta = $N - $delta if $delta > $max_delta;
         if ($one{$delta})    { $two{$delta} = delete $one{$delta} }
         elsif ($two{$delta}) { return }
         else                 { $one{$delta} = 1 }
      }
   }
   return if scalar(keys %one) == 1 && !$one{$max_delta};
   return 1;
}
```

The `check_double_dobble` function is not very... *scientific*, in that
it bails out immediately if we hit a delta three times (it would not be
a valid [Double Dobble][]), but still allows for one of the deltas to
appear exactly once (in particular, the maximum possible delta).

I currently have no demonstration of why this is true... but it seems to
work 🙄

It is interesting that the code above yields the sequence of indexes $(0
1 2 4 7)$ for an input $k = 5$, which is *different* from the one in
[Double Dobble][], although still working of course:

```
0 1 2 4
  1 1 3
    2 2 5
      4 3
4 5     7
```

This makes me *really* curious of what algorithm they used.

It's also interesting that there are no solutions for $k \in \{6, 7,
8\}$, but there is one for $k = 4$ (and $N = 7$) that *might* have
escaped the scrutiny in [Double Dobble][]:

```
0 1 2
  1 1 3
    2 2
3     4
```

It leads to a *very simple* game with 7 cards only... but it's still
better than the more *trivial* case for $k = 3$.

Well... at least now I know how the author of [Double Dobble][] *might*
have been approached the problem... but didn't!

[Double Dobble - constraints]: {{ '/2021/05/10/double-dobble/' | prepend: site.baseurl }}
[Matt Parker on Dobble]: {{ '/2021/05/04/matt-parker-dobble/' | prepend: site.baseurl }}
[Double Dobble]: https://aperiodical.com/2020/05/the-big-lock-down-math-off-match-22/
[Matt Parker]: http://standupmaths.com
[video]: https://www.youtube.com/watch?v=VTDKqW_GLkw
[Some Maths for Dobble]: http://blog.polettix.it/some-maths-for-dobble/
[Dobble]: https://boardgamegeek.com/boardgame/63268/spot-it
[pg2]: https://metacpan.org/source/POLETTIX/Math-GF-0.004/eg/pg2
[Algorithm::Loop]: https://metacpan.org/pod/Algorithm::Loop
