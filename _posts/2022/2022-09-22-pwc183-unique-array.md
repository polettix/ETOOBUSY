---
title: PWC183 - Unique Array
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-09-22 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#183][]. Enjoy!

# The challenge

> You are given list of arrayrefs.
>
> Write a script to remove the duplicate arrayrefs from the given list.
>
> **Example 1**
>
>     Input: @list = ([1,2], [3,4], [5,6], [1,2])
>     Output: ([1,2], [3,4], [5,6])
>
> **Example 2*
>
>     Input: @list = ([9,1], [3,7], [2,5], [2,5])
>     Output: ([9, 1], [3,7], [2,5])

# The questions

It would be interesting to know what is *inside* the array references,
and if they are all of the same size!

I will assume that the arrayrefs will contain some "stuff" that contains
no loop references and no blessed references.

# The solution

The general algorithm will be the same:

- figure out a string representation for the array ref
- use the string as a key in a hash, to filter out copies efficiently.

With [Raku][] we will use method `.gist` for the string representation:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   my @list = [1,2], [3,4], [5,6], [1,2];
   .say for remove-duplicate-subarrays(@list);
}
sub remove-duplicate-subarrays (@a) { my %seen; @a.grep({!%seen{.gist}++}) }
```

For the [Perl][] alternative, we're going to leverage the stock JSON
encoder that comes in CORE:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use JSON::PP;

my @list = ([1,2], [3,4], [5,6], [1,2]);
say JSON::PP::encode_json($_) for remove_duplicate_subarrays(@list);

sub remove_duplicate_subarrays (@l) {
   state $encoder = JSON::PP->new->ascii->canonical;
   my %seen;
   grep {!$seen{$encoder->encode($_)}++} @l;
}
```

This will break in case of circular data structures, blessed stuff...
but we're excluding them here, right?!?

Stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#183]: https://theweeklychallenge.org/blog/perl-weekly-challenge-813/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-183/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
