---
title: Brute forcing "The monkey and the coconuts"
type: post
tags: [ puzzle, rakulang ]
comment: true
date: 2021-07-24 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Brute forcing an old puzzle: [The monkey and the coconuts][].

A (lot) while ago I read about puzzle [The monkey and the coconuts][] in
one of [Martin Gardner][]'s books, and I was fascinated by the answer. A
big part of the fascination was coming from the fact that the book
observed that it was practically *too boring* to try and brute force the
puzzle all by *human* trial and error.

I'm pretty much sure that I came across the puzzle again during the
years, and surely after I started doing some programming with C64 and
later with a PC. To be honest, it never occurred to me to try and brute
force it with a computer at the time.

Until now, where I thought... *how hard can it be?!?*. So I was set to
do some [Raku][] programming to get some exercise.

Before going to the implementation, it's good to point out that there
are (at least) two versions of the puzzle:

- **basic**, were the monkey gets one more coconut:

> Five men and a monkey were shipwrecked on an island. They spent the
> first day gathering coconuts. During the night, one man woke up and
> decided to take his share of the coconuts. He divided them into five
> piles. One coconut was left over so he gave it to the monkey, then hid
> his share, put the rest back together, and went back to sleep.
>
> Soon a second man woke up and did the same thing. After dividing the
> coconuts into five piles, one coconut was left over which he gave to
> the monkey. He then hid his share, put the rest back together, and
> went back to bed. The third, fourth, and fifth man followed exactly
> the same procedure. The next morning, after they all woke up, they
> divided the remaining coconuts into five equal shares. **Again, one
> coconut remains after the division, and it is given to the monkey**.


- **Williams**, where the monkey does not get a coconut the day after:

> Five men and a monkey were shipwrecked on an island. They spent the
> first day gathering coconuts. During the night, one man woke up and
> decided to take his share of the coconuts. He divided them into five
> piles. One coconut was left over so he gave it to the monkey, then hid
> his share, put the rest back together, and went back to sleep.
>
> Soon a second man woke up and did the same thing. After dividing the
> coconuts into five piles, one coconut was left over which he gave to
> the monkey. He then hid his share, put the rest back together, and
> went back to bed. The third, fourth, and fifth man followed exactly
> the same procedure. The next morning, after they all woke up, they
> divided the remaining coconuts into five equal shares. **This time no
> coconuts were left over**.


They differ only in the last detail, which is easy to *refactor* so one
single implementation with slightly different inputs does the trick:

```raku
#!/usr/bin/env raku
use v6;

subset PosInt of Int where * > 0;

sub any-version (PosInt $sailors, @monkey-gains is copy) {
   my $last-gain = @monkey-gains.pop;
   ATTEMPT:
   for 1 .. Inf -> $last-quota {
      my $x = $last-quota;
      for @monkey-gains -> $to-monkey {
         $x = $x * $sailors + $to-monkey;
         next ATTEMPT unless $x %% ($sailors - 1);
         $x /= $sailors - 1;
      }
      return ($x * $sailors + $last-gain, $last-quota);
   }
   return $sailors;
}

sub basic-version (PosInt $sailors) {
   return any-version($sailors, [1 xx ($sailors + 1)]);
}

sub williams-version (PosInt $sailors) {
   return any-version($sailors, [0, |(1 xx $sailors)]);
}


my $sailors = @*ARGS ?? @*ARGS[0].Int !! 5;
say 'basic version: ', basic-version($sailors);
say 'Williams version: ', williams-version($sailors);
```

Each solution is composed of two integers, the first representing the
total number of coconuts that were collected in the first place, the
second representing the number of coconuts that each sailor gets in the
last division the morning after the collection.

# The algorithm

Doing brute force in this case basically means trying out candidate
inputs until one matches all requirements.

My first idea was to use the *total number of initial coconuts*, but
then I thought... **why?!?* I mean, a valid solution MUST end up with an
integer value for what is given to each sailor the day after, and this
MUST be a lower number, right?

This is why the *outer* `ATTEMPT:` loop feeds variable `$last-quota`,
which represents... what we said.

Inside the loop, we have to test that this candidate value is indeed
valid, going *backwards in time*. In other terms, we go through the
division process backwards, from the last iteration back to when the
first sailor decides to do a preliminar division of the coconuts.

Hence, at each stage we:

- calculate the total number of coconuts *before* the division, by
  multiplying the current value `$x` times the number of sailors, then
  adding the coconuts that are given to the monkey (which we keep in
  @monkey-gains);

- check that this number is divisible by the number of sailors, minus
  one. Why? Well, this is what is expected to remain after one of the
  sailors did their division, where it took one part and left four
  parts, so this number MUST be divisible by 4.

This goes on until we arrive to the very first sailor. In this case,
though, we can lift off the constraints that the number is divisible by
4, because we are on the initial, total number of coconuts and we have
no such constraint on it. Hence, we just use `$last-gain` without doing
any check.

