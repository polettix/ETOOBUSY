---
title: PWC161 - Abecedarian Words
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-04-19 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#161][]. Enjoy!

# The challenge

> An `abecedarian word` is a word whose letters are arranged in alphabetical
> order. For example, “knotty” is an abecedarian word, but “knots” is not.
> Output or return a list of all abecedarian words in the [dictionary][],
> sorted in decreasing order of length.
>
> Optionally, using only abecedarian words, leave a short comment in your code
> to make your reviewer smile.

# The questions

A nice detour! I'd ask what we have to do with uppercase letters, but the provided [dictionary][] contains none so... it's OK.

# The solution

[Raku][] goes first:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Str:D $dictionary) {
   all-sorted-abecedarian-in($dictionary).put;
}

sub all-sorted-abecedarian-in (Str $dictionary) {
   all-abecedarian-in($dictionary).sort({$^a.chars <=> $^b.chars}).Array;
}

sub all-abecedarian-in (Str $dictionary) {
   $dictionary.IO.lines.grep({is-abecedarian($_)}).Array;
}

sub is-abecedarian (Str $word) {
   $word.fc.comb.sort.join('') eq $word.fc;
}

# be chill or annoy forty bossy nosy cops
```

The test in `is-abecedarian` is dead simple: rearrange letters in alphabetical
order and compare the resulting word with the original. I'm anyway choosing to
do the test ignoring the case, hence the calls to `fc`.

The rest is support integration stuff: `all-abecedarian-in` filters the file
for abecedarian words, and `all-sorted-abecedarian-in` does the requested
sorting. printing is in `MAIN`.

[Perl][] gets a more or less straightforward translation:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say join ' ', all_sorted_abecedarian_in(shift);

sub all_sorted_abecedarian_in ($dictionary) {
   sort { length($a) <=> length($b) } all_abecedarian_in($dictionary);
}

sub all_abecedarian_in ($dictionary) {
   open my $fh, '<:encoding(utf-8)', $dictionary or die "open(): $!\n";
   grep { is_abecedarian($_) } map { s{\s+\z}{}rmxs } readline $fh;
}

sub is_abecedarian ($word) {
   fc $word eq join '', sort split m{}mxs, fc $word;
}
```

Same logic, different syntax and supporting functions, same result.

Stay safe and... *be no ill*!!!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#161]: https://theweeklychallenge.org/blog/perl-weekly-challenge-161/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-161/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[dictionary]: https://github.com/manwar/perlweeklychallenge-club/blob/master/data/dictionary.txt
