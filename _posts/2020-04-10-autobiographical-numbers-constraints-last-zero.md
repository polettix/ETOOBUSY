---
title: Autobiographical numbers constraints - last is zero
type: post
tags: [ constraint programming, cglib, perl, algorithm ]
comment: true
date: 2020-04-10 09:35:23 +0200
mathjax: true
published: true
---

**TL;DR**

> Remember [Autobiographical numbers][]? We will go on looking at
> constraints for it!

Let's move on to a more *fixed* and *theoretical* one, i.e. that the last
slot MUST be $0$. Code is in [stage 2][].

# A preliminary note

Let's first note one thing:

> if slot `x` contains the value $y$, then there MUST be at least $x \cdot y$
> slots in the whole array.

Let's see why, assuming that slot `x` contains value $y$:

- by definition, value $x$ is contained in exactly $y$ slots
- assume that `z` slot is one of these $y$ slots, it means that it contains
  value $x$
- as a consequence, there are exactly $x$ slots that contain value $z$
- because there are $y$ such slots, each bearing a different value, then we
  need to accomodate *at least* $x * y$ slots.

The condition is actually stronger than this, as a simple extension of the
reasoning above and observing that each slot can only contain a single
value:

$$ N = \sum_{i = 0}^{N-1} i \cdot v_i$$

where $v_i$ represents the value contained in slot `i`.

# One more thing: N > 3

The autobiographical numbers puzzle can't be solved for $N \leq 3$:

- $N = 0$ means that there is no slot.
- $N = 1$ means that there is only slot `0`. It cannot contain $0$ because
  otherwise it would have to contain $1$ (there would be $1$ value $0$ in
  it, right?!?), and of course it cannot contain $1$ because otherwise it
  would not contain any $0$.
- $N = 2$ means that there are only slots `0` and `1`. It's easy to see that
  no value combination is possible:

  - both slots can only contain $0$ or $1$, because of what we discussed in
    the previous section;
  - slot `0` cannot contain $0$ for the same reasons as the previous case
    where $N = 1$, so it can only contain a $1$ (if anything);
  - `10` is not a solution because there is one $1$ and the slot for `1` is
    $0$
  - `11` is not a solution because there are two values $1$, but slot `1`
    contains a $1$.

- $N = 3$ is equally impossible. Allowed values for quantities are $0$, $1$
  and $2$ because there are only slots `0`, `1` and `2`.
  - We already established that slot `0` cannot contain $0$
  - in the previous section, we saw that slot `2` cannot contain $2$ (it
    would mean that we need to have 4 slots, but we have only three)
  - so we are left with:

```
10* not a solution, the value of slot 1 cannot be less than 1
11* not a solution, the value of slot 1 cannot be less than 2
120 not a solution, slot 1 should be 1
121 not a solution, there is no 0
2*0 not a solution, the value of slot 2 cannot be less than 1
201 not a solution, the value of slot 1 should be 1
211 not a solution, the value of slot 1 should be 2 
22* not a solution, the value of slot 2 should be 2 but it can't
```

Hence, it only makes sense to consider cases where $N > 3$.

# Last slot MUST be 0?

Suppose you have $N$ slots, numbered from `0` to `N-1` and let's focus on
the last slot. Remember also that $N > 3$.

Can it be greater than 1? Let's remember the note in the previous section,
and observe that $ k \cdot (N - 1) $ is greater than $N$ (i.e. the total
number of available slots!) for $k > 1$ and $N > 2$. So, for $N > 3$ (as we
are considering) we MUST have that $k \leq 1$.

Our next question is: can slot `N - 1` actually take value $1$? Well... no
again. If it were true, then it would mean that the value $N - 1$ is written
in some slot, which MUST be one of the first $N - 1$ slots (the last one is
already occupied by the $1$ and we already know that $N - 1 > 1$).

We know that $N - 1$ cannot be written in *any* slot from `2` on, again
because of the constraints discussed in the previous section. Hence, it
could only be either slot `0` or slot `1`.

Can it be slot `0`? No it can't, because we would need to accomodate $N - 1$
slots with $0$ inside, but we only have $N - 2$ left (remember that slot `0`
is occupied by value $N - 1$, and slot `N - 1` is occuped by value $1$, so
they cannot accomodate a $0$ at the same time).

Can it be slot `1`? No again, because if we take the equation in the
previous section, we would end up with *at least* $1 \cdot (N - 1) + (N - 1) \cdot 1
= 2(N - 1) > N$ needed slots, which is impossible.

Let's visualize this latter case explicitly:

```
  0   1   2   3
+---+---+---+---+
| 1 | 3 | 1 | 1 |
+---+---+---+---+

...

  0   1     2   3   4        N-2 N-1 
+---+-----+---+---+---+ ... +---+---+
| 1 | N-1 | 1 | 1 | 1 |     | 1 | 1 |
+---+-----+---+---+---+ ... +---+---+
```

All slots show either $1$ or $N - 1$, and other values are absent. Which is
a violation of the main constraint about the game rule: value $0$ is
supposed to appear once (there is a $1$ in slot `0`) but it does not appear
at all.

Hence, the very last value in a suitable solution MUST be $0$.


# Coding

Now that we know it MUST be $0$, it's easy to code it - we will do this
directly upon initialization.

```perl
 1 sub autobiographical_numbers ($n) {
 2    my $solution = [
 3       map {
 4          +{map { $_ => 1 } 0 .. $n - 2}  # "n-1" is always 0
 5       } 1 .. $n -1
 6    ];
 7    push $solution->@*, {0 => 1};         # "n-1" is always 0
 8    my @constraints = map { main->can('constraint_' . $_) }
 9       qw< basic >;
10    my $state = solve_by_constraints(
11       constraints    => \@constraints,
12       is_done        => \&is_done,
13       search_factory => \&explore,
14       start          => {solution => $solution},
15       logger         => ($ENV{VERBOSE} ? \&printout : undef),
16    );
17 } ## end sub autobiographical_numbers ($n)
```

There are two places where this insight is useful:

- the obvious one is that... the last slot only allows for $0$, which is
  what line 7 is about;
- then, we can also get rid of value $N-1$ from all other slots (line 4, the
  range goes up to $N-2$ for this reason).

# Is it of help?

Let's see how it goes:

```shell
$ time ./run.sh 01-basic/ 30
solution => [26,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0]

real	0m6.449s
user	0m6.404s
sys	0m0.032s

$ time ./run.sh 02-last-is-zero/ 30
solution => [26,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0]

real	0m5.679s
user	0m5.648s
sys	0m0.012s
```

Not bad!

# So long...

Curious about more constraints? By all means wait for new posts!


[Autobiographical numbers]: {{ '/2020/04/08/autobiographical-numbers/' | prepend: site.baseurl | prepend: site.url }}
[stage 2]: https://gitlab.com/polettix/autobiographical-numbers/-/blob/master/02-last-is-zero/autobiographical-numbers.pl
