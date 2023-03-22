---
title: PWC209 - Merge Account
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-03-24 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#209][].
> Enjoy!

# The challenge

> You are given an array of accounts i.e. name with list of email addresses.
>
> Write a script to merge the accounts where possible. The accounts can only
> be merged if they have at least one email address in common.
>
> **Example 1:**
>
>     Input: @accounts = [ ["A", "a1@a.com", "a2@a.com"],
>                          ["B", "b1@b.com"],
>                          ["A", "a3@a.com", "a1@a.com"] ]
>                        ]
>
>     Output: [ ["A", "a1@a.com", "a2@a.com", "a3@a.com"],
>               ["B", "b1@b.com"] ]
>
> **Example 2:**
>
>     Input: @accounts = [ ["A", "a1@a.com", "a2@a.com"],
>                          ["B", "b1@b.com"],
>                          ["A", "a3@a.com"],
>                          ["B"m "b2@b.com", "b1@b.com"] ]
>
>     Output: [ ["A", "a1@a.com", "a2@a.com"],
>               ["A", "a3@a.com"],
>               ["B", "b1@b.com", "b2@b.com"] ]

# The questions

Should the merging be "stable"? I mean, should we preserve as much as
possible the order of appearance of the different groups? It seems not,
because in the second example the two "A" groups both appear *before* the
"B" group, despite a "B" group appearing between them.

Which begs a related question: maybe it's some kind of "stable", but moving
forward instead of keeping things backwards? I'm digressing.

Another question relates to the order of the addresses. The inputs are
arranged in arrays, which seems to imply that order *might* be important. ON
the other hand, these arrays contain semantically different data (a name,
addresses), so maybe it's more like a tuple and order does not matter. I'll
assume the latter.

# The solution

The solution in [Perl][] is somehow intentionally long and complicated. I
took the challenge of producing a *stable* result, i.e. try to preserve the
order of appearance of addresses if possible. Additionally, I tried to
minimize the copying and duplications and iterations and whatsnot, in pure
evil spirit of [premature optimization][].

Addresses are iterated over and amassed in "groups" by name. Each group
contains all disjoint addresses belonging to that name, trying to pack them
as much as possible while we do the input's sweep. If we can merge, we merge
and move on to see if additional merging is possible (because previous
addresses A and B might be disjoint, but both joined with later address C).

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

use constant TRUE  => (!0);
use constant FALSE => (!!0);

my @accounts = (
   ['A', 'a1@a.com', 'a2@a.com'],
   ['B', 'b1@b.com'],
   ['A', 'a3@a.com', 'a4@a.com'],
   ['B', 'b2@b.com', 'b1@b.com'],
   ['A', 'a8@a.com'],
   ['A', 'a3@a.com', 'a2@a.com'],
);

for my $merged (merge_accounts(\@accounts)->@*) {
   say '[', join(', ', map { +"'$_'"} $merged->@* ), ']';
}

sub hashes_intersect ($h1, $h2) {
   my $n1 = scalar(keys($h1->%*));
   my $n2 = scalar(keys($h2->%*));
   ($h1, $h2) = ($h2, $h1) if $n1 > $n2;

   # now $h1 has *at most* as many elements as $h2, it's beneficial to
   # iterate over it
   for my $key (keys $h1->%*) {
      return TRUE if exists $h2->{$key};
   }
   return FALSE;
}

sub merge_accounts ($aref) {
   my %alternatives_for;  # track each name separately
   my %group_for;         # track aggregated groups by order of appearance
   for my $i (0 .. $aref->$#*) {
      my ($name, @addresses) = $aref->[$i]->@*;
      $group_for{$i} = my $new = {
         i => $i,
         name => $name,
         addresses => { map { $_ => 1 } @addresses },
      };

      # Add this group like it's detached
      my $all_groups = $alternatives_for{$name} //= [];
      push $all_groups->@*, $new;

      # sweep back to merge when necessary
      my $challenger = $all_groups->$#*;
      my $resistant = $challenger - 1;
      my $last_wiped;
      while ($resistant >= 0) {
         my $cas = $all_groups->[$challenger]{addresses};
         my $ras = $all_groups->[$resistant]{addresses};
         if (hashes_intersect($cas, $ras)) {
            $ras->%* = ($ras->%*, $cas->%*);     # merge

            ($last_wiped, $challenger) = ($challenger, $resistant);
            delete $group_for{$all_groups->[$last_wiped]{i}};
            $all_groups->[$last_wiped] = undef;
         }
         --$resistant;
      }

      # sweep ahead to remove wiped out stuff, if necessary
      if (defined($last_wiped)) {
         my $marker = my $cursor = $last_wiped;
         while (++$cursor < $all_groups->$#*) {
            next if defined($all_groups->[$cursor]);
            $all_groups->[$marker++] = $all_groups->[$cursor];
         }
         splice $all_groups->@*, $marker if $marker < $all_groups->@*;
      }
   }

   my @accounts = map {
      my $group = $group_for{$_};
      [ $group->{name}, sort { $a cmp $b } keys $group->{addresses}->%* ];
   } sort { $a <=> $b } keys %group_for;

   return \@accounts;
}
```

For contrast, in the [Raku][] implementation I chose to ditch the
*stability* and opted for some copying of data around, which I think
improves readability and maintainability. Otherwise, the approach is pretty
much the same: sweep and merge, keeping disjoint addresses.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   my @accounts =
      ['A', 'a1@a.com', 'a2@a.com'],
      ['B', 'b1@b.com'],
      ['A', 'a3@a.com', 'a4@a.com'],
      ['B', 'b2@b.com', 'b1@b.com'],
      ['A', 'a8@a.com'],
      ['A', 'a3@a.com', 'a2@a.com'],
   ;

   for merge-accounts(@accounts) -> $merged {
      put '[', $merged.map({"'$_'"}).join(', '), ']';
   }
}

sub merge-accounts (@accounts) {
   my %alternatives_for;
   for @accounts -> $account {
      my ($name, @addresses) = @$account;
      my $new = { name => $name, addresses => @addresses.Set };

      my @disjoint;
      my $all = %alternatives_for{$name} //= [];
      for @$all -> $candidate {
         if ($new<addresses> ∩ $candidate<addresses>) { # merge
            $new<addresses> = (
               $new<addresses>.keys.Slip,
               $candidate<addresses>.keys.Slip
            ).Set;
         }
         else {
            @disjoint.push: $candidate;
         }
      }
      @disjoint.push: $new;
      %alternatives_for{$name} = @disjoint;
   }
   return %alternatives_for.values».Slip.flat
      .map({[ $_<name>, $_<addresses>.keys.Slip ]})
      .Array;
}
```

All in all, this challenge was a bit more... *challenging* than the average
for me. All of this, of course, thanks to [manwar][]!

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#209]: https://theweeklychallenge.org/blog/perl-weekly-challenge-209/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-209/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[premature optimization]: https://en.wikiquote.org/wiki/Donald_Knuth
