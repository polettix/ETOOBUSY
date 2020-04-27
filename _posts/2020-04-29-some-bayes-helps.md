---
title: Some Bayes helps
type: post
tags: [ maths, probabilities ]
comment: true
date: 2020-04-29 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> I've been thinking a bit about inference applied to a concrete
> problem.

In these times of [Covid-19][] there are a lot of discussions about the
Apps that are supposed to tell you whether you got in contact with other
people, so that sanitary checks can be targeted.

I know that a lot of those discussions are about the privacy concerns.
On the one hand these concerns seem somehow *out of time* after
considering the breadth of data that corporations like Google and
Facebook get since a long time; on the other hand, it's so much right
that we discuss about this, and possibly also draw conclusions about
limiting the data we allow companies to gather about us.

This post, anyway, is about a technical issue: how does the App figure
out that you got too close to someone else?

# A little model

All Apps I heard about leverage Bluetooth to figure out the distance.
Rightly so, I daresay: it's a technology based on proximity, it's
widespread in a lot of countries, and phones exchange some data that
make inferring close contacts somehow better than guessing.

In the simplified model, we are very un-fuzzy and set a hard threshold
for a contact:

- we estimate the distance between two phones;
- if this distance is below a threshold, a contact is inferred;
  otherwise, no contact is inferred.

## What distance estimation means

Estimating the distance mainly involves some sort of *channel
inversion*. Your phone knows how much power it received, how much was
transmitted (it should be part of the message, as I understand), makes
some magic assumption about how much loss was there and with a
propagation model you have your distance back. Easy, right?

Well, not so fast. There are a *lot* of variables playing in this game,
including the specific position of the two phones by themselves (is it
in the pocket? held in hand? in a purse?) and relative to one another
(antennas propagate differently depending on the direction). So we can
expect that the *magic assumption* will have to be really *magic*.

A usual approach to this extent is to mitigate variations over multiple
measurements in time. You can take averages or be more creative, but at
the end of the day you will always get an evaluation of the distance.

## Inferring contacts

