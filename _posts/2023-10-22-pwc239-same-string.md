---
title: PWC239 - Same String
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-10-22 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#239][]. Enjoy!

# The challenge

> You are given two arrays of strings.
>
> Write a script to find out if the word created by concatenating the
> array elements is the same.
>
> **Example 1**
>
>     Input: @arr1 = ("ab", "c")
>
>     Output: true
>
>     Using @arr1, word1 => "ab" . "c" => "abc"
>     Using @arr2, word2 => "a" . "bc" => "abc"
>
> **Example 2**
>
>     Input: @arr1 = ("ab", "c")
>            @arr2 = ("ac", "b")
>     Output: false
>
>     Using @arr1, word1 => "ab" . "c" => "abc"
>     Using @arr2, word2 => "ac" . "b" => "acb"

# The questions

This time I have a *meta*-question... how is people addressing the
problem of getting the inputs from the command line?

Well, apart from this I'd probably ask what *the same* means. E.g.
should differently-accented character count as *same*? I'll assume
not...

# The solution

We're starting with [Raku][] and we're going the easy way, joining all
strings together and comparing the results:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($s1, $s2) { say is-same-string($s1.split(/\,/), $s2.split(/\,/)) }

sub is-same-string (@s1, @s2) { @s1.join('') eq @s2.join('') }
```

For the [Perl][] counterpart, we're going the over-engineering way and
assume that there might be several input arrays, as well as avoiding to
merge them in single strings and instead iterate them character by
character:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;

my ($s1, $s2) = map { [ split m{,}mxs ]  } @ARGV[0,1];
say is_same_string($s1, $s2) ? 'true' : 'false';

sub is_same_string {
   my ($lead, @other) = map {
      my $aref = $_;
      my $idx = 0;
      my $ch_idx = 0;
      sub {
         while ($idx <= $aref->$#*) {
            return substr($aref->[$idx], $ch_idx++, 1)
               if $ch_idx < length($aref->[$idx]);
            ++$idx;
            $ch_idx = 0;
         }
         return;
      };
   } @_;
   while ('necessary') {
      my $ch = $lead->();
      if (! defined($ch)) {
         for my $it (@other) {
            return 0 if defined($it->());
         }
         return 1;
      }
      for my $it (@other) {
         my $och = $it->();
         return 0 if ($och // '') ne $ch;
      }
   }
}
```

Cheers and... stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#239]: https://theweeklychallenge.org/blog/perl-weekly-challenge-239/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-239/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
