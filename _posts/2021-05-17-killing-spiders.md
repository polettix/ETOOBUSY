---
title: 'Killing spiders - a fresh look on Chowla Numbers'
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-05-17 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Don't burn the house to kill a spider.

In previous post [PWC109 - Chowla Numbers][] I gave a *very inefficient*
solution to the challenge:

```perl
sub gcd { my ($A, $B) = @_; ($A, $B) = ($B % $A, $A) while $A; return $B }

sub chowla_number ($n) { sum(grep { gcd($n, $_) == $_ } 2 .. $n - 1) // 0 }
```

Well, it was *more* inefficient than I was thinking at the time. And I
am lucky that `Colin Crain` reviews all the submissions and provides
fruitful comments on the solutions ([Colin Crain › Perl Weekly Review #109][]).

Now... emojis are me, reading through the post and... taking action:


> The most basic way to determine whether a number is a divisor of
> another number is to try the division and see it there is any
> remainder.

🧐  💪 👍

> [...] Flavio has provided us with something completely different:
> using a greatest common divisor routine to vet the divisor candidates.

🤭  😱 🤯

> I find this somewhat analogous to burning down the house to kill a
> spider, but it gets the job done and certainly made me think.

🙄 😂

```perl
sub chowla_number ($n) { sum(grep { !($n % $_) } 2 .. $n - 1) // 0 }
```

🤗

So there you have it: **feedback is key**! Thanks Colin 😄

[Colin Crain › Perl Weekly Review #109]: https://perlweeklychallenge.org/blog/review-challenge-109/
[PWC109 - Chowla Numbers]: {{ '/2021/04/21/pwc109-chowla-numbers/' | prepend: site.baseurl }}