Just saying that one of the measurements was below the threshold might
be a bit too *conservative*. If you rely on spot measurements (i.e.
there's no averaging over time), having a single contact event might be
too little to actually infer that a health check is due and we might
want to count at least $N$ such events before calling it a day.

At the end of the day, anyway, this would be a process that is composed
*over* the basic question of understanding whether a specific
measurement supports the hypothesis of contact or not.


# After this simple exercise for the reader...

So suppose we actually gather a lot of data and want to figure out an
algorithm to extract some info from these data. We can assume that each
data point holds the following basic information:

- whether the data point was taken in a real condition of proximity
  (event $C$ for *contact*) or not (event $D$ for *distancing*). This is
  just a boolean that has some implicit assumptions, e.g. the existence
  of the data point itself (so the two phones were close enough to
  gather it);
- the outcome of the distance estimation process, that we will assume to
  be classified in one of $M$ possible slots, yielding events $X_1$,
  $X_2$, ..., $X_M$.

We can count all these data points in a table like the following, where
$\Gamma_{X}$ represents the count of how many times class $X$ came out
in a test under *contact* condition $C$, and $\Delta_{X}$ the count of
how many times class $X$ came out in a test under *distancing* condition
$D$.

| | $X_1$ | $X_2$ | ... | $X_M$ |
|:---:|:---:|:---:|:---:|:---:|
| C | $\Gamma_{X_1}$ | $\Gamma_{X_2}$ | ... | $\Gamma_{X_M}$ |
| D | $\Delta_{X_1}$ | $\Delta_{X_2}$ | ... | $\Delta_{X_M}$ |

Let's see what this table can give us.

## Testing conditions

One key point might be to understand in which conditions we did our
measurements campaign. Did we just schedule an equal number of tests in
possible different variants? Or did we just ask people to act naturally,
leave them in an environment for some time while tracking them to attach
a $C$/$D$ information on each data point?

In this latter case, we can use the data to estimate the a-priori
probability $P_C$ that there's a contact or not, like this:

$$P_C = \frac{\sum_X \Gamma_X }{\sum_X(\Gamma_X + \Delta_X)}$$

In lack of this estimation, we will have to resort to *guessing*, e.g.
by assuming $P_C = \frac{1}{2}$.

## Turn to estimated probabilities

We can turn the table into something containing our estimates for the
probability of each event $X$ dividing each count by the sum of all
counts on each line, like this:

| | $X_1$ | $X_2$ | ... | $X_M$ |
|:---:|:---:|:---:|:---:|:---:|
| C | $P_{X_1\|C} = \frac{\Gamma_{X_1} }{\sum_X \Gamma_X}$ | $P_{X_2\|C} = \frac{\Gamma_{X_2} }{\sum_X \Gamma_X}$ | ... | $P_{X_M\|C} = \frac{\Gamma_{X_M} }{\sum_X \Gamma_X}$ |
| D | $P_{X_1\|D} = \frac{\Delta_{X_1} }{\sum_X \Delta_X}$ | $P_{X_2\|D} = \frac{\Delta_{X_2} }{\sum_X \Delta_X}$ | ... | $P_{X_M\|D} = \frac{\Delta_{X_M} }{\sum_X \Delta_X}$ |

Each probability estimation in the table appears as a *conditioned*
probability because it assumes the *condition* in the first column, i.e.
either $C$ or $D$.

## What to do of each X?

At this point it makes sense to ask ourselves: when a measure in
the wild yields a specific class $X$, should we assume that there was a
contact or not? Should we discard the data point, and wait for more?

Having measured event $X$ means that one of the following mutually
exclusive events happened:

- event $CX$, i.e. both event $C$ (contact) and $X$ were true, or
- event $DX$, i.e. both event $D$ (distancing) and $X$ were true.

We *know* it was one of these two - we got $X$, right? Should we bet on
the one with $C$ or the other with $D$? Let's calculate their
probabilities now that we know that $X$ actually happened:

$$P_{C|X} = \frac{P_{CX}}{P_{X}} \\
P_{D|X} = \frac{P_{DX}}{P_{X}}$$

The sum of these two probabilities amounts to 1 because the two events
cover all possibilities (*contact* or *distancing*) when $X$ is true.
It's easy to see that the bigger one is the safer to bet on, so:

- if $P_{C\|X} > P_{D\|X}$ we bet on $C$, otherwise
- if $P_{C\|X} < P_{D\|X}$ we bet on $D$.

And yes, if you're wondering, this is the *maximum likelihood
principle* at work.

The two probabilities in the comparison share the same denominator
($P_{X}$), so we can just as well compare the numerators only, i.e.
$P_{CX}$ and $P_{DX}$. These can be calculated as follows:

$$P_{CX} = P_C \cdot P_{X|C} \\
P_{DX} = (1 - P_C) \cdot P_{X|D}$$

which only involve numbers that we already have (or have assumed).

To summarize, the inference is as follows:

- if $P_C \cdot P_{X\|C} \geq (1 - P_C) \cdot P_{X\|D}$ we infer $C$ from $X$, otherwise
- if $P_C \cdot P_{X\|C} < (1 - P_C) \cdot P_{X\|D}$ we infer $D$ from $X$.

# So... Bayes?

Our initial matrix provides us with the conditional probability of
getting outcome $X$ out of initial conditions $C$ or $D$, while the
maximum likelihood principle requires us to have the *inverse*, i.e. the
conditional probability that event $C$ (or $D$) happened subject to
event $X$ happening.

If you follow the maths, you end up with:

$$P_{C|X} = \frac{P_C \cdot P_{X|C}}{P_X}$$

which is exactly [Bayes's Theorem][].


# Enough!

I guess I abused enough of your patience at this point. Want more? Stay
tuned, we will discuss about the errors we can do!

[Covid-19]: https://en.wikipedia.org/wiki/Coronavirus_disease_2019
[Bayes's Theorem]: https://en.wikipedia.org/wiki/Bayes%27_theorem
