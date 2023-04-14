---
title: PWC212 - Jumping Letters
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-04-13 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#212][]. Enjoy!

# The challenge

> You are given a word having alphabetic characters only, and a list of
> positive integers of the same length
>
> Write a script to print the new word generated after jumping forward each
> letter in the given word by the integer in the list. The given list would
> have exactly the number as the total alphabets in the given word.
>
> **Example 1**
>
>     Input: $word = 'Perl' and @jump = (2,22,19,9)
>     Output: Raku
>
>     'P' jumps 2 place forward and becomes 'R'.
>     'e' jumps 22 place forward and becomes 'a'. (jump is cyclic i.e. after 'z' you go back to 'a')
>     'r' jumps 19 place forward and becomes 'k'.
>     'l' jumps 9 place forward and becomes 'u'.
>
> **Example 2**
>
>     Input: $word = 'Raku' and @jump = (24,4,7,17)
>     Output: 'Perl'

# The questions

One thing that is missing in the *text* is the behaviour upon going
off-edge, i.e. cycling back to either `a` or `A` (depending on the letter's
case). This is later explained in the first example, *although* it
techically only covers lowercase letters, and nothing is said about upper
case. The second example seems to confirm this approach for uppercase
letters too.

# The solution

There are two main *things* going on here:

- lowercase and uppercase letters have to be dealt with separately;
- jump operations have to wrap when going off-edge.

The first issue will require us to tell the difference, which we can do by
comparing the `ord` of the character (i.e. its numerical value according to
ASCII) against that of the letter `a`:

- if greater or equal, it's a lowercase letter;
- otherwise, it's uppercase.

This leverages an *offline knowledge* about the values for those two base
letters, of course.

The second issue can be addressed by summing the jump and resetting to the
respective base for uppercase or lowercase letters as applicable. This
assumes that letters are consecutive and contiguous, which is true in ASCII.

All in all, if we're on some system that *does not* adopt ASCII, the
solution below will fail miserably.

[Raku][] first:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@jumps) {
   @jumps = 'Perl', 2, 22, 19, 9 unless @jumps;
   my $word = @jumps.shift;
   put jumping-letters($word, @jumps);
}

sub jumping-letters ($word, @jumps) {
   state @bases = 'A'.ord, 'a'.ord;
   ($word.comb Z @jumps).map(-> ($c, $j) {
      my $old = $c.ord;
      my $base = @bases[$old >= @bases[1] ?? 1 !! 0];
      my $new = $base + (($old - $base + $j) % 26);
      $new.chr;
   }).join('');
}
```

[Perl][] is the usual translation, with a bit less of sophistication:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

my ($word, @jumps) = @ARGV ? @ARGV : qw< Perl 2 22 19 9 >;
say jumping_letters($word, @jumps);

sub jumping_letters ($word, @jumps) {
   state $bases = [ord('A'), ord('a')];
   join '', map {
      my $old = ord(substr($word, $_, 1));
      my $base = $bases->[$old >= $bases->[1]];
      my $new = $base + (($old - $base + $jumps[$_]) % 26);
      chr($new);
   } 0 .. $#jumps;
}
```

What should we do to remove the dependency on ASCII encoding? I have a few
ideas, but the simpler one is to pre-build two arrays, one for lowercase
letters and the other one for uppercase ones, to be used both for figuring
out the case and doing the whole jump trick. Something along the lines of
the following **untested** [Raku][] code:

```raku
sub jump-letter ($letter, $jump) {
    state @cases = 'abcdefghijklmnopqrstuvwxyz',
                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for @cases -> $case {
        my $old = $case.index($letter);
        next if $old < 0;
        my $new = ($old + $jump) % $case.chars;
        return $case.substr($new, 1);
    }
}
```

Stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#212]: https://theweeklychallenge.org/blog/perl-weekly-challenge-212/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-212/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
