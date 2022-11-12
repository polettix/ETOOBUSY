---
title: A D4 from a D6 - squeeze more
type: post
tags: [ maths, probabilities ]
series: 'Transforming Randomization'
comment: true
date: 2020-05-13 07:00:00 +0200
published: true
mathjax: true
---

**TL;DR**

> Where we squeeze even more from a D6 to obtain a D4.

In [A D4 from a D6, with time guarantees][] we looked at an alternative
way of generating a D4 from a D6, a method that always provides us with
an answer with exactly two D6 rolls. Although working, that solution
leaves some *bad taste in the mouth* because always rolling two *more
expressive* dice to get a single *less expressive* one seems somehow
overkill.

**CAVEAT** I didn't formally study most of this stuff, but I had some
exposure. I might be saying things that are not 100% correct, at least
from a terminology point of view.

# What's more/less expressive to start with?

Let's start from the claim that a D6 is *more expressive* than a D4. In
what sense?

The outcome of a D6 is one in 6 possible, while in a D4 it is one in 4.
So, in a sense, the outcome of the D6 carries more *information* because
there are more possible configurations that it can end with. To bring
this to an extreme, a die with one single face only would not carry any
information at all, because we already know what the outcome will be.

This reflects in the fact that the rejection method... *rejects*
outcomes `5` and `6` from the D6 because they are a *surplus* for a D4.
Later on we will see a formal representation for this intuition.

# Let's start doing better

Question: can `5` and `6` be used when they come out of a roll? Just
take a look at the following table before reading on:

| First | Second | D4 outcome |
| :---: | :---:  | :---:      |
|   5   |   5    |   1        |
|   5   |   6    |   2        |
|   6   |   5    |   3        |
|   6   |   6    |   4        |

Let's then consider  the following algorithm:

1. allocate a memory cell to hold one of three possible values:
  - empty (initial value)
  - `5`
  - `6`
2. roll a D6
3. if the outcome is `1` through `4`
  - keep it as the outcome of a D4
4. otherwise, if the cell is empty
  - save the outcome in the cell
5. otherwise
  - use the cell contents and the new outcome to generate a D4 from the
    table above
  - set the cell to empty
6. go to step 2 for the next roll

It is easy to see that the algorithm above gives out the outcome of a
D4, on average, in 5 rolls out of 6 and, in any case, it will take it no
more than two rolls to give out one D4. Hence, we get efficiency *and* a
time guarantee.

Still this is not entirely satisfactory. The D6 is more *expressive*
than the D4, right? How come that we get a D4 only 5 times out of 6
rolls, on average? Shouldn't we get *more*?!?

# Help from Information Theory

[Claude Shannon][] formalized in 1948 [A Mathematical Theory of
Communication][] and introduced the concept of *entropy* for the
possible outcomes of an event, defined like this:

$$H = - \sum_{i = 1}^n p_i log p_i$$

In the following, we will assume that logarithms are evaluated in base 2.
In our cases we have:

$$H_{D6} = - 6 \frac{1}{6} log \frac{1}{6} = log 6 \approx 2.58$$

$$H_{D4} = - 4 \frac{1}{4} log \frac{1}{4} = log 4 = 2$$

In other terms, encoding the outputs of a fair D6 requires us more
*bits* than encoding the outputs of a fair D4, hence a D6 is more
*expressive*.

Our main question now is: can we put that $0.58$ of difference to work?

Let's roll two *distinct* D6 dice, where *distinct* means that we have a
way to put them in order independetly of the value they take (e.g. they
have different colors and we decide beforehand how to sort them). We can
then arrange them according to the 36 possible and equiprobable
outcomes:

```
(1, 1) (1, 2) (1, 3) (1, 4) (1, 5) (1, 6)
(2, 1) (2, 2) (2, 3) (2, 4) (2, 5) (2, 6)
(3, 1) (3, 2) (3, 3) (3, 4) (3, 5) (3, 6)
(4, 1) (4, 2) (4, 3) (4, 4) (4, 5) (4, 6)
(5, 1) (5, 2) (5, 3) (5, 4) (5, 5) (5, 6)
(6, 1) (6, 2) (6, 3) (6, 4) (6, 5) (6, 6)
```

