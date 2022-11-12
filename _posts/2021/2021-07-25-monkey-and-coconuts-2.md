---
title: More on monkeys and coconuts
type: post
tags: [ puzzle ]
comment: true
date: 2021-07-25 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Some add-ons to latest post [Brute forcing "The monkey and the
> coconuts"][mc1].

In last post we saw that we could reduce the *brute force* attack first
from 15625 candidates down to 1024, then down to one-fourth i.e. 256.
This is already a factor of about 60, but of course we can do more.

In particular, for the *basic* puzzle we observed that the last division
assigns $L$ coconuts to each sailor, where $L$ must be of the form $L =
4k - 1$.

So why stop here then?

Let's rename $L$ to $L_0$, and let's move on to the next step in the
ladder, i.e. the amount of coconuts that are taken by the *last* sailor
during the *preliminar divisions* that happen through the night. We will
call this value $L_1$ 🙄

On the one hand, in the *basic* puzzle we can easily conclude that $L_1$
must have the same shape as $L_0$, i.e. be of the form:

$$
L_1 = 4 k_1 - 1
$$

On the other hand, we also know the exact relation between $L_0$ and
$L_1$:

$$
L_1 = (5 L_0 + 1)/4 \\
4L_1 = 5 L_0 + 1 \\
5 L_0 = 4 L_1 - 1
$$

Putting these two together we can express $L_0$ in terms of $k_1$, let's
see where we get:

$$
5 L_0 = 4(4 k_1 - 1) - 1 = 16 k_1 - 5
$$

Now we can observe that the left hand side is divisible by 5, so the
right hand side must be divisible by 5 too. As 16 is *not* divisible by
5, then $k_1$ MUST be divisible by 5 itself, i.e.:

$$
5 L_0 = 16 \cdot 5 k - 5 \\
L_0 = 16 k - 1
$$

This last relation is extremely interesting, because it tells us that we
can iterate over *one-sixteenth* of the possible candidates between 1
and 1024, i.e. ranging $1 \leq k \leq 64$. Even better times for a brute
force attack from a human!

Well, the trend for the *basic* puzzle is set anyway... why even stop
here? Doing the same for the following steps in the ladder brings us to
further restrict the range of candidates:

$$
L_2 \rightarrow L_0 = 64 k - 1 \quad 1 \leq k \leq 16 \\
L_3 \rightarrow L_0 = 256 k - 1 \quad 1 \leq k \leq 4 \\
L_4 \rightarrow L_0 = 1024 k - 1 \quad 1 \leq k \leq 1 \\
$$

We don't have to take any further step of course, because there's no
constraint for what comes out of $L_5$.

Wait a minute... the last expression has one single candidate for $k$...
giving $L_0 = 1023$ that is precisely the solution to the puzzle!

Well... time and again some reasoning beats brute force!

> After better reading the page on [The monkey and the coconuts][], it
> turns out that **of course** this approach was already described as a
> **numerical approach**. You can take a look at the page to see how a
> mix of a similar mechanism and some trial-and-error can be applied
> with the **sieve** approach, targeting **Williams**'s puzzle
> alternative.
>
> Although, in this case... **some brute force required**.


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[mc1]: {{ '/2021/07/24/monkey-and-coconuts/' | prepend: site.baseurl }}
[The monkey and the coconuts]: https://en.wikipedia.org/wiki/The_monkey_and_the_coconuts
