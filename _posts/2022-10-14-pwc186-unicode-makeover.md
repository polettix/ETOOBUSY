---
title: PWC186 - Unicode Makeover
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-10-14 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#186][].
> Enjoy!

# The challenge

> You are given a string with possible unicode characters.
>
> Create a subroutine `sub makeover($str)` that replace the unicode
> characters with ascii equivalent. For this task, let us assume it only
> contains alphabets. **Example 1**
>
>     Input: $str = 'ÃÊÍÒÙ';
>     Output: 'AEIOU'
>
> **Example 2**
>
>     Input: $str = 'âÊíÒÙ';
>     Output: 'aEiOU'

# The questions

Should I learn everything about Unicode?

# The solution

There is a high probability that this will not be a correct solution,
whatever.

I'll look for a decomposition and check if the first part is an ASCII
letter, taking it if true or the whole char if not.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Unicode::UCD 'charinfo';
use utf8;

say makeover('âÊíÒÙ whatever123 ÃÊÍÒÙ');

sub makeover ($str) {
   return join '', map {
      my $info = charinfo(ord $_);
      my ($basic_hex) = split m{\s+}mxs, $info->{decomposition};
      my $basic = hex($basic_hex // '00');
      my $is_latin_letter =
         (ord('a') <= $basic && $basic <= ord('z'))
         || (ord('A') <= $basic && $basic <= ord('Z'));
      $is_latin_letter ? chr($basic) : $_;
   } split m{}mxs, $str;
}
```

I should have probably used [Text::Undiacritic][] but whatever.

Same approach in [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   put makeover('âÊíÒÙ whatever123 ÃÊÍÒÙ');
}

sub makeover ($str) {
   $str.comb(/./)».NFD.map(
      -> $c {
         my ($basic) = $c.list;
         ('a'.ord <= $basic <= 'z'.ord) || ('A'.ord <= $basic <= 'Z'.ord)
         ?? $basic.chr !! $c;
      }
   ).join('');
}
```

Enough for today, stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#186]: https://theweeklychallenge.org/blog/perl-weekly-challenge-186/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-186/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://manwar.org/
[Text::Undiacritic]: https://metacpan.org/pod/Text::Undiacritic
