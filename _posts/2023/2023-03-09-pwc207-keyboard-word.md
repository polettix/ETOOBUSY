---
title: PWC207 - Keyboard Word
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-03-09 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#207][]. Enjoy!

# The challenge

> You are given an array of words.
>
> Write a script to print all the words in the given array that can be types
> using alphabet on only one row of the keyboard.
>
> Let us assume the keys are arranged as below:
>
>     Row 1: qwertyuiop
>     Row 2: asdfghjkl
>     Row 3: zxcvbnm
>
> **Example 1**
>
>     Input: @words = ("Hello","Alaska","Dad","Peace")
>     Output: ("Alaska","Dad")
>
> **Example 2**
>
>     Input: @array = ("OMG","Bye")
>     Output: ()

# The questions

I'd nitpick that the SHIFT key is usually on the `zxc...` (at least on the
keyboard I have in front of me now), so `Alaska` is a bit controversial. On
the other hand, it's not an *alphabet* key, so it's debatable.

# The solution

We're encapsulating the single test in a `is-keyboard-word` function, that
applies on a single word at a time.

The function has a bit of "preparation" in the `state` variables, so that we
can reuse it over and over without having to re-compute everything all the
times.

State variable `@letter-sets` contains three sets, one for each group of
letter (i.e. the letters in each keyboard row, according to the spec). Each
set allows telling whether a specific "input" letter belongs to the group of
letters or not.

State variable `%set-ids-for` tells us the index of the set in
`@letter-sets` where a specific input letter belongs.

When a word comes in, we split (via `comb`) it into characters and find out
the set related to the first one (`$set`). We then check that all characters
from the splitting belong to the same set. This check might be more
idiomatic, but I find the "extended" form easier to read.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { @args.grep(&is-keyboard-word).put }

sub is-keyboard-word ($word) {
   state @rows = < qwertyuiop asdfghjkl zxcvbnm >;
   state @letter-sets = @rows.map({ .comb.Set });
   state %set-idx-for =
      @rows.kv
      .map(-> $idx, $row {
         $row.comb.map(-> $char { $char => $idx }) })
      .flat;

   my @letters = $word.lc.comb;
   my $set-idx = %set-idx-for{@letters[0]};
   my $set = @letter-sets[$set-idx];
   for @letters -> $letter {
      return False if $letter ∉ $set;
   }
   return True;
}
```

The [Perl][] version is a straight translation:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say join ' ', grep { is_keyboard_word($_) } @ARGV;

sub is_keyboard_word ($word) {
   state $rows = [qw< qwertyuiop asdfghjkl zxcvbnm >];
   state $letter_sets = [
      map {
         +{ map { $_ => 1 } split m{}mxs }
      } $rows->@*
   ];
   state $set_idx_for = {
      map {
         my $idx = $_;
         map { $_ => $idx } split m{}mxs, $rows->[$idx];
      } 0 .. $rows->$#*
   };
   my @letters = split m{}mxs, lc($word);
   my $set_idx = $set_idx_for->{$letters[0]};
   my $set = $letter_sets->[$set_idx];
   for my $letter (@letters) {
      return '' unless exists($set->{$letter});
   }
   return 1;
}
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#207]: https://theweeklychallenge.org/blog/perl-weekly-challenge-207/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-207/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
