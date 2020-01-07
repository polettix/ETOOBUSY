---
title: The extended Euclid's algorithm
type: post
tags: [ perl, algorithm, maths, cglib ]
comment: true
date: 2020-01-08 08:00:00
mathjax: true
published: false
---

**TL;DR**

> Sometimes you need to find out the Greatest Common Divisor of two
> integers.. [Euclid's algorithm][euclid-wiki] is your friend. Sometimes you
> need slightly more... the [extended Euclid's algorithm][eeuclid-wiki] can
> help too!

A few days ago [Julia Evans][] posted [a tweet about Euclid's
algorithm][je-euclid-tweet], linking to a video about it. While I highly
appreciate her work, and wholeheartedly encourage everyone to look at it, in
this specific case I didn't go through the whole 15 minutes explanation in
the video because... well, I already know Euclid's algorithm for finding the
greatest common divisor of two integers. OK I'm cheating, I know what it is
for and [where to find about it][euclid-wiki].

So that should be the end of the story, right? Wrong.

## Six Lines of Code

The first thing that popped to my eyes is that the implementation was going
to be *six lines of code* long. It seemed a bit too much (didn't know the
language to be honest), considering that it can be as low as five when done
in Perl without signatures and with the sub closing brace on its own line.
See the implementation at the end if you don't believe me.

Then I looked at the code:

```python
1  def gcf(a, b):
2      print(f"gcf({a},{b})")
3      if a < b:
4          return gcf(b, a)
5      if a % b == 0:
6          return b
7      return gcf(b, a % b)
```

Well, first observation is that it's seven lines 😁. To be fair, the `print`
at line 2 is actually only there to show what's going on and can be removed
in "the real world".

Jokes apart, lines 3 and 4 are not really necessary. Sure, the algorithm
"works" by taking the remainder of the greater number in a division by the
smaller one, but if `a` is smaller than `b`:

- `a % b` is just `a`;
- if `a` is zero then the greater common divisor is indeed `b` and lines 5-6
  work fine;
- otherwise, line 7 becomes the same as `return gcf(b, a)` i.e. line 4.

I'm not particularly fond of recursion-based solutions in general, but it's
totally my bias because I usually program in Perl and there's no
tail-recursion optimization there (that I know of, at least). No clue about
Python.

In this case, though, I think that the recursive solution is perfect to
explain the algorithm.


## The extended Euclid's algorithm

[Julia's video][video] touches upon a generalization of the algorithm that
is applied over polynomials, so you should definitely watch the video to get
the gist of it. Here, I'd like to elaborate a bit more on an evolution
towards a different direction.

The [extended Euclid's algoritm][eeuclid-wiki] computes the greater common
divisor *and* something more within the same complexity bounds. Yes, it has
a bigger multiplicative constant 😅. In particular, it is capable of
calculating the coefficients $x$ and $y$ of the [Bézout's identity][bezout]:

$$a \cdot x + b \cdot y = gcd(a, b)$$

Why should we care?

Sometimes we might want to do operations modulo some prime $a$ and find the
inverse of $b < a$ in the field $\mathbb{Z}_a$. The greatest commond divisor between
them is 1 by definition ($a$ is prime!) so the identity becomes:

$$a \cdot x + b \cdot y = 1$$

Going modulo $a$ simply yields:

$$b \cdot y = 1\ (mod\ a)$$

i.e. $y$ from the algorithm is the inverse of $b$ in $\mathbb{Z}_a$. Yay!

## The two algorithms, in Perl

The two algorithms above, written in Perl:

<script src="https://gitlab.com/polettix/notechs/snippets/1927534.js"></script>

In case [GitLab][] does not work, you can find also a [local
version][code-local].

As promised, the [basic algorithm][euclid-wiki] is 5 lines long, including
the input parameters unwrapping line and the closing brace - otherwise it
would be 2 😁.

The [extended algorithm][eeuclid-wiki] is more or less a direct
implementation of what explained in the Wikipedia page, apart from taking
the stylistic choice to change some variables' names. Translating the code
to lesser programming languages should be easy 😁.

Both implementations are iterative, which helps keeping the number of
function calls to a minimum and avoid bloating `perl`'s stack.

These functions are part of [cglib-perl][], my library of copy-and-paste
functions for [CodinGame][].

## So long!

Nothing much to wrap up this time, only a suggestion: if you don't know
[Julia Evans][] and her [programming zines][zines] you SHOULD definitely
check them out because they are amazing!

[euclid-wiki]: https://en.wikipedia.org/wiki/Euclidean_algorithm
[eeuclid-wiki]: https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
[Julia Evans]: https://jvns.ca/
[je-euclid-tweet]: https://twitter.com/b0rk/status/1212490150254694400?s=20
[code-local]: {{ '/assets/code/egcd.pl' | prepend: site.baseurl | prepend: site.url }}
[bezout]: https://en.wikipedia.org/wiki/B%C3%A9zout%27s_identity
[zines]: https://wizardzines.com/
[GitLab]: https://www.gitlab.com/
[video]: https://www.youtube.com/watch?v=WIbbd_usHo8
[cglib-perl]: https://github.com/polettix/cglib-perl
[CodinGame]: https://www.codingame.com/
