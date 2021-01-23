---
title: 'AoC 2016/19 - Dynamic Josephus'
type: post
tags: [ advent of code, coding, perl, algorithm, AoC 2016-19 ]
comment: true
date: 2021-01-26 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 19][p19] from [2016][aoc2016]:
> using [dynamic programming][] to attack the [Josephus problem][]
> variant described in [Aoc2016/19 - Halving Josephus][].
> This is a series of posts, [click here][series] to list them all!

[series]: {{ '/tagged#aoc-2016-19' | prepend: site.baseurl }}

I was very happy to get past [puzzle 19][p19] from the [2016
edition][aoc2016] of [Advent of Code][], but let's admit two facts:

- I didn't *demonstrate* that the *heuristic* is actually a *rule*;
- This wouldn't help in some other general case.

I mean... what if I didn't spot the heuristic at all? Would I have been
stuck with the *brute force* approach?

Well... we have other cards to play.

# A recurrent situation

We are actually in a... *recurrent* situation where knowing the solution
to the problem for $N$ items might help us find out a solution for $N +
1$ items somehow easily (i.e. without having to actually place $N + 1$
elves and simulate the full game).

So let's say we know the solution for $N$. It's $i$.

Now, let's consider what we would do to solve the $N + 1$ case. Let's
first place all of them:

```
1 2 3 ... (k-3) (k-2) (k-1) k (k+1) (k+2) ... (N-3) (N-2) (N-1) N (N+1)
```

Here we are highlighting position $k$, which is the position that we
will have to eliminate in this condition. We already know how to find
$k$, because of the rules about the odd and even values of $N$.

Now, our first step is to eliminate element $k$, so we're left with:

```
1 2 3 ... (k-3) (k-2) (k-1) (k+1) (k+2) ... (N-3) (N-2) (N-1) N (N+1)
```

At this point, we would have to move to the following item, that is the
same as taking the initial item and move it to the end, like this:

```
2 3 ... (k-3) (k-2) (k-1) (k+1) (k+2) ... (N-3) (N-2) (N-1) N (N+1) 1
```

Now, *theoretically*, our *brute force* approach would ask us to just
repeat the same steps with this new array of elements.

Array of $N$ elements.

Wait. A. Minute.

We already know what the solution is to this case: it's $i$. Well no,
it's the *element* that is at *position $i$*. Let's write the positions
and the values then:

```
i> 1 2 3 ... (k-3) (k-2) (k-1) k     (k+1) ... (N-3) (N-2) (N-1) N
v> 2 3 4 ... (k-2) (k-1) (k+1) (k+2) (k+3) ... (N-2) (N-1) N     1
```

We can observe that:

* if $i$ was less than $k$, then it is only transformed into $i + 1$
  after we "move on" to the next item, i.e. take the first item and put
  it in the final position;

- if $i$ was greater than, or equal to, $k$, then it gets shifted *two*
  positions ahead, one due to the elimination of $k$ itself, the other
  one for "moving on" like in the previous bullet;

- the only special case is when $i = N$, because in this case we reset
  back to $1$.

Hence, if we call $E(n)$ the winning elf in a game of $n$ elves, we have
the following recursive relation:

$$
E(n) = \begin{cases}
E(n-1) + 1, & \text{if $E(n-1) < \lfloor\frac{n}{2}\rfloor$ }\\
E(n-1) + 2, & \text{if $\lfloor\frac{n}{2}\rfloor \le E(n-1) < n - 1$ } \\
1,        & \text{if $E(n-1) = n - 1$ }
\end{cases}
$$

# A dynamic algorithm

To solve for $N$, then, we need the solution for $N - 1$, hence we need
the solution for $N - 2$ and so on up to... $N = 2$, where we already
know that the solution is $1$.

Hence, an algorithm to solve for $N$ might be:

- start from $n = 2$ and $E(2) = 1$
- make a loop where $n$ is increased by one at each iteration and the
  corresponding value $E(n)$ is calculated from the value of the
  previous iteration;
- When $n$ lands on $N$... we're done!

This can be coded as follows:

```perl
sub josephus_part2_dynamic ($N) {
   my $i = 1;
   my $n = 2;
   my $k = 1;
   while ($n < $N) {
      ++$n;
      $k = int($n / 2);
      $i = $i < $k     ? $i + 1
         : $i < $n - 1 ? $i + 2
         :                 1;
   }
   return $i;
}
```

This approach as a complexity that is $O(n)$, as opposed to $O(1)$ of
the *heuristic*... but it's anyway a more general one, because it only
requires us to figure out the mapping of the different indexes from an
iteration to the following.

# Conclusion

This was an interesting ride! In particular, it gave me the opportunity
to go a bit more in depth with the [dynamic programming][] paradigm...
and learn something more on the way 😄



[p19]: https://adventofcode.com/2016/day/19
[aoc2016]: https://adventofcode.com/2016/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
[dynamic programming]: https://en.wikipedia.org/wiki/Dynamic_programming
[Josephus problem]: https://en.wikipedia.org/wiki/Josephus_problem
[Aoc2016/19 - Halving Josephus]: {{ '/2021/01/25/halving-josephus/' | prepend: site.baseurl }}
