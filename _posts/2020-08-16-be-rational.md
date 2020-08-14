---
title: Be Rational
type: post
tags: [ maths ]
comment: true
date: 2020-08-16 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Rational numbers are *compact* and might prove better for doing a lot
> of stuff.

When dealing with numbers with computers, we always have to keep in mind
that there is so much we can do. By default.

As an example, a fantastic number like $\pi$ cannot be represented easily
in any base, neither base-10 nor base-2 or any power of 2. Considering
that numbers are represented by finite strings of bits (or decimal
digits on a piece of paper)... you can only get so much.

As an example, most people I know usually truncate $\pi$ to $3.14$. A few
more, I think, go to $3.14159$, me included.

On the other hand, if you have to remember 6 decimal digits overall,
it's probably better to remember $\frac{355}{113}$, because it gets you
one digit more (with the rounding, both $\pi$ and that fraction yield
$3.141593$).

The fun thing with rational numbers is that they are *compact*. Even if
a *lot* of numbers are not rational, they have this interesting
property that you can get as close as you finitely want to any of them
with a rational representation.

Not sure about it? Let's see an example with $\pi$ itself.

We start with two fractions that are below and above $\pi$:

$$
B_1 = \frac{3}{1} \\
A_1 = \frac{4}{1} \\
\epsilon_1 < \frac{A_1 - B_1}{2} = \frac{1}{2}
$$

The first one is closer to $\pi$ so this will be our starting
approximation. The error we are doing by choosing these two values is
less than $\frac{1}{2}$, i.e. the distance between our starting
fractions. (It cannot be *equal* to $\frac{1}{2}$ because $\pi$ is
irrational!).

Now let's consider the mid-point between our starting fractions:

$$
M_1 = \frac{A_1 + B_1}{2} > \pi
$$

It's still a rational number, and as it comes it's better than $A_0$
because it's closer to $\pi$. So we can build a second iteration like
this:

$$
B_2 = \frac{3}{1} \\
A_2 = \frac{7}{2} \\
\epsilon_2 = \frac{1}{4} \\
M_2 = \frac{13}{4} > \pi
$$

Our initial rational approximation still wins, but now we know that the
error we are doing must be less than $\epsilon_2 = 0.25$. As before, we
can use $M_2$ to get a better upper rational bound and get to the second
iteration:

$$
B_3 = \frac{3}{1} \\
A_3 = \frac{13}{4} \\
\epsilon_3 = \frac{1}{8} \\
M_3 = \frac{25}{8} < \pi
$$

Now we have two considerations:

- the upper bound for the error is always halving, because we are always
  cutting an interval in half
- this new value $M_3$ is lower than $\pi$, so we will update the lower
  rational bound instead of the upper one.

At this point, the algorithm is simple:

- at iteration $k$, calculate

$$
\epsilon_k = \frac{1}{2^k} \\
M_k = \frac{A_k + B_k}{2}
$$

- if $M_k < \pi$, then the boundary values for iteration $k + 1$ will
  be:

$$
A_{k+1} = M_k \\
B_{k+1} = B_k
$$

- otherwise:

$$
A_{k+1} = A_k \\
B_{k+1} = M_k
$$

This is it. If you fix the maximum finite error $\epsilon$ that you are
willing to accept, you can then iterate until $\epsilon_k$ is lower
than, or equal to this value, and you're done.

Now... I'm not saying that these values will be somehow *optimal* in
terms of how compact the representation will be in terms of digits, just
that you can get as close as you finitely want.

Cheers!
