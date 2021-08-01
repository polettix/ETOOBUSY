---
title: Double check a puzzle result
type: post
tags: [ maths, rakulang ]
comment: true
date: 2021-08-02 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> I double checked a puzzle (theoretical) solution with some simulation
> in [Raku][].

I have a free account on [Brilliant][], which means I can enjoy a little
puzzle a day from them.

These puzzles are normally meant to be solved theoretically, that is by
thinking a bit on the problem and solving it e.g. with a couple of
formulas.

One recent puzzle was a interesting question about a game similar to
this:

> Roll a six-sided die and accumulate as many points as the outcome. If
> the outcome is greater than 2, repeat to gain more points; if the
> outcome is 1 or 2 stop.
>
> What is the expected value of the points accumulated?

Assuming a fair six-sided die, each face value has probability
$\frac{1}{6}$ of coming out, so the expected value *for a single round*
is:

$$
E_1 = \frac{1}{6} (1 + 2 + 3 + 4 + 5 + 6) = \frac{1}{6} \frac{7 \cdot
6}{2} = \frac{7}{2} = 3.5
$$

Then, of course, we have to consider that we would have to go on if the
outcome is greater than $2$. If we call our target, unknown expected
value $E$, this additional component that we have from continuing will
have to be considered only $4$ times out of $6$, i.e. only when the
outcome is one of $3$, $4$, $5$, or $6$. It contribution, then, will be
$\frac{4}{6} E = \frac{2}{3} E$.

Overall, then, our $E$ will be formed by the outcome of a single roll
$E_1$ and this additional component, i.e.:

$$
E = E_1 + \frac{2}{3} E = 3.5 + \frac{2}{3} E
$$


We can now solve for $E$:

$$
E - \frac{2}{3} E = 3.5 \\
\frac{1}{3} E = 3.5 \\
E = 10.5
$$

On average, then, our score will be 10.5 points.

Did I get the calculations right? Let's set up a simulation and double
check!

In pure *bottom-up* style, let's start defining one full round of the
game:

```raku
sub simulation-round () {
   return [+] gather {
      loop {
         my $value = roll-die();
         take $value;
         last if $value < 3;
      }
   }
}
```

The [`loop`] goes on *indefinitely*, although it has a positive and
finite probability of being interrupted thanks to statement `last if
$value < 3`, that is exactly our exit condition for a round of the game.

We use [`gather`/`take`][] to get the outcome of each roll of the die;
as our score is actually the *sum* of all these outcomes, we use the
[`[+]` reduction operator][reduction] to obtain this sum.

Now, to *estimate* the expected value we want to double check, we can
set up *a lot* of simulation rounds and take the average of the
outcomes:

```raku
my $N = @*ARGS.shift || 100;
my $total = [+] gather { take simulation-round() for 1 .. $N };
put 'average gain: ', $total / $N;
```

Again, we calculate the total sum of *all* the `$N` outcomes using
[`[+]`][reduction], applied to a [`gather`/`take`] pair that operates on whole
simulation rounds this time. At this point, the average is calculated by
dividing this `$total` by the number of rounds `$N` that we did.

The die rolling will be done a bit crudely, leveraging the stock
[`rand`][] facility. I'm not sure about its statistical characteristics,
but for our simulation it will do:

```raku
sub roll-die (Int:D $sides where * > 0 = 6) { (1 .. $sides).pick }
```

I'm also not entirely convinced that putting the default value *after*
the condition makes this entirely readable, but it's life.

Let's run this a few time, by averaging over 10000 rounds each time:

```
$ for i in 1 2 3 4 5 ; do raku multiple-rolls.raku 10000 ; done
average gain: 10.5096
average gain: 10.4038
average gain: 10.3704
average gain: 10.3157
average gain: 10.6384
```

It seems pretty consistent with the theoretical value of $10.5$ that we
calculated above, yay!

If you want to play with the code, there is a [local copy here][].

Have fun and stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Brilliant]: https://brilliant.org/
[`gather`/`take`]: https://docs.raku.org/language/control#gather/take
[`loop`]: https://docs.raku.org/language/control#loop
[reduction]: https://docs.raku.org/language/operators#Reduction_metaoperators
[local copy here]: {{ '/assets/code/multiple-rolls.raku' | prepend: site.baseurl }}
[`rand`]: https://docs.raku.org/routine/rand
