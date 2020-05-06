---
title: 'Resolving a (Steiner) design'
type: post
tags: [ algorithm, constraint programming, cglib, coding, perl ]
comment: true
date: 2020-05-06 22:59:24 +0200
mathjax: true
published: true
---

**TL;DR**

> Using our constraint programming solver to resolve a $S(2, 4, 28)$
> design.

In [Steiner design S(2, 4, 28)][] we saw that it's possible to set up a
tournament with the following characteristics:

- 28 participants overall
- 4 players at the table for each match
- 63 matches overall
- each participants competes in exactly 9 matches
- every pair of participants face each other exactly once
- matches can be arranged into *rounds*, so that all players can play in
  a round at the same time and the wait time is limited.

In mathematical terms, this means that we have a [Steiner design S(2, 4,
28)][] that is also resolvable (this is the division into rounds). The
post also includes the *solution* to this problem, so that you can start
playing right away. Go play!

Then, in [Sorting an incidence matrix][] we set the first step to
actually implementing the division into rounds. The program was needed
because there are a lot of $S(2, 4, 28)$ in the linked file, but only 6
of them seem to have proved to be resolvable. Additionally, the linked
file did not have this division into rounds... so we had to find a
solution anyway.

Here, we start looking into the code for finding a rounds arrangement,
leveraging on the function described in [More constraint programming][].

# Preparing the data structure

The incidence matrix has a lot of merits, but for our quest is not the
most straightforward representation - at least, it's not with respect to
the implementation that we will see. Maybe there's a clever way to use
it directly!

So, the first thing will be to arrange matches in a list of hashes, each
containing two keys:

- `participants` will hold a list of the players in the match
- `round` will be either a simple scalar indicating the specific round
  of the match, or an anonymous array containing all possible candidate
  rounds to which it can be assigned.

This is done by the following function:

```perl
 1 sub incidence_to_matches ($incidence) {
 2    my $n_rounds = grep {$_} $incidence->[0]->@*;
 3    my @matches   = map { {participants => [], round => [1 .. $n_rounds]} }
 4       1 .. $incidence->[0]->@*;
 5    my $player_id = 0;
 6    for my $player_data ($incidence->@*) {
 7       ++$player_id;
 8       for my $match_idx (0 .. $#$player_data) {
 9          next unless $player_data->[$match_idx];
10          push $matches[$match_idx]{participants}->@*, $player_id;
11       }
12    } ## end for my $player_data ($incidence...)
13    return ($n_rounds, \@matches);
14 }
```

The number of rounds is not known beforehand, but it's easily counted by
the number of matches of player number 1 (line 2).

The loop in lines 6 to 12 make sure to fill in the `participants`
anonymous array with the right player identifiers. We decided to stick
with starting from 1 for identifiers, just to avoid that anyone feels a
*zero*.

# Resolution main function

The main function where we resolve a design is the following; it
assembles some of the functions we saw so far, and calls more that will
be described in due time:

```perl
 1 sub resolve ($incidence_text) {
 2    my $incidence            = lexi_parse($incidence_text);
 3    my ($n_rounds, $matches) = incidence_to_matches($incidence);
 4    my $n_matches            = $matches->@*;
 5 
 6    # The incidence matrix is lexicographically ordered, which means that
 7    # first player's matches are also the first matches. We can assign them
 8    # to its own round and fix this symmetry for good.
 9    my @pre_assigned_match_idx = map {
10       ($matches->[$_]{round} = $_ + 1) - 1;
11    } 0 .. $n_rounds - 1;
12 
13    # We are now ready to start searching
14    my $state = solve_by_constraints(
15       start => {
16          unassigned            => ($n_matches - $n_rounds),
17          matches               => $matches,
18          last_chosen_match_idx => [@pre_assigned_match_idx],
19       },
20       constraints => [ \&prune ],
21       is_done        => sub ($s) { $s->{unassigned} == 0 },
22       search_factory => \&search_factory,
23    );
24 
25    my %matches_for;
26    push $matches_for{$_->{round}}->@*, $_ for $state->{matches}->@*;
27    return \%matches_for;
28 } ## end sub resolve ($incidence_text)
```

Lines 2 to 4 do the initialization as we saw, and compute how many
matches we should expect.

Lines 6 to 11 do a pre-computing that is a kind of preliminar
application of a constraint. Thanks to the lexicographical ordering that
we have after line 2, we are sure that the first `$n_rounds` matches are
all played by participant `1`. It makes sense to initialize them each
with a different round identifier, because they surely all belong to
different rounds *and* any possible resolution would be a permutation of
this choice. For this reason, we set them to fixed values, getting rid
of the other candidates.

The identifiers of these matches are saved in array
`@pre_assigned_match_idx`, which we will later use to optimize our
pruning activities.

Lines 14 to 23 contain the actual call to the solver. The `start` key
points to our data structure, with the following keys:

- `matches` is the match arrangement we saw in the previous section;
- `unassigned` keeps track of how many matches we still have to assign
  to a specific round. It's initialized to the number of total matches,
  minus the ones for player `1` that we pre-assigned;
- `last_chosen_match_idx` allows the search function to communicate to
  the prune function which match was assigned a tentative value last, in
  order to optimize the pruning function. It is initialized with the
  list of identifiers that we set in the pre-assignment, so that the
  pruning will start from them.

Function `is_done` for the solver is straightforward: if the
`unassigned` count ever drops to 0 we are done (line 21).

The constraints are actually condensed in a single function `prune`, and
the search function (or better, a factory for iterating through the
search alternatives) is encapsulated in its own `search_factory`
function. We will see them in due time.

Last, if the returned `$state` contains a solution, it is re-arranged
(lines 25 to 27) in a way that makes it easy for the caller to figure
out which matches belong to which round. Not surprisingly, this is the
format that [torneo][] would be happy with.


[Steiner design S(2, 4, 28)]: {{ '/2020/05/04/steiner-2-4-28' | prepend: site.baseurl | prepend: site.url }}
[Sorting an incidence matrix]: {{ '/2020/05/05/sorting-an-incidence-matrix' | prepend: site.baseurl | prepend: site.url }}
[More constraint programming]: {{ '/2020/04/07/more-constraint-programming/' | prepend: site.baseurl | prepend: site.url }}
[torneo]: {{ '/2020/05/01/torneo/' | prepend: site.baseurl | prepend: site.url }}