Let's rearrange them as follows:

```
(1, 1) (1, 2) (1, 3) (1, 4)
(1, 5) (1, 6) (2, 1) (2, 2)
(2, 3) (2, 4) (2, 5) (2, 6)
(3, 1) (3, 2) (3, 3) (3, 4)

(3, 5) (3, 6) (4, 1) (4, 2)
(4, 3) (4, 4) (4, 5) (4, 6)
(5, 1) (5, 2) (5, 3) (5, 4)
(5, 5) (5, 6) (6, 1) (6, 2)

(6, 3) (6, 4) (6, 5) (6, 6)
```

i.e. two groups with 16 outcomes each, plus one group with 4 outcomes.

The first group gives us two D4 rolls, just take one from the row and
another one from the column.

The second group gives us two D4 rolls, for the same reason.

Together, they also give out an additional bit of information, namely
"it fell in the first group" or "it fell in the second group". Take it
as the outcome of a fair coin, which we can save for future use as long
as we have the outcome of another fair coin.

The last group gives out a D4, exactly.

Again, we have a time bound because it will take *at most* two rolls to
get one D4, much like before. But we have much more now:

- in $\frac{32}{36} = \frac{8}{9}$ cases, on average, we get $2.5$ D4
  outcomes;
- in $\frac{4}{36} = \frac{1}{9}$ cases, on average, we get $1$ D4 only

so, in total, the expected number of D4 outcomes we will get is:

$$\frac{8 \cdot 2.5 + 1 \cdot 1}{9} = \frac{21}{9} \approx 2.33$$

i.e. *more* than just two D4 dice. Now we start to reason!

# Even better?

In the previous section, we saw that 8 times out of 9 we get $2.5$ D4
dice out (i.e. 2 D4 and a coin). To make the most out of the *half die*
we should roll another pair of D6, right and use those coints, right?

It turns out that considering the *collective* outcome of the four D6
rolls gives us a better performance. Assuming the dice have a
pre-determined order there are $6^4 = 1296$ possible outcomes, that we
can arrange like follows:

- the first $1024$ provide us with 5 D4 outcomes. To see it, note that
  it takes exactly 10 bits to represent all numbers from 1 to 1024
  included; divide these 10 bits in 5 pairs of 2 bits each, and they
  will give you 5 D4 dice;
- the following $256$ values can be turned into 8 bits, i.e. 4 D4 dice;
- the remaining 16 bits provide us 2 D4 dice.

Hence, on average, we get:

$$\frac{1024 \cdot 5 + 256 \cdot 4 + 16 \cdot 2}{1296} \approx 4.76$$

D4 outcomes for rolling 4 D6 dice. Note that this is better than *just*
doubling the outcomes of rolling 2 D6 dice.

We might roll even more D6 dice and do clever aggregations, but where
can we hope to end up? The ratio has an upper bound given by the inverse
ratio of the two entropies, i.e.:

$$\frac{log 6}{log 4} \approx 1.29$$

So far we got up to $\frac{2.33}{2} \approx 1.16$ with two rolls and
$\frac{4.76}{4} \approx 1.19$ with four, so we definitely have space to
improve, but at the cost of rolling the D6 *a lot* of times.

Which, time and again, will make your friends wonder why you didn't buy
a D4 in the first place.

[A D4 from a D6, with time guarantees]: {{ '2020/05/12/d6-to-d4-deterministic' | prepend: site.baseurl }}
[Claude Shannon]: https://en.wikipedia.org/wiki/Claude_Shannon
[A Mathematical Theory of Communication]: https://web.archive.org/web/19980715013250/http://cm.bell-labs.com/cm/ms/what/shannonday/shannon1948.pdf
