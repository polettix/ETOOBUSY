---
title: "Some Bayes helps - more"
type: post
tags: [ maths, probabilities ]
comment: true
date: 2020-04-30 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Where you are patient enough to continue on the Bayes rabbit hole.

In last post [Some Bayes helps][] we took a look at how we can use a
campaign of measurements to get a table that helps us understanding how
to infer information from more future measurements.

# (re-)Starting point

We restart from the estimated conditional probabilities table:

| | $X_1$ | $X_2$ | ... | $X_M$ |
|:---:|:---:|:---:|:---:|:---:|
| C | $P_{X_1\|C} = \frac{\Gamma_{X_1} }{\sum_X \Gamma_X}$ | $P_{X_2\|C} = \frac{\Gamma_{X_2} }{\sum_X \Gamma_X}$ | ... | $P_{X_M\|C} = \frac{\Gamma_{X_M} }{\sum_X \Gamma_X}$ |
| D | $P_{X_1\|D} = \frac{\Delta_{X_1} }{\sum_X \Delta_X}$ | $P_{X_2\|D} = \frac{\Delta_{X_2} }{\sum_X \Delta_X}$ | ... | $P_{X_M\|D} = \frac{\Delta_{X_M} }{\sum_X \Delta_X}$ |

Remember that we also have some a-priori estimation of *absolute*
probability of a *contact* $P_C$, and that the maximum likelihood
principle led us to establish the following inference algorithm:

- if $P_C \cdot P_{X\|C} \geq (1 - P_C) \cdot P_{X\|D}$ we infer $C$ from $X$, otherwise
- if $P_C \cdot P_{X\|C} < (1 - P_C) \cdot P_{X\|D}$ we infer $D$ from $X$.

This inference algorithm partitions the set of all measured classes
$X_1 .. X_M$ into two sets:

$$\mathscr{C} = \{X : X \Rightarrow C\} \\
\mathscr{D} = \{X : X \Rightarrow D\}
$$

# Can we be wrong?

You bet we can. The fact itself that a column in our table can have two
non-zero values means that we will be wrong in some cases - the whole
point of the maximum likelihood approach is to try and choose the option
that makes us fail less often.

There are two kind of errors that we can make:

- saying that a contact happened, when it didn't - this is called a
  *false positive*;
- saying that a contact did not happen, when it did - this is called a
  *false negative*.

Each of the possible classes from our measurement will contribute to at
most one of these errors (it might contribute to neither if the column
has one $1$ and one $0$, but this is the real world).

In particular:

- elements in $\mathscr{C}$ all lead to inferring a contact, and can
  thus contribute to *false positives* only;
- elements in $\mathscr{D}$ can only contribute to *false negatives*.

## False positives

Let's start with *false positives*. As we saw, we chose to infer $C$
from event $X$ because this applies:

$$P_C \cdot P_{X|C} \geq (1 - P_C) \cdot P_{X|D}$$

which is equal to say:

$$ P_{C|X} = \frac{P_C \cdot P_{X|C}}{P_X} \geq \frac{(1 - P_C) \cdot P_{X|D}}{P_X} = P_{D|X}$$

This basically means that, when $X$ happens, we will be right in
inferring $C$ with probability $P_{C|X}$, and fail otherwise.

For this reason, the term on the right is exactly our false positive
probability, conditioned to event $X$:

$$P_{fp|X} = P_{D|X}$$

It's easy at this point to calculate the overall probability of a false
positive, adding up all terms that can lead to this kind of error
weighting them with the probability of each event $X$:

$$P_{fp} = \sum_{X \in \mathscr{C}}(P_X \cdot P_{fp|X}) = \sum_{X \in \mathscr{C}}(P_X \cdot P_{D|X}) = \sum_{X \in \mathscr{C}}P_{DX} = \sum_{X \in \mathscr{C}}((1 - P_C) \cdot P_{X|D}) \\
P_{fp} = (1 - P_C) \sum_{X \in \mathscr{C}}P_{X|D}
$$

The summatory takes all items from the table corresponding to the row
for $D$ and to those columns that provide an inference to $C$; this sum
is weighted with the absolute probability of *distancing*, which makes
sense because a false positive means being distanced (which happens with
probability $(1 - P_C)$) but having ended up with classes that we
consider for a *contact*.

## False Negatives

Calculating the probability of *false negatives* is the dual of what we
considered in the previous section, so we end up with:

$$P_{fn} = P_C \sum_{X \in \mathscr{D}}P_{X|C}$$

# Not all wrongs are created equal

As we saw, for each measured event $X$ with non-zero probability of
being associated to $C$ and $D$ (i.e. $X$'s column in the table has both
entries greater than zero) we end up with some probability of doing
errors (respectively false positives and false negatives).

Do we think they are the same? Maybe not.

Just as you would probably pick your umbrella if the wheather forecasts
tell you there's a 40% probability of rain, at the risk of carrying it
unnecessarily most of the times, we might want to be conservative and
prefer false positives over false negatives.

For this reason, we might set a higher limit to the probability of false
negatives, and move all classes that would exceed this limit from
$\mathscr{D}$ to $\mathscr{C}$. This would be against the maximum
likelihood principle and would mean being *more wrong* in average, but
at least it would be our favourite flavor of being wrong.

Note that it's still meaningful to allow for some false negatives,
though: in most cases, bringing this number down to zero would mean that
every Bluetooth exchange is interpreted as a contact, which might not be
economically feasible (e.g. for lack of sufficient testing capabilities).


# Fancier uses?

The mathematical model we ended up with can also be used for a *hybrid*
solution. Many things in life are not black and white, so why should
this be different?

At the basic level, we can consider that measuring event $X$ gives us
two probabilities, i.e. one for inferring a contact ($C$) and one for
inferring correct distancing ($D$). We already saw these two
probabilities, expressed in terms of quantities we have or have assumed:

$$P_{C|X} = \frac{P_C \cdot P_{X|C}}{P_X} = \frac{P_C \cdot P_{X|C}}{P_C \cdot P_{X|C} + (1 - P_C) \cdot P_{X|D}} \\
P_{D|X} = \frac{(1 - P_C) \cdot P_{X|D}}{P_X} = \frac{(1 - P_C) \cdot P_{X|D}}{P_C \cdot P_{X|C} + (1 - P_C) \cdot P_{X|D}}$$

So, if our health testing capabilities are of $K$ tests per day, we
might do like this:

- record all occurrences of every event $X$, without removing any;
- sort them by inverse $P_{C|X}$, i.e. from greater probability of a
  contact to lower ones;
- each day, remove the top $K$ and apply the health test to them.

This would allow prioritizing the most probable contacts, remain within
the limits of the SSN checking capabilities, and decide where to draw
the line of *excessive testing* when there are more available data.

[Some Bayes helps]: {{ '/2020/04/29/some-bayes-helps/' | prepend: site.baseurl | prepend: site.url }}
