---
title: PWC112 - Climb Stairs
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-05-13 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#112][].
> Enjoy!

# The challenge

> You are given `$n` steps to climb
> 
> Write a script to find out the distinct ways to climb to the top. You
> are allowed to climb either 1 or 2 steps at a time.
>
> **Example**
>     
>     Input: $n = 3
>     Output: 3
>     
>         Option 1: 1 step + 1 step
>         Option 2: 1 step + 2 steps
>         Option 3: 2 steps + 1 step
>     
>     Input: $n = 4
>     Output: 5
>     
>         Option 1: 1 step + 1 step + 1 step + 1 step
>         Option 2: 1 step + 1 step + 2 steps
>         Option 3: 2 steps + 1 step + 1 step
>         Option 4: 1 step + 2 steps + 1 step
>         Option 5: 2 steps + 2 steps

# The questions

I remember a story about a child - aged about 10 around year 1180 -
called Leonardo that was often sent to buy some bread, and had to climb
some stairs every day to go back home. He decided that each day he
wanted to take a different pattern, either 1 or 2 steps at a time, and
wanted to figure out how many different ways he could do this before
having to repeat a climbing pattern.

So my question is... *is this somehow related to his problem*? You know,
I have [the blessing of forgetting][The blessing of forgetting]...

# The solution

Algorithm first:

- **F**or each element, you can take 1 step or 2, but only
- **I**f there are 2 steps or more,
- **B**ecause 1 step has 1 allowed move only.
- **O**n each alternative, you just sum recurrently,
- **N**either choice being the preferred.
- **A**ll you have to do is
- **C**ontinue along the
- **C**ourse down to no steps left.
- **I** guess we're ready now!

[It reminds me of something...][The blessing of forgetting]

It seems that Leonardo had to climb $42$ steps to come back home from
the bakery, and he calculated that it would take $433494437$ days to be
forced again on the same pattern... which is more than one million
years. Enough!

> This also seems to be one of the first cases of [off-by-one error][]
> but [it was not the child's fault][no-fault]...

The solution can be found [here][].


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#112]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-112/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-112/#TASK2
[Perl]: https://www.perl.org/
[The blessing of forgetting]: {{ '/2020/12/03/the-blessing-of-forgetting/' | prepend: site.baseurl }}
[off-by-one error]: https://en.wikipedia.org/wiki/Off-by-one_error
[here]: https://github.com/manwar/perlweeklychallenge-club/tree/master/challenge-112/polettix/perl/ch-1.pl
[no-fault]: https://upload.wikimedia.org/wikipedia/commons/0/04/Liber_abbaci_magliab_f124r.jpg
