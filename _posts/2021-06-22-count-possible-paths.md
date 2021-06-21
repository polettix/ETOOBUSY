---
title: Count Possible Paths
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-06-22 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> What [TASK #2][] from the [Perl Weekly Challenge][] [#117][] could
> (well... SHOULD) have been...

Fellow participants to the [Perl Weekly Challenge][], I have discovered
a shocking secret.

We were all tricked. By none other than... well, *you know*.

Conspiracy theory circles knew this since ages: the [Find Possible
Paths][TASK #2] challenge was supposed to require us *count* how many
different ways to go from the top to the bottom-right, not to
*enumerate* them! Alas, nobody listened to them.

I guess that, were the original challenge published instead:

- I would have lost the occasion to inflict to my blog's readers a very
  long post on the solution, namely [PWC117 - Find Possible Paths][].
  You can't reclaim your time back now!
- Most would have probably run into the [Schröder number][sn] and
  taken advantage of the [Recurrence relation][] (thanks to [Some
  explicit and recursive formulas of the large and little Schröder
  numbers][article]):

$$
S_0 = 1 \\
S_1 = 2 \\
S_n = 3S_{n - 1} + \sum_{k = 1}^{n - 2}S_{k}S_{n - k - 1}
$$

This can be (*could have been?*) coded in [Raku][] like this:

```raku
#!/usr/bin/env raku
use v6;
sub sn (Int:D $N where * > 0) {
   state $sns = [1, 2];
   while $N > $sns.end {
      my $n = $sns.elems;
      $sns.push: [+] 3 * $sns[*-1],
         (1 .. $n - 2).map({$sns[$_] * $sns[$n - $_ - 1]}).Slip;
   }
   return $sns[$N];
}

put $_, ' -> ', sn($_) for 1 .. 20;
```

I start to get the gist of it... *except* for `flat` and when to use
`Slip`, which still trick me almost every time 🙄

Well... there we are at the end. **Now you know!**

[PWC117 - Find Possible Paths]: {{ '/2021/06/17/pwc117-find-possible-paths' | prepend: site.baseurl }}
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#117]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-117/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-117/#TASK2
[sn]: https://en.wikipedia.org/wiki/Schr%C3%B6der_number
[Recurrence relation]: https://en.wikipedia.org/wiki/Schr%C3%B6der_number#Recurrence_relation
[article]: https://www.sciencedirect.com/science/article/pii/S1319516616300184?via%3Dihub
[Raku]: https://raku.org/
