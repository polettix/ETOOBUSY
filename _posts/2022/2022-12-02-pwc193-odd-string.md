---
title: PWC193 - Odd String
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-12-02 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#193][].
> Enjoy!

# The challenge

> You are given a list of strings of same length, `@s`.
>
> Write a script to find the odd string in the given list. Use
> positional value of alphabet starting with `0`, i.e. `a = 0, b = 1,
> ... z = 25`.
>
>> Find the difference array for each string as shown in the example.
>> Then pick the odd one out.
>
> **Example 1:**
>
>     Input: @s = ("adc", "wzy", "abc")
>     Output: "abc"
>
>     Difference array for "adc" => [ d - a, c - d ]
>                                => [ 3 - 0, 2 - 3 ]
>                                => [ 3, -1 ]
>
>     Difference array for "wzy" => [ z - w, y - z ]
>                                => [ 25 - 22, 24 - 25 ]
>                                => [ 3, -1 ]
>
>     Difference array for "abc" => [ b - a, c - b ]
>                                => [ 1 - 0, 2 - 1 ]
>                                => [ 1, 1 ]
>
>     The difference array for "abc" is the odd one.
>
> **Example 2:**
>
>     Input: @s = ("aaa", "bob", "ccc", "ddd")
>     Output: "bob"
>
>     Difference array for "aaa" => [ a - a, a - a ]
>                                => [ 0 - 0, 0 - 0 ]
>                                => [ 0, 0 ]
>
>     Difference array for "bob" => [ o - b, b - o ]
>                                => [ 14 - 1, 1 - 14 ]
>                                => [ 13, -13 ]
>
>     Difference array for "ccc" => [ c - c, c - c ]
>                                => [ 2 - 2, 2 - 2 ]
>                                => [ 0, 0 ]
>
>     Difference array for "ddd" => [ d - d, d - d ]
>                                => [ 3 - 3, 3 - 3 ]
>                                => [ 0, 0 ]
>
>     The difference array for "bob" is the odd one.

# The questions

Well, I only have one question: can I skip all input validation? There
are a lot of assumptions, like that there *is* an odd string, that there
is *only one* such string, that strings are all the same length and it's
at least 1 character long, etc.

# The solution

In the [Perl][] alternative, we're taking the longer route for the
programmer, but one that should give us an answer as soon as possible
(i.e. without having to go through the whole string for all strings or
so). So we're iterating by char index *and then* by string.

One thing to note is that finding the odd one does not necessarily mean
that each element should be compared against the previous one - we might
just as well compare against the first one. Which is what we're doing
here by using `@pre`.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @strings = @ARGV ? @ARGV : qw< adc wzy abc >;
say odd_string(@strings);

sub odd_string (@strings) {
   my @pre = map { ord substr $_, 0, 1 } @strings;
   for my $i (1 .. $#strings) {
      my %string_for;
      my $n_different = 0;
      my @cur;
      my $j = 0;
      for my $string (@strings) {
         my $delta = ord(substr $string, $i, 1) - $pre[$j++];
         if (! $n_different) {
            $string_for{$delta} = $string;
            ++$n_different;
         }
         elsif ($n_different == 1) {
            if (exists $string_for{$delta}) {
               $string_for{$delta} = [];
            }
            elsif (ref((values %string_for)[0])) {
               return $string;
            }
            else {
               $string_for{$delta} = $string;
               ++$n_different;
            }
         }
         elsif ($n_different == 2) {
            delete $string_for{$delta};
            return((values %string_for)[0]);
         }
      }
   }
}
```

In [Raku][] we're taking an easier-to-code approach, where we calculate
the *fingerprint* for each string, and find out the odd one:

```raku
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @strings = @ARGV ? @ARGV : qw< adc wzy abc >;
say odd_string(@strings);

sub odd_string (@strings) {
   my @pre = map { ord substr $_, 0, 1 } @strings;
   for my $i (1 .. $#strings) {
      my %string_for;
      my $n_different = 0;
      my @cur;
      my $j = 0;
      for my $string (@strings) {
         my $delta = ord(substr $string, $i, 1) - $pre[$j++];
         if (! $n_different) {
            $string_for{$delta} = $string;
            ++$n_different;
         }
         elsif ($n_different == 1) {
            if (exists $string_for{$delta}) {
               $string_for{$delta} = [];
            }
            elsif (ref((values %string_for)[0])) {
               return $string;
            }
            else {
               $string_for{$delta} = $string;
               ++$n_different;
            }
         }
         elsif ($n_different == 2) {
            delete $string_for{$delta};
            return((values %string_for)[0]);
         }
      }
   }
}
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#193]: https://theweeklychallenge.org/blog/perl-weekly-challenge-193/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-193/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
