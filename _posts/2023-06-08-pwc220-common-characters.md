---
title: PWC220 - Common Characters
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-06-08 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#220][]. Enjoy!

# The challenge

> You are given a list of words.
>
> Write a script to return the list of common characters (sorted
> alphabeticall) found in every word of the given list.
>
> **Example 1**
>
>     Input: @words = ("Perl", "Rust", "Raku")
>     Output: ("r")
>
> **Example 2**
>
>     Input: @words = ("love", "live", "leave")
>     Output: ("e", "l", "v")

# The questions

Should we consider uppercase and lowercase equivalent to lowercases? The
first example seems to hint in this direction.

The list is supposed to be composed of words formed by *characters*. Is this
from a specific alphabet? Does it guarantee that a lowercase form always
exist?

# The solution

We'all assume that whatever we get as input is a word composed of
characters, but we'll stick to ASCII for simplicity.

Each word can be split into component characters, then the checks can begin.
There can be no different letters than what are contained in the first word,
so we can start from there. We can imagine that the group of letters is then
checked against the next word, where only the matching ones remain and other
ones are removed, just to move on to the next word and so on. What we're
left with after the last word are the letters we are looking for.

OK, enough talking, let's go to [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@words) { say common-characters(@words) }

sub common-characters (@words) {
   return [] unless @words;
   @words
      .map({ .lc.comb })
      .reduce(-> $a, $b { my $s = $b.Set; $a.grep({ $_ ∈ $s }) })
      .sort;
}
```

We are getting our initial group of letters, and traversing it through a
comparison with all remaining groups, which seems where `reduce` is really
at ease. The "second" group of letter (at each iteration) is turned into a
set, so that we can use `grep` to keep the matching ones easily.

`reduce` leaves us with a single output sequence, which is sorted and
returned. Easy-peasy.

Moving to [Perl][], there's a bit more of fiddling that we have to do, but
we can basically adopt the same approach. In lack of sets, we resort to the
super-flexible hashes, which work pretty well for these filtering
activities:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
use JSON::PP;
use List::Util 'reduce';

say encode_json(common_characters(@ARGV)) =~ tr{[]}{()}r;

sub common_characters (@words) {
   return [] unless @words;
   my $aref = reduce {
         my %s = map { $_ => 1 } $b->@*;
         [ grep { $s{$_} } $a->@* ];
      }
      map { [ split m{}mxs ] }
      @words;
   return [ sort { $a cmp $b } $aref->@* ];
}
```

I opted for splitting the whole thing into two parts, separating the sorting
at the end to reduce confusion (we end up with an array reference, so we
have to dereference it in order to get a sorted output to embed in yet
another array reference).

Stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#220]: https://theweeklychallenge.org/blog/perl-weekly-challenge-220/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-220/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
