---
title: PWC215 - Odd One Out
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-05-04 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#215][]. Enjoy!

# The challenge

> You are given a list of words (alphabetic characters only) of same
> size.
>
> Write a script to remove all words not sorted alphabetically and print
> the number of words in the list that are not alphabetically sorted.
>
> **Example 1**
>
>     Input: @words = ('abc', 'xyz', 'tsu')
>     Output: 1
>
>     The words 'abc' and 'xyz' are sorted and can't be removed.
>     The word 'tsu' is not sorted and hence can be removed.
>
> **Example 2**
>
>     Input: @words = ('rat', 'cab', 'dad')
>     Output: 3
>
>     None of the words in the given list are sorted.
>     Therefore all three needs to be removed.
>
> **Example 3**
>
>     Input: @words = ('x', 'y', 'z')
>     Output: 0

# The questions

**I strongly oppose to the considerations in the second example**: the
`rat` is being discriminated.

Just to nit-pick a bit more:

- we're assuming the latin alphabet without accents and other stuff,
  right?
- two equal words in sequence are considered sorted, right?

I also wonder... why specify that the words are of the same size?

# The solution

We'll keep a *cursor index variable* to point to the latest word that
was in correct order, then move ahead to find the next one that is still
correctly sorted with respect to the cursor. For each of them:

- if sorted correctly, we just advance the cursor
- otherwise, we mark one tick up.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put count-odd-one-out(@args) }

sub count-odd-one-out (@words) {
   my $i = 0;
   return sum gather for ^@words {
      if @words[$i] le @words[$_] { $i = $_ }
      else                        { take 1  }
   }
}
```

If we really want to let the second example make sense, then we can
easily wrap this within the following:

```raku
sub count-odd-one-out-but-not-really (@words) {
    my $candidate = count-odd-one-out(@words);
    my $total-words = @words.elems;
    return $total-words if $total-words - $candidate <= 1;
    return $candidate;
}
```

i.e. we do one additional remove if only one word would be left.

Again, I can't see how this fits the description.

Moving on to [Perl][], we do basically the same thing, only counting
things a bit differently because there's no `gather`/`take` around:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say count_odd_one_out(@ARGV ? @ARGV : qw< abc xyz def >);

sub count_odd_one_out (@words) {
   my $sum = 0;
   my $i = 0;
   for my $j (1 .. $#words) {
      if ($words[$i] le $words[$j]) { $i = $j }
      else                          { ++$sum  }
   }
   return $sum;
}
```

The adaptation for example 2 is left as an easy exercise for the reader 🙄

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#215]: https://theweeklychallenge.org/blog/perl-weekly-challenge-215/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-215/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
