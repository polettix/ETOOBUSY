---
title: PWC221 - Good Strings
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-06-15 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#221][]. Enjoy!

# The challenge

> You are given a list of `@words` and a string \$chars.
>
>> A string is good if it can be formed by characters from $chars, each
>> character can be used only once.
>
> Write a script to return the sum of lengths of all good strings in words.
>
> **Example 1**
>
>     Input: @words = ("cat", "bt", "hat", "tree")
>            $chars = "atach"
>     Output: 6
>
>     The good strings that can be formed are "cat" and "hat" so the answer
>     is 3 + 3 = 6.
>
> **Example 2**
>
>     Input: @words = ("hello", "world", "challenge")
>            $chars = "welldonehopper"
>     Output: 10
>
>     The strings that can be formed are "hello" and "world" so the answer >     is 5 + 5 = 10.

# The questions

Given past challenges, one question is whether characters case matters or
not. Additional questions would be:

- how should we handle accented characters?
- special characters, like quotation marks, hyphens, dots, etc.

# The solution

The [Bag][] data structure fits perfectly, allowing us to check the
inclusion via the aptly named `⊆` operator:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@words is copy) {
   my $chars = @words.shift;
   say good-strings($chars, @words);
}

sub good-strings ($chars, @words) {
   my $cbag = $chars.comb.Bag;
   return @words.grep({ .comb.Bag ⊆ $cbag })».chars.sum;
}
```

There's no such thing in [Perl][], so we will leverage hashes to do the
checks.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say good_strings(@ARGV);

sub good_strings ($chars, @words) {
   my %available;
   $available{$_}++ for split m{}mxs, $chars;
   my $retval = 0;
   WORD:
   for my $word (@words) {
      my %residual;
      for my $c (split m{}mxs, $word) {
         $residual{$c} //= $available{$c} // 0;
         next WORD if --$residual{$c} < 0;
      }
      $retval += length($word);
   }
   return $retval;
}
```

Cheers and stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#221]: https://theweeklychallenge.org/blog/perl-weekly-challenge-221/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-221/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Bag]: https://docs.raku.org/language/setbagmix.html
