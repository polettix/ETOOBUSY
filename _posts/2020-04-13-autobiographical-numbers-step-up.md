---
title: Autobiographical numbers constraints - step up
type: post
tags: [ constraint programming, cglib, perl, algorithm, series:Autobiographical numbers ]
comment: true
date: 2020-04-13 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Where we remove all programming joy from this nice puzzle.

Do you see any pattern?

```shell
$ for N in $(seq 10 20) ; do ./run.sh 04-luckier-sum "$N" ; done
solution => [6,2,1,0,0,0,1,0,0,0]
solution => [7,2,1,0,0,0,0,1,0,0,0]
solution => [8,2,1,0,0,0,0,0,1,0,0,0]
solution => [9,2,1,0,0,0,0,0,0,1,0,0,0]
solution => [10,2,1,0,0,0,0,0,0,0,1,0,0,0]
solution => [11,2,1,0,0,0,0,0,0,0,0,1,0,0,0]
solution => [12,2,1,0,0,0,0,0,0,0,0,0,1,0,0,0]
solution => [13,2,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0]
solution => [14,2,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0]
solution => [15,2,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0]
solution => [16,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0]
```

It *seems* that this would always be a solution, at least for $N$
*sufficiently large*:

- `0` contains value $N - 4$
- `1` contains value $2$
- `2` contains value $1$
- `N-4` contains value $1$
- everything else is $0$.

When $N > 6$, then $N - 4 > 2$ which is the condition in which slot `N-4`
does not overlap with any of the other three slots that have non-zero
values.

Is this *always* a solution for $N > 6$ a.k.a. $N - 4 > 2$? Yes it is:

- `0`, `1`, `2`, and `N-1` are 4 distinct slots, because $N-4>2$;
- these are the only slots holding a value different from $0$;
- all the other slots (i.e. $N - 4$ of all slots) hold value $0$, which is
  consistent with the value at slot `0`;
- value $1$ appears exactly 2 times (in slot `2` and `N-4`), and slot `1`
  contains value $2$;
- value $2$ appears exactly once (in slot `1`), and slot `2` contains value
  $1$;
- value $N-4$ appears exactly once (in slot `0`), and slot `N-4` contains
  value $1$.

So there's no need for complicated searches for $N > 6$: just provide the
solution according to the pattern above.

```perl
sub autobiographical_numbers ($n) {
    my @solution;
    if ($n == 4) {
        @solution = (1, 2, 1, 0); # also good: (2, 0, 2, 0)
    }
    elsif ($n > 6) {
        @solution = (0) x $n;
        @solution[0, 1, 2, $n - 4] = ($n - 4, 2, 1, 1);
    }
    return {solution => [map {+{$_ => 1}} @solution]};
}
```

Find all of this at [stage 5][].

How boring. And yet... are these the *only* solutions?!? E.g. $N = 4$ allows
two different solutions... is it possible elsewhere?!?

# The end of it

Curious about the whole series? Here it is:

- [Autobiographical numbers][]
- [Autobiographical numbers constraints - basic][]
- [Autobiographical numbers constraints - last is zero][]
- [Autobiographical numbers constraints - weighted sum][]
- [Autobiographical numbers constraints - luckier weighted sum][]
- [Autobiographical numbers - step up][]
- [Code repository][repository]

Comments? Please comment below!

[Autobiographical numbers]: {{ '/2020/04/08/autobiographical-numbers/' | prepend: site.baseurl | prepend: site.url }}
[Autobiographical numbers constraints - basic]: {{ '/2020/04/09/autobiographical-numbers-constraints-basic/' | prepend: site.baseurl | prepend: site.url }}
[Autobiographical numbers constraints - last is zero]: {{ '/2020/04/10/autobiographical-numbers-constraints-last-zero/' | prepend: site.baseurl | prepend: site.url }}
[Autobiographical numbers constraints - weighted sum]: {{ '/2020/04/11/autobiographical-numbers-constraints-weighted-sum/' | prepend: site.baseurl | prepend: site.url }}
[Autobiographical numbers constraints - luckier weighted sum]: {{ '/2020/04/12/autobiographical-numbers-constraints-luckier-sum/' | prepend: site.baseurl | prepend: site.url }}
[Autobiographical numbers - step up]: {{ '/2020/04/13/autobiographical-numbers-step-up/' | prepend: site.baseurl | prepend: site.url }}
[repository]: https://gitlab.com/polettix/autobiographical-numbers
[stage 5]: https://gitlab.com/polettix/autobiographical-numbers/-/blob/master/05-boring/autobiographical-numbers.pl
