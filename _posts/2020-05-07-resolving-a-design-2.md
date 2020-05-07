---
title: 'Resolving a (Steiner) design - constraints and search'
type: post
tags: [ algorithm, constraint programming, cglib, coding, perl ]
comment: true
date: 2020-05-07 20:47:43 +0200
published: true
mathjax: true
---

**TL;DR**

> We look into the constraints and the search function for resolving
> designs.

In [Resolving a (Steiner) design][] we looked into the generic setup for
running a Constraint Programming search for diving our matches into
rounds. Today we take a look at the two main workhorses: the *pruning
constraint* and the *search function*.

# Pruning the search via constraints

The only constraint that we impose is that each player must play only
once per round, hence a round will always contain matches that have no
overlap with one another.

In this case, when a match is assigned to a round, all other matches
that include the participants in that match are *pruned* of that
specific round. This might possibly lead to:

- no more candidate rounds for a match, which is a violation of the
  search and triggers backtracking (each match *must* be assigned to a
  round);
- one single candidate for a match, which is in itself an assignment
  event and likely to trigger further pruning;
- several candidates, in which case the search should continue.

```perl
 1 sub prune ($state) {
 2    my $q = $state->{last_chosen_match_idx} or return 0;
 3    my @queue   = ref $q ? $q->@* : $q;
 4    my $matches = $state->{matches};
 5    my $changes = 0;
 6    while (@queue) {
 7       my $pruning_match_idx = shift @queue;
 8       my $match             = $matches->[$pruning_match_idx];
 9       my $r                 = $match->{round};
10       die 'whatever' if ref $r;
11       my %p = map { $_ => 1 } $match->{participants}->@*;
12       MATCH:
13       for my $midx (0 .. $#$matches) {
14          next if $midx == $pruning_match_idx;
15          my $m = $matches->[$midx];
16          for my $participant ($m->{participants}->@*) {
17             next unless $p{$participant};
18             if (!ref $m->{round}) {
19                die 'conflict' if $m->{round} == $r;
20                next MATCH;
21             }
22             my @remaining = grep { $_ != $r } $m->{round}->@*;
23             if (@remaining == 0) {
24                die 'unfeasible';
25             }
26             elsif (@remaining == 1) {
27                $m->{round} = $remaining[0];
28                $state->{unassigned}--;
29                push @queue, $midx;
30                ++$changes;
31             } ## end elsif (@remaining == 1)
32             elsif (@remaining < $m->{round}->@*) {
33                $m->{round}->@* = @remaining;
34                ++$changes;
35             }
36             next MATCH;
37          } ## end for my $participant ($m...)
38       } ## end MATCH: for my $midx (0 .. $#$matches)
39    } ## end while (@queue)
40    return $changes;
41 }
```

Pruning happens only if an assignment has been performed. Assignments
that happen externally from `prune` are expected to be passed through an
anonymous array in key `last_chosen_match_idx` of the input argument
`$state` (lines 2 and 3).

All assigned matches are tracked into `@queue`; the pruning goes on as
long as there are items in it, consumed one by one in the same order as
they are assigned (line 7).

Participants in a match are saved in a temporary hash to make detection
of their presence in other matches easy (line 11).

All matches are looked (except the very match we are analyzing, line
14), and only those with the same participant as the one under analysis
are considered (line 17).

If there is a correspondence with an already assigned match (line 18),
we just have to check that the respective rounds are different,
otherwise it would be a violation. Otherwise, the round is pruned from
the candidates list, and a decision is taken accordingly. In particular,
if only one candidate round is left, it is assigned, queueing the match
identifier in `@queue` and decreasing the number of unassigned matches,
which will eventually help us determine whether our quest has come to an
end.

As expected, the return value from this function tells the caller
whether some pruning happened or not.

# Search

The search function is actually a factory function that returns an
iterator to go through different alternative attempts performed in a
specific match.

```perl
 1 sub search_factory ($state) {
 2    my %original = $state->%*;
 3    my ($unassigned, $matches) = @original{qw< unassigned matches >};
 4    for my $i (0 .. $#$matches) {
 5       ref(my $rounds = $matches->[$i]{round}) or next;
 6       my ($j, $max_j) = (-1, $#$rounds);
 7       return sub {
 8          my $matches = $state->{matches} = dclone($matches);
 9          $state->{unassigned}            = $original{unassigned};
10          $state->{last_chosen_match_idx} = $i;
11          if (++$j <= $max_j) {
12             $state->{unassigned}--;
13             $matches->[$i]{round} = $rounds->[$j];
14             return 1;
15          }
16          return 0;
17       };
18    } ## end for my $i (0 .. $#$matches)
19    die 'never reached, hopefully?';
20 }
```

The loop in line 4 looks for the next round that has a possible choice;
in this implementation, the first is good for us, but it might be a
possible point of optimization.

The condition for a not-yet-assigned match is easy: an assigned match
points to a simple scalar, otherwise it holds an array reference (line
5).

The iterator function (lines 7 to 17) makes sure to reset the state to
the search initial state (via `dclone`, line 8); in this way, all
possible assignments are backtracked at once. The number of unassigned
matches is reset as well (line 9).

Then, the next candidate round identifier is selected if possible (line
11), in which case an assignment is performed and recorded (line 12 and
on). For simplicity, the match identifier is always saved in
`last_chosen_match_idx`.

# The whole thing

Curious about the whole program? Wait no more and take it [in this
snippet][code-snippet].

[Resolving a (Steiner) design]: {{ '/2020/05/06/resolving-a-design' | prepend: site.baseurl | prepend: site.url }}
[Sorting an incidence matrix]: {{ '/2020/05/05/sorting-an-incidence-matrix' | prepend: site.baseurl | prepend: site.url }}
[Steiner design S(2, 4, 28)]: {{ '/2020/05/04/steiner-2-4-28' | prepend: site.baseurl | prepend: site.url }}
[More constraint programming]: {{ '/2020/04/07/more-constraint-programming/' | prepend: site.baseurl | prepend: site.url }}
[torneo]: {{ '/2020/05/01/torneo/' | prepend: site.baseurl | prepend: site.url }}
[code-snippet]: https://gitlab.com/polettix/notechs/snippets/1974669
