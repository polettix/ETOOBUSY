---
title: PWC216 - Registration Number
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-05-11 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#216][]. Enjoy!

# The challenge

> You are given a list of words and a random registration number.
>
> Write a script to find all the words in the given list that has every
> letter in the given registration number.
>
> **Example 1**
>
>     Input: @words = ('abc', 'abcd', 'bcd'), $reg = 'AB1 2CD'
>     Output: ('abcd')
>
>     The only word that matches every alphabets in the given registration number is 'abcd'.
>
> **Example 2**
>
>     Input: @words = ('job', 'james', 'bjorg'), $reg = '007 JB'
>     Output: ('job', 'bjorg')
>
> **Example 3**
>
>     Input: @words = ('crack', 'road', 'rac'), $reg = 'C7 RA2'
>     Output: ('crack', 'rac')

# The questions

OK, I'll take the bait. This challenge's text has so many red flags that it
*oughts to be* an interview question. Let's see how much I score!

- the registration "*number*" is not a number, so what's a number?
- what's a word composed of? (I mean, if a number can have letters, a word
  might have digits...)
- what's a letter? Should we consider accented letters?
- is "having" a letter supposed to be considered case sensitive?
- what does "every letter" refer to exactly? I mean, "A has every letter in
  B" might mean:
    - that every letter of A is also in B, OR
    - that A has every letter that B has.
- what if a letter appears multiple times?

The examples shed some light on a few questions, but leave other ones
unanswered:

- we will only consider letters from the "registration number"
- (assumption) words are only composed of letters
- (assumption) a letter is a latin letter without accents
- comparisons will be case-insensitive
- we will check that the word contains every letter coming from the code
- (assumption) duplicates are ignored

# The solution

We will iterate through all words and filter out those that do not match our
inclusion rule. As we will ignore duplicates, we can use Sets and check that
the code is included within the word. In [Raku][] terms:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Str :$code, *@words) {
   my @code = $code.lc.subst(/ <-[ a..z ]>/, '', :g).comb.Set;
   @words.grep({ @code ⊆ .lc.comb }).join(', ').put;
}
```

[Perl][] does not have sets and set operations, but we can work at a lower
level. This time, then, we will filter each word's character to only keep
the ones that also appear within the code, ignoring duplicates. If we land
on the same number of items as in the code, then we have a match because all
items in the code appeared at least once.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

my %code = map { $_ => 1 } split m{}mxs, lc(shift) =~ s{[^a-z]}{}rgmxs;
my @words = grep {
   my %word = map { $_ => 1 } grep { $code{$_} } split m{}mxs, lc($_);
   scalar(keys(%code)) == scalar(keys(%word));
} @ARGV;
{ local $" = "', '"; say "('@words')" if @words }
```

Stay safe folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#216]: https://theweeklychallenge.org/blog/perl-weekly-challenge-216/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-216/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
