---
title: PWC160 - Four Is Magic
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-04-12 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#160][]. Enjoy!

# The challenge

> You are given a positive number, `$n < 10`.
>
> Write a script to generate english text sequence starting with the
> English cardinal representation of the given number, the word ‘is’ and
> then the English cardinal representation of the count of characters
> that made up the first word, followed by a comma. Continue until you
> reach four.
>
> **Example 1:**
>
>     Input: $n = 5
>     Output: Five is four, four is magic.
>
> **Example 2:**
>
>     Input: $n = 7
>     Output: Seven is five, five is four, four is magic.
>
> **Example 3:**
>
>     Input: $n = 6
>     Output: Six is three, three is five, five is four, four is magic.

# The questions

Apart from the *usual* nitpick about *numbers* meaning *integers*, I'm
curious about the restriction to numbers below 10. Is it just kindness?

Another question: are there other *fixed points* in addition to four?

# The solution

I was initially planning on getting a generic function for whatever
positive input, or negative for what's it's worth, but time pressure
steered me to just address the task at hand. So we're doing it in the
safe way: spell all digits loud, iterate until we find four, and format
our outputs according to the examples.

[Raku][] goes first:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $n where 0 < * < 10 = 5) { put four-is-magic($n); }

sub four-is-magic (Int:D $n is copy where 0 < * < 10) {
   state @ints = <zero one two three four five six seven eight nine >;
   my $current = @ints[$n];
   my @seq = gather while $n != 4 {
      $n = $current.chars;
      my $next = @ints[$n];
      take "$current is $next";
      $current = $next;
   };
   @seq.push: 'four is magic.';
   @seq[0] = @seq[0].tclc;
   return @seq.join(', ');
}
```

Then, of course, [Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my $n = shift // 7;
say four_is_magic($n);

sub four_is_magic ($n) {
   state $ints = [qw< zero one two three four five six seven eight nine >];
   my $current = $ints->[$n];
   my @seq;
   while ($n != 4) {
      $n = length $current;
      (my $previous, $current) = ($current, $ints->[$n]);
      push @seq, "$previous is $current";
   }
   push @seq, 'four is magic.';
   $seq[0] = ucfirst $seq[0];
   return join ', ', @seq;
}
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#160]: https://theweeklychallenge.org/blog/perl-weekly-challenge-160/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-160/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
