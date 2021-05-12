---
title: Complexity ramblings
type: post
tags: [ algorithm ]
comment: true
date: 2021-05-14 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> A few totally-not authoritative notes on evaluating the complexity of
> an algorithm.

[Mohammad Sajid Anwar][manwar] expressed a couple of times doubts about
how to calculate the *complexity* of an algorithm. I hope these few
notes might be of help, without being wrong.

In a nutshell, calculating the complexity of an algorithm is about
evaluating how much resources it takes to perform its workings. As
algorithms usually operate on data, this evaluation is usually related
to how much data there is.

# Resources: time and space

The two main resources that are usually considered are *time* and
*space* (usually in terms of memory).

Sometimes algorithms can trade one for another. As an example, if we
have a lot of memory we might adopt an algorithm that consumes a lot of
space but gives us better times. On the other hand, if memory is a
scarce resource we might compensate by *doing more* and taking more
time.

As an example, consider the calculation of the $n$-th Fibonacci number.
We might keep a very long list of them, and just take the item from the
list when we need it, or we might calculate it on the spot. The first
approach is faster, the second approach uses a low amount of memory.

Normally we talk about *time complexity*, but considering *space
complexity* is always advisable too.

# Let's start simple, and talk granularity

Let's take a simple program to write out stuff from the input:

```perl
while (<>) { print }
```

This reads a line, writes a line, reads a line, ...

Reading a line means reading all characters up to the end of the line.
So we can say that we will do this `read` operation for each character.
Writing has a similar consideration, so we do a `write` operator for
each character too.

In memory terms, how much do we need? If our file is a single, long
line... then our *space complexity* scales like the file size. You have
a 1 MB file with one line only? You will need about 1 MB RAM. Your file
is 100 MB? You might need 100 MB RAM in the worst case where there's
only a single line.

Of course not all inputs have one, single line. So the estimation above
is the *worst case*, but it also makes sense to consider the *average
case*, or even the *best case*. This is why we read about them. In a
normal text file where the author wraps lines at about 80 characters,
we will need about 80 characters of buffer to do the `read`/`write`
cycles, so much less than the worst case.

It might also happen that we don't really mind about individual
characters, especially if our lines do not deviate too much (or too
often) from the average. At this point we might simplify the problem
and just reason in terms of "lines" instead of "characters". Hence,
instead of saying:

- read characters up to a newline or the end of file
- write all characters read in the previous line

we might "simplify" like this:

- read one line
- write one line.

Hence, we have one `read` and one `write` operation for each line. The
more the lines, the more stuff we will have to do.

Of course, the `read` and `write` operations are not *simpler* than
before. It's just that we're switching gears, and we are considering
*lines* as our granularity level, instead of individual characters.
Whether this makes sense or not depends on the problem and... on us.

We touched upon the *space complexity*, and we know that the average
space needed is that to hold an average line, with the worst case being
the full file size. If we are dealing with "normal" text files, we can
just say that the *space complexity* is constant, because - well - a
memory allocation that is about X character long should be fine.

What about *time complexity*? Well, this is probably simpler, because we
have to do one read and one write operation for each character, or for
each line (depending on the chosen granularity level). Hence, whatever
we put it, the complexity increases *linearly* with the input. Do we
have 1 MB of file? It will take this long. Is it a 100 MB file? It will
take about 100 times more.

Except when it does not, because maybe reading X bytes all together
takes exactly the same time as reading only one, thanks to optimizations
in the memory transfer routines. But let's keep it simple!

# Let's go detailed

If we have an estimation of how much time an operation takes, then we
can make the calculation quite exact. Let's say that a `read` operation
on a line takes 1 unit of time, while a `write` takes 2 units of time;
in this case, for a file that is $N$ long, we have:

- $N$ units of time for reading
- $2 \cdot N$ units of time for writing
- $0.01 \cdot N$ units of time for checks, etc

The one about loop checks is an estimation, of course; it might be
different. Hence, we have that the total amount of *time resources*
would be:

$$T = N + 2 \cdot N + 0.01 \cdot N \\
T = 3.01 \cdot N$$

# Another example

Let's now consider a simple sorting algorithm, [bubble sort][]
(pseudo-algorithm taken from Wikipedia):

