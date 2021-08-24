---
title: PWC127 - Disjoint Sets
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-08-25 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#127][]. Enjoy!

# The Challenge

> You are given two sets with unique integers. Write a script to figure
> out if they are disjoint. The two sets are disjoint if they don’t have
> any common members.
>
> **Example**
>
>     Input: @S1 = (1, 2, 5, 3, 4)
>            @S2 = (4, 6, 7, 8, 9)
>     Output: 0 as the given two sets have common member 4.
>
>     Input: @S1 = (1, 3, 5, 7, 9)
>            @S2 = (0, 2, 4, 6, 8)
>     Output: 1 as the given two sets do not have common member.

# The Questions

It might be interesting to understand if there is any limit on the
inputs, e.g. how many items in each set and/or if the values can have
restrictions (e.g. a lower and a upper bound).

Depending on the answer, there might be different implementation
choices. For example, if there are so many elements that they cannot fit
in memory, then some file-based solution might be wise, e.g. by sorting
the inputs first and then comparing them for intersection (which might
lead to anticipatedly exiting the comparison loop in case the two
sequences indeed have a common element).

We will assume that all inputs fit in memory and that, in general,
memory is not an issue in our case.

# The Solution

[Raku][] has core support for sets, so it would be a waste not to use
it. Which is what is done in the following solution:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   my @sequences = @args.map: *.split(/\D+/).Set;
   put ([(&)] @sequences) ?? 0 !! 1;
}
```

We assume to get the two lists from the command line arguments, a single
string each that is looked for non-digit characters to act as
separators. The result is turned into a `Set` because we want to do some
*set operations*, right?

This is actually a more general approach where we might want to put more
lists inside, and see if they are all disjoint. For this reason, we use
a `map` to get all inputs that we are given.

The [reduction (meta)operator][reduct] `[(&)]` implements the actual
intersection across all sets. Doing this is overkill, because
technically speaking we don't have to compute the whole intersection,
just find whether one intersection exists. Whatever, we'll save this for
[Perl][].

Due to precedence, the call to the reduction operator has to be embedded
in round parentheses; its result is used to generate the output as
requested.

The [Perl][] alternative is... different. In it, we actually build one
single set-equivalent from one sequence (that is the ultra-flexibile
hash) and then check the elements from the other sequence for matches in
the first one:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub disjoint_sets ($seq1, $seq2) {
   my %flag = map { $_ => 1 } $seq1->@*;
   for my $e ($seq2->@*) { return 0 if exists $flag{$e} }
   return 1;
}

say disjoint_sets(map { [split m{\D+}mxs] } @ARGV);
```

As an afterthought, actually, we can observe that the inputs
specification makes it clear that elements are never repeated in each
sequence, so we might even simplify like this:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub disjoint_sets ($seq1, $seq2) {
   my %flag;
   for my $e ($seq1->@*, $seq2->@*) { return 0 if $flag{$e}++ }
   return 1;
}

say disjoint_sets(map { [split m{\D+}mxs] } @ARGV);
```

I'm not entirely sure it's better - just simpler, I guess. It only
checks for duplicates in the whole thing, keeping track of them as it
goes.

And with this... stay safe folks, and have `-Ofun`!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#127]: https://theweeklychallenge.org/blog/perl-weekly-challenge-127/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-127/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[reduct]: https://docs.raku.org/language/operators#Reduction_metaoperators
