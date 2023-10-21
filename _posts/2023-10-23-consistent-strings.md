---
title: PWC239 - Consistent Strings
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-10-23 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#239][].
> Enjoy!

# The challenge

> You are given an array of strings and allowed string having distinct
> characters.
>
>> A string is consistent if all characters in the string appear in the
>> string allowed.
>
> Write a script to return the number of consistent strings in the given
> array.
>
> **Example 1**
>
>     Input: @str = ("ad", "bd", "aaab", "baa", "badab")
>            $allowed = "ab"
>     Output: 2
>
>     Strings "aaab" and "baa" are consistent since they only contain characters 'a' and 'b'.
>
> **Example 2**
>
>     Input: @str = ("a", "b", "c", "ab", "ac", "bc", "abc")
>            $allowed = "abc"
>     Output: 7
>
> **Example 3**
>
>     Input: @str = ("cc", "acd", "b", "ba", "bac", "bad", "ac", "d")
>            $allowed = "cad"
>     Output: 4
>
>     Strings "cc", "acd", "ac", and "d" are consistent.

# The questions

Talking about checking for equality... are accented characters the same
as non-accented ones?

# The solution

We can do the check using a hash/set and then checking that all
characters belong to it.

[Perl][] goes first, we encapsulate the test in a function so that it's
easy to use `grep` in scalar context to produce the output:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

my $cc = consistency_checker_for(shift);
say scalar grep { $cc->($_) } @ARGV;

sub consistency_checker_for ($string) {
   my %is_allowed = map { $_ => 1 } split m{}mxs, shift;
   return sub ($input) {
      for my $i (0 .. length($input) - 1) {
         return unless $is_allowed{substr($input, $i, 1)};
      }
      return 1;
   };
}
```

We do almost the same in [Raku][], just a little change moving the test
function inside the function to do the overall test. We could have done
like this in [Perl][] as well.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($allowed, *@str) { put consistent-string($allowed, @str).elems }

sub consistent-string ($allowed, @str) {
   my $al = $allowed.comb.Set;
   my &checker = sub ($input) {
      for $input.comb -> $c {
         return False unless $c ∈ $al;
      }
      return True;
   };
   @str.grep(&checker);
}
```

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#239]: https://theweeklychallenge.org/blog/perl-weekly-challenge-239/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-239/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