```
procedure bubbleSort(A : list of sortable items)
    n := length(A)
    repeat
        swapped := false
        for i := 1 to n-1 inclusive do
            /* if this pair is out of order */
            if A[i-1] > A[i] then
                /* swap them and remember something changed */
                swap(A[i-1], A[i])
                swapped := true
            end if
        end for
    until not swapped
end procedure
```

In the best case, we have a single sweep but no swapping happens, which
means that after the iteration from $1$ to $n - 1$ the algorithm will
exit. Hence, the *best case* has a *time complexity*  equal to:

$$T = (n - 1)$$

if a single comparison takes one unit of time. On the other hand, the
*worst case* would require us to go through the whole list multiple
times, making a lot of swap operations. The amount of operations would
be this:

$$
T = n \cdot (n - 1) + 4 \cdot \frac{(n - 1)(n - 2)}{2}\\
T = n^2 - n + 2n^2 - 6n + 4 \\
T = 3n^2 - 7n + 4
$$

assuming, of course, that a `swap` operation takes $4$ units of time. Am
I throwing numbers? Yes I am.

But wait! there's a `length` operation at the beginning... if we have to
count all items, the time will be proportional to the amount of items
$n$, let's assume it takes $0.5$ units of time for each count operation:

$$
T = 0.5 n + 3n^2 - 7n + 4 \\
T = 3n^2 -6.5n + 4
$$

The interesting thing is that there is a *quadratic* term and a
*linear* term, in addition to a constant.

# Making things simpler

Let's suppose that we have two algorithms, with the following
estimations:

$$
T_1 = 3n^2 + n + 10 \\
T_2 = 800n
$$

Which of the two is better? Well... of course *it depends*. For little
values of $n$, the first one clearly wins, On the other hand, as $n$
grows, the first algorithm grows faster than the second one, up to the
point where its resource requirements overcomes those of the second one.

This is where the concept of *asymptoticity* kicks in. We figure that
our inputs will be larger and larger, hence we want algorithms that can
address larger and larger inputs without requiring too many resources.

For this reason, we usually keep only the fastest growing term in the
equation. What makes the difference and makes $T_1$ *worse* than $T_2$
for large inputs is the square term. Hence, we neglect all other terms
and simplify the two estimations like this:

$$
T'_1 = 3n^2 \\
T'_2 = 800 n
$$

Another thing that is usually neglected are multiplicative constants. I
always failed to fully get this point, but it helps us get a gist of how
an algorithm scales without too many details. This leads us to the
so-called Big-O notation:

$$
C_1 = O(n^2) \\
C_2 = O(n)
$$

So there it is - this is a representation of how fast the resources
requirements grows. At this point it's easy to say that, for bigger and
bigger inputs, the second algorithm is definitely the way to go.

This procedure applies both to the *time* and to the *space*
estimations. Saying that an algorithm goes like $O(n^3)$ *space*-wise
means that we can expect that for an input that is $n$ long, we will
need an amount of memory that grows like $n^3$, so it's better than
$n^4$ but definitely worse than a linear growth.

# Doing quick estimations

To quickly estimate the complexity of an algorithm, we usually have to
look for loops.

Do we act upon each item a few times? Then it's $O(n)$. Do we have two
nested loops to compare each item in an array with a significant portion
of the array itself? Then it's $O(n^2)$. Do we want to evaluate a
tri-dimensional function over $n$ points on each dimension? Then we
will have to calculate $n^3$ values, for a complexity of $O(n^3)$. You
get the idea.

Sometimes we don't even have to act upon each item. As an example, when
we have an array of $n$ items, and we already know that it is sorted,
then we can use a *binary search* and complete the search in *no more*
than about $log(n) + 1$ operations. So... we have $O(log(n))$, because
the $log(n)$ part grows with $n$ and the constant $1$ does not, so we
ignore it and only keep the logarithm.

# Conclusions

Here we are, practical considerations and a whole load of stuff to read
about what Big-O means, what Little-o means, what Theta and Omega are
for... [Intrigued][]?!?

[manwar]: http://www.manwar.org/
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[bubble sort]: https://en.wikipedia.org/wiki/Bubble_sort
[Intrigued]: https://cathyatseneca.gitbooks.io/data-structures-and-algorithms/content/analysis/notations.html