The inner loop tries to go through the whole `@monkey-gains` (except the
`$last-gain`, of course) and if it succeeds we have a solution. If any
intermediate step fails, then the `next ATTEMPT` just sets us to try the
next candidate.

The two variants of the puzzle can be addressed by feeding different
values for the coconuts gained by the monkey. In the basic case, we
provide an array that contains 1 coconut for each division step we want
to go through; in the other case, we provide 0 coconuts for the *morning
step* and 1 coconut for each division performed by the sailors on their
own.

# A couple of [Raku][] considerations

All in all, I think I'm keeping my strong *[Perl][] accent* while coding
in [Raku][], and I like it very much. Who does not like a slight foreign
accent in people?

One cool thing is to iterate through a lazy list that's potentially
infinite:

```raku
for 1 .. Inf -> $last-quota { ...
```

The equivalent in [Perl][] would probably be something like this:

```perl
my $last_quota = 0;
while ('necessary') {
    $last_quota++;
    ...
```

but it's not as readable as the other.

Another thing that I discovered is that `x` becomes `xx` when we want to
"multiply" lists:

```raku
return any-version($sailors, [1 xx ($sailors + 1)]);
```

I was initially puzzled by this, although I have to admit that having
separate operators to express separate operations is probably saner.

Getting the input number of sailors from the command line is somehow
*worse* though:

```raku
my $sailors = @*ARGS ?? @*ARGS[0].Int !! 5;
```

I like [Perl][] better in this case:

```perl
my $sailors = shift || 5;
```

(Of course I hope someone will point out how to express this in [Raku][]
😋)

# Last: human brute-forcing

The consideration about what to use as an iteration candidate for
solving the problem got me thinking... *was this really so difficult to
solve by human brute forcing?*

Let's do a quick back-of-the-envelope calculation.

As correctly pointed out in [Martin Gardner][]'s column, as well as
everywhere this puzzle is analyzed, there are infinite solutions for the
total number of coconuts, which are spaced by multiples of $5^6 =
15625$. Hence, a *minimal positive* solution must be comprised between 1
and 15625 (otherwise we can simply subtract 15625 until we get a number
lower or equal to it).

This seems daunting indeed: if we took on average 2 minutes to check
each candidate, we would need 31250 minutes, which is about 521 hours.
If we dedicate 1 hour per day to this task, it would take about one year
and a half to go through all the candidates, so on average we would
solve it in about 9 months. Not very encouraging.

On the other hand, let's consider focusing on the remaining coconuts
first, and working backwards. This has the advantage that
multiplications are easier (multiplying by 5 is multiplying by 10 and
dividing by 2, both very easy to accomplish) and divisions too (we have
to divide by 4, which is twice a division by 2, again very easy to check
and to do).

Additionally, the *worst case* for the total number of coconuts is of
course 15625 itself, i.e. the biggest value. What does this mean for the
last quota? Assuming that there is *no coconut* given to the monkey, the
last quota would be:

$$ L = \frac{5^6}{5} \left(\frac{4}{5}\right)^5 = 4^5 = 1024$$

Hence, our last quota will have to be *lower* than this value (because
we have to take into account that something goes to the monkey).

Again, if we take 2 minutes to test one candidate, it means at most 2048
minutes, i.e. about 34 hours and some. Even if we go in order, it would
take us 34 days with one hour of work per day... which is not too bad!

But, of course, **there's more**.

Any *last value* $L$ will have to be such that:

$$
5L + 1 \equiv 0 \pmod 4 \\
5L \equiv -1 \pmod 4 \\
L \equiv -1 \pmod 4
$$

i.e. $L = 4k - 1$ with $0 \leq k \leq 256$. The last passage is allowed
because:

$$
(5L)_4 = 5_4 L_4 = L_4
$$

where $X_4 \doteq X \pmod 4$.

In other terms, it only makes sense to consider *one-fourth* of the
candidates we were discussing about before.

This also means that our overall time to a solution drops to about 9
hours... i.e. slightly more than one week. This is definitely in reach!

A similar consideration might be done for *Williams*'s puzzle, although
in this case we would have to consider that the monkey does *not* get a
coconut in the last division, i.e. $L$ is such that:

$$
5L \equiv 0 \pmod 4 \\
L \equiv 0 \pmod 4
$$

i.e. $L = 4k$, again with with $1 \leq k \leq 256$.

> It's worth noting that if we proceed in order, the *basic* puzzle
> would require us to go through *all* 256 values, because the solution
> is 1023, i.e. exactly the last one. In the case of *Williams*'s
> puzzle, though, the solution is 204, so we would reach it at the
> 51<sup>th</sup> attempt, i.e. in the second hour of trial-and-error!

I hope you enjoyed it, stay safe folks!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[The monkey and the coconuts]: https://en.wikipedia.org/wiki/The_monkey_and_the_coconuts
[Martin Gardner]: https://en.wikipedia.org/wiki/Martin_Gardner
