---
title: PWC197 - Wiggle Sort
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-12-30 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#197][].
> Enjoy!

# The challenge

> You are given a list of integers, `@list`.
>
> Write a script to perform `Wiggle Sort` on the given list.
>
> Wiggle sort would be such as list[0] < list[1] > list[2] < list[3]….
>
> **Example 1**
>
>     Input: @list = (1,5,1,1,6,4)
>     Output: (1,6,1,5,1,4)
>
> **Example 2**
>
>     Input: @list = (1,3,2,2,3,1)
>     Output: (2,3,1,3,1,2)

# The questions

Why... oh why these sort of sorts? Sort of strange...

More seriously, what to do with corner cases where e.g. most numbers are
the same, and the requested sorting cannot be obtained?

# The solution

I'll call my solutions *sloppy* to acknowledge the fact that I'm not
putting exactly all myself into this solution. Maybe it's an interview
question geared at testing our willingness to do sillyness. Or lack
thereof.

Anyway.

We can sort the list and then cut it *in half*, then interleave the two
parts. If the list has an odd number of elements... no worries, let's
just make the second half shorter and interleave them starting from the
first.

Why is this sloppy? There might be corner cases, like most numbers being
the same, where the requested sorting is simply not possible. I'll
happily waive my hand and leave this as a simple exercise for the
reader.

Which brings us to the [Perl][] solution:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @wiggled = wiggle_sort_sloppy(@ARGV ? @ARGV : (1, 5, 1, 1, 6, 4));
{local $" = ','; say "(@wiggled)"}

sub wiggle_sort_sloppy (@list) {
   @list = sort { $a <=> $b } @list;
   my @upper = splice @list, int((@list + 1) / 2);
   map { $_, (@upper ? shift(@upper) : ()) } @list;
}
```

The [Raku][] solution is very similar, although I like `gather`/`ŧake`
and use them when possible:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   @args = 1, 5, 1, 1, 6, 4 unless @args;
   put '(', wiggle-sort-sloppy(@args).join(','), ')';
}

sub wiggle-sort-sloppy (@list) {
   my @ordered = @list.sort: { $^a <=> $^b };
   my $halfway = (@ordered + 1) div 2;
   gather for ^$halfway {
      take @ordered[$_];
      take @ordered[$_ + $halfway] if $_ + $halfway < @ordered;
   }
}
```

Enough! Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#197]: https://theweeklychallenge.org/blog/perl-weekly-challenge-197/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-197/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
