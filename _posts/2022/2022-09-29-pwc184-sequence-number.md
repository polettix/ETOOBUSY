---
title: PWC184 - Sequence Number
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-09-29 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#184][]. Enjoy!

# The challenge

> You are given list of strings in the format `aa9999` i.e. first 2
> characters can be anything `'a-z'` followed by 4 digits `'0-9'`.
>
> Write a script to replace the first two characters with sequence
> starting with `'00'`, `'01'`, `'02'` etc.
>
> **Example 1**
>
>     Input: @list = ( 'ab1234', 'cd5678', 'ef1342')
>     Output: ('001234', '015678', '021342')
>
> **Example 2**
>
>     Input: @list = ( 'pq1122', 'rs3334')
>     Output: ('001122', '013334')

# The questions

Well, a couple...

- can we really assume that items are compliant to the specification? In
  case, what to do with the non-compliant ones?
- what if our array has more than 100 items? Do we start back from
  `'00'` or should we add a digit? Should we eat a digit from the next
  section?

# The solution

We will use a substring function to substitute the first two characters
with the sequence number, obtained using `sprintf` with a suitable
*at-least-to-digits* template.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   my @l = < ab1234 cd5678 ef1342 >;
   sequence-number(@l);
   .put for @l;
}

sub sequence-number (@list) {
   my $n = 0;
   @list.map({.substr-rw(0, 2) = '%02d'.sprintf($n++)});
   @list;
}
```

We can do the same with [Perl][] of course:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @list = qw< ab1234 cd5678 ef1342 >;
sequence_number(\@list);
say for @list;

sub sequence_number ($list) {
   my $n = 0;
   substr $_, 0, 2, sprintf '%02d', $n++ for $list->@*;
   return $list;
}
```

Both solutions change the array *in-place* because... well, that's how I
read *replace the first two characters...*! Should I have asked
something in the questions?!?

Stay safe folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#184]: https://theweeklychallenge.org/blog/perl-weekly-challenge-184/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-184/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
