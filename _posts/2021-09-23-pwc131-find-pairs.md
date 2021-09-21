---
title: PWC131 - Find Pairs
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-09-23 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#131][].
> Enjoy!

# The challenge


> You are given a string of delimiter pairs and a string to search.
>
> Write a script to return two strings, the first with any characters
> matching the “opening character” set, the second with any matching the
> “closing character” set.
>
> **Example 1:**
>
>     Input:
>         Delimiter pairs: ""[]()
>         Search String: "I like (parens) and the Apple ][+" they said.
>     
>     Output:
>         "(["
>         ")]"
>
> **Example 2:**
>
>     Input:
>         Delimiter pairs: **//<>
>         Search String: /* This is a comment (in some languages) */ <could be a tag>
>     
>     Output:
>         /**/<
>         /**/>


# The questions

At a first reading, I could not make too much of the challenge text. But
I was probably tired, because after some time passed it makes perfectly
sense.

The input string with the pairs is assumed to contain pairs of consecutive
characters. Well... actually I didn't bother to do anything about the
expected encoding of the inputs, so it's... whatever we get, most
probably ASCII.

When the pair of consecutive characters actually contains the same
character repeated twise, I'll assume that it's fine to find any
occurrence independently of whether it's an *opening* or a *closing*
one. Whatever.

Last, there seems to be no constraint about escaping, so I'll assume
there is none.


# The solution

This was pretty straightforward in [Perl][]:

- we divide the delimiters string putting the even-positioned character
  in a string, and the odd-positioned characters in another string (both
  go into an array `@delimiters);
- then we do a non-destructive substitution using the strings of
  delimiters as character classes in the matching part.

Easier shown than described:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub find_pairs ($delimiter_pairs, $search_string) {
   my @delimiters = ('', '');
   while ($delimiter_pairs) {
      $delimiters[$_] .= substr $delimiter_pairs, 0, 1, '' for 0, 1;
   }
   return map { $search_string =~ s{[^\Q$_\E]+}{}rgmxs } @delimiters;
} ## end sub find_pairs

say
  for find_pairs(@ARGV
   ? @ARGV
   : ('""[]()', '"I like (parens) and the Apple ][+" they said.'));
```

My [Raku][]-fu is not that strong, though.

First of all, I don't particularly like the equivalent of the [Perl][]'s
`substr` form that allows putting another string instead of the one that
is isolated. So I opted for splitting the input string using `comb` and
working on the resulting array of character.

Second, it seems that it's not possible to interpolate a variable into a
character class (see [this issue][]). Hence, using `S///` was out of
luck.

I eventually decided to split the input `$search-string` too, and use
some smartmatching to get the filtering job done.

```raku
#!/usr/bin/env raku
use v6;

sub find-pairs ($delimiter-pairs, $search-string) {
   my @delimiters = [], [];
   my @chars = $delimiter-pairs.comb;
   (0, 1).map({@delimiters[$_].push: @chars.shift}) while @chars;
   return @delimiters.map: -> $d {
      $search-string.comb.grep({$^a ~~ $d.any}).join: '';
   };
}

sub MAIN ($delimiter-pairs = '""[]()',
      $search-string = '"I like (parens) and the Apple ][+" they said.') {
   .put for find-pairs($delimiter-pairs, $search-string).List;
}
```

I'm not happy with this solution, the regular expression approach just
seems much more natural.

Anyway, enough for this post... stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#131]: https://theweeklychallenge.org/blog/perl-weekly-challenge-131/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-131/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[this issue]: https://github.com/Raku/problem-solving/issues/97
