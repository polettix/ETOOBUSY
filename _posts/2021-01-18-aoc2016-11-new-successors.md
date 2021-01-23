---
title: 'AoC 2016/11 - New successors'
type: post
tags: [ advent of code, coding, perl, algorithm, AoC 2016-11 ]
comment: true
date: 2021-01-18 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 11][p11] from [2016][aoc2016]: a
> new function for finding successors of a node.

The [New representation][] forces us to update the `successors_for`
function to read the new state layout and, more importantly, produce new
states that adhere to the new convention.

> This is a series of posts, [click here][aoc2016-11-tag] to list them
> all!

[aoc2016-11-tag]: {{ '/tagged#aoc-2016-11' | prepend: site.baseurl }}

While we're at it, anyway, we'll also chip in some enhancements.
Hopefully.

Now buckle up, because it's going to be a longish journey!

# The function

The function implementing the *new* `successors_for` is the following.
As we already introduced, it takes an input state and returns a list of
other states that can be reached from the input one with one *allowed*
move of the elevator.

```
 1 sub successors_for ($state) {
 2    my ($elevator, $generators, $microchips) =
 3      $state->@{qw<elevator generators microchips>};
 4    my $floor_start_mask = 0x01 << 8 * $elevator;
 5    my @retval;
 6    for my $ne ($elevator - 1, $elevator + 1) {
 7       next unless 0 <= $ne && $ne <= 3;
 8 
 9       # I can move (g), (m), (gg), (mm), (gm)*
10       # (gm)* means matching and only 1 move makes sense (prune others)
11       my $outer_mask = $floor_start_mask;
12       my $did_mixed  = 0;
13       for my $outer_element (1 .. $state->{n_elements}) {
14          my @masks_prefix = ();
15          for my $type (qw< generators microchips >)
16          {    # (g), (gg), (m), (mm)
17             if ($state->{$type} & $outer_mask) {
18                push @retval,
19                  new_candidate($state, $ne, @masks_prefix, $outer_mask)
20                  ;    # (x)
21                my $inner_mask = $outer_mask << 1;
22                for my $inner_element (
23                   $outer_element + 1 .. $state->{n_elements})
24                {
25                   if ($state->{$type} & $inner_mask) {
26                      push @retval,
27                        new_candidate($state, $ne, @masks_prefix,
28                         $outer_mask, $inner_mask);    # (xx)
29                   }
30                   $inner_mask <<= 1;
31                } ## end for my $inner_element (...)
32             } ## end if ($state->{$type} & ...)
33             push @masks_prefix, 0, 0;
34          } ## end for my $type (qw< generators microchips >)
35          if (  !$did_mixed
36             && ($generators & $outer_mask)
37             && ($microchips & $outer_mask))
38          {
39             $did_mixed = 1;
40             push @retval,
41               new_candidate($state, $ne, $outer_mask, 0, $outer_mask, 0);
42          } ## end if (!$did_mixed && ($generators...))
43 
44          $outer_mask <<= 1;    # move to next position
45       } ## end for my $outer_element (...)
46    } ## end for my $ne ($elevator -...)
47    return @retval;
48 } ## end sub successors_for ($state)
```

Lines 2 and 3 extract the current relevant values from the input state
to avoid having to do indirections on the input hash reference all the
time.

Line 4 introduces a *mask* that marks the starting position for the
current floor. As you might remember, floors are represented by
individual octets in a 32-bits integer, with the fourth floor (indexed
with `0`) sitting at the least significant octet, and the first floor
(indexed with `3`) sitting at the most significant one. We keep this
variable only because we will need to reuse this starting value in line
11, possibly 2 times. So it's not much the efficiency gain that we get
here, but more the readability (i.e. *let's start from the beginning of
the source floor).

An observation is due at this moment about what movements are possible
and/or meaningful (this is by no means *efficient* but it's at least
*complete* and *correct*). All of the following *possible* moves are of
course subject to additional checking for feasibility (i.e. not frying
up any microchip in the process):

- we might do a single-step move of each item in the source floor. This
  is what the comments refer to as `(g)` and `(m)`;
- we might move two same-typed elements, i.e. two generators (`(gg)`) or
  two microchips (`(mm)`).
- we might move *one* pair of *same-element* items, i.e. one generator
  and one matching microchip (`(gm)*`). If the starting floor has more
  than one such pair, it only makes sense to consider one of them (all
  other alternatives would be isomorphic and a total waste of
  resources). This is why variable `$did_mixed` exists: it tracks
  whether we considered such a pair and skips any following ones for a
  possible elevator move.

These are the only three possibilities. We are explicitly cutting out
the possibility to move two *different-element* items of different type,
e.g. a `plutonium` generator together with a `curium` microchip, because
it would *always* lead to frying the microchip.

Not convinced?

If the starting state is correct, and the microchip is still alive even
in presence of the other-element generator in the same floor, it means
that the microchip is protected by the corresponding generator in that
starting floor. Hence, if we move the microchip away from a floor where
it is protected by its corresponding generator, and we also make sure
that we bring a generator of a different element together with it...
we're going to fry it. Hence, we know *beforehand* it's a bad idea.

So, we're left with the five alternatives described above.

The loop in line 13 (ending online 45, which is pretty long) goes
through each slot in the floors. We leverage the count of number of
elements here, but we might just as well use `8`, possibly at the
expense of some efficiency (but avoiding a bug**COUGH**).

At each slot, we might either decide to focus on microchips or on
generators (we'll save the mixed case for later at line 35, don't
worry), so we iterate over `generators` and `microchips` (line 15) to
consider them. At this point, anyway, it only makes sense to go on if
the specific element type is *present* in the current floor, which is
established by the `$outer_mask`. "Outer" here is in reference to the
fact that we're considering a *outer loop* (lines 15 to 34).

The first thing we do is to consider the single-movement alternantive,
i.e. `(g)` or `(m)` (depending on `$type`). Function `new_candidate`
here is supposed to return either a new neighbor of the current state,
or an empty list if the candidate is not good; hence, the `push` in line
18 might actually *not* push anything in the `@retval` array used to
collect all return values.

Now it's time to consider the `(gg)` or `(mm)` pair (again, depending on
`$type`), which is why we have to setup an *inner loop* (lines 22
through 31). To avoid duplications, we only iterate *after* the current
slot, so we initialize the `$inner_mask` to the following slot with
respect to `$outer_mask` (*following* means doing a left shift, line
21).

Then, again, for the pair to be valid we have to check that the slot in
the *inner loop* is filled in (check at line 25) and in case repeat the
call to `new_candidate` with the same contact we discussed above (i.e.
it returns either a valid new neighbor, or the empty list).

A little word on the `new_candidate` function is due here; its calling
interface is the following:

```
my @new_items = new_candidate(
    $starting_state,         # this has elevator, microchips, ...
    $target_elevator_index,  # where the elevator is heading to
    $generator_1_mask,
    $generator_2_mask,
    $microchip_1_mask,
    $microchip_2_mask,
);
```

The four `*_mask` variables are either *false* (in which case they are
ignored) or contain a valid mask to detect which item to move for the
specific type. At any given call, only *one* or *two* of these masks are
different from a *false* value, accounting for one or two-item
movements.

For this reason, the `@masks_prefix` is initially empty, making sure
that `$outer_mask` in line 19 and `$outer_mask`/`$inner_mask` in line 28
refer to generators.

After the first loop in line 15 ends, it's time for microchips, right?
This is why at the very end of the first loop (line 33) we set
`@masks_prefix` to `(0, 0)`: in this way, the following round will put
`$outer_mask` at line 19 and `$outer_mask`/`$inner_mask` at line 29 in
the positional places for the microchip masks. Maybe it's not that
elegant... but it works.

Line 35 addresses the *mixed* case where we might move one generator
*and* one microchip together. As we already saw, the *must* be of the
same type (which is why lines 36 and 37 do checks against the *same*
`$outer_mask`, i.e. the same slot) and we must not have done this
attempt before for this elevator movement (so we check against
`$did_mixed`, initially set to a *false* value in line 12 and then set
to a *true* value in line 39).

Lines 40 and 41 are two old friends at this point... you will notice
that we're calling `new_candidate` again, this time with the mask for
one generator and one microchip.

Note that we set `$did_mixed` to `1` in line 39 independently of whether
the mixed move is allowed or not. Considering that we're moving two
same-element items, either a pair can be moved, or no pair can be moved.

Line 44, at last, sets the `$outer_mask` on the next item by shifting
our *aiming bit" one position to the left.

After all these loops, array `@retval` collected all possible and
admissible neighbors... so we're only left to return them in line 47.

Whew, what a ride!

# Crafing and checking a new candidate

The `new_candidate` function follows. As a matter of fact, it should
have probably been called `new_neighbor` instead, because this funciton
not only builds up a *candidate*, but it also tests it for *being
feasible*. Anyway.

```
 1 sub new_candidate ($state, $ne, @masks) {
 2    my $target_shift = 8 * ($ne - $state->{elevator});    # shift: <<
 3    my %retval = (elevator => $ne, n_elements => $state->{n_elements});
 4    for my $type (qw< generators microchips >) {
 5       my $v = $state->{$type};
 6       for (1 .. 2) {
 7          my $mask = shift @masks or next;
 8          $v = ($v & ~$mask) | ($mask << $target_shift);
 9       }
10       $retval{$type} = $v;
11    } ## end for my $type (qw< generators microchips >)
12 
13    # now check if the new candidate is viable
14    state $mf4 = 0xFF;
15    state $mf3 = $mf4 << 8;
16    state $mf2 = $mf3 << 8;
17    state $mf1 = $mf2 << 8;
18    my $generators       = $retval{generators};
19    my $naked_microchips = $retval{microchips} & ~$generators;
20    return
21      if ((($naked_microchips & $mf1) && ($generators & $mf1))
22       || (($naked_microchips & $mf2) && ($generators & $mf2))
23       || (($naked_microchips & $mf3) && ($generators & $mf3))
24       || (($naked_microchips & $mf4) && ($generators & $mf4)));
25    return \%retval;
26 } ## end sub new_candidate
```

As we already explained, we can get four masks in, but only two of them
will be actually filled. This is anyway how we *use* this function, but
this is in no way enforced here. Ah... the joy of very specialized
functions!

The input masks allow us to pinpoint a bit in the *starting* floor, but
we also need to know the right mask/bit for the *landing* floor. The
shift will be by 8 bits (because each floor is an octet), while the
direction will be given by the difference between the landing floor
identifier and the source floor identifier. This should explain line 2;
the note refers to the fact that the *sign* of `$target_shift` is such
that it works properly when used with a left shift.

> Did you know it? Doing a left bit shift by a negative amount actually
> yields a right shift by the corresponding positive amount! Amazing!

Varible `%retval` holds our candidate, and is initialized with the same
`n_elements` as the source one (this is an invariant) and with the
elevator in the target floor. This all happens at line 3.

The loop in lines 4 through 11 considers each input mask and does an
action only for *true* ones (line 7, note the `or next` to skip *false*
values). Line 8 is an obfuscated way to say that we set the bit in the
starting floor to `0` (`$v & ~$mask`) and we set the corresponding bit
on the landing floor to `1` (with `| ($mask << $target_shift)`). This
effectively moves the *item* across the two floors.

When we arrive at line 12, our candidate `%retval` is built, but is it
*feasible*? Or would it fry any microchip?

A correct, modular approach here would require us to encapsulate the
check in its own function. Alas, my [Perl][]-fu is a bit rusty, and I'm
not sure that [tail call optimization][] has been implemented at all, so
we'll spare the cost of calling another sub here and just put the check
in the same function. At the end of the day... it's the only place in
the code where we need this check, so it's not a big deal.

Well, maybe it's a big aesthetic deal.

But we have a puzzle to solve here, not to do decorations!

The check in lines 14 to 24 makes sure that *unfeasible* states are
pruned out, returning the empty list (because we're calling
`new_candidate` in list context) if applicable (line 20).

Lines 14 to 17 declare some handy masks to *isolate* each single floor.
This is needed because the check for "lonely microchip in the same floor
as a different-element generator) has to be done floor by floor. as you
can see, these masks are "all bits high" (`0xFF` in line 14), properly
shifted (from floor 4 down to floor 1).

We're testing for generators in our candidate, so our `$generators` in
line 18 is initialized to that value.

Also, we're looking for *naked microchips*, i.e. microchips that have no
corresponding generator in the same floor. This is calculated at line
19, by doing an `&` bitwse operation between the microchips themselves
and the *inverse* of the generators. This is the right way to detect a
*naked microchip*, because...

- if the microchip bit is `0`, the `&` operation will yield `0` (so, no
  naked microchip in that bit position);
- otherwise, if the corresponding generator bit is `1`, *inverting* it
  will yield `0` and the `&` operation will yield `0` as well. This is
  correct, because the microchip is protected by the generator and is
  not *naked*;
- otherwise, we have a `1` in the microchip and a `0` in the generator,
  the output of the expression is `1` in that bit position... and it
  marks a *naked* microchip.

So... it seems that those years studying electronic engineering finally
gave some result, yay!

Now that we located all *naked microchips*, it's time to do the test
floor by floor. In each floor, the *frying* condition is that we have
*naked microchips* in that floor *and* (**boolean and**) we also have
generators in that floor. Naked microchips in a floor without generators
are fine!

So, in the first floor:

- `$naked_microchips & $mf1` tells us whether the floor has *naked
  microchips* or not, while
- `$generators & $mf1` tells us whether the floor has generators or not.

Doing a **boolean and** between these two conditions does the trick for
this floor. Applying the same approach to the other floors (using their
respective mask `$mf2`, `$mf3`, and `$mf4`) does the trick overall.

If we manage to get past the dreaded test in lines 21 to 24...
congratulations, we have a feasible new state, and we can happily return
it in line 24, yay!

# This was an intense ride...

... and we're stopping it here.

No, I'll save running this for the next post, *MBWAHAHAHAAHAH*!

OK, OK.

I'm not *this* bad.

If you're curious, you can try this [local version here][] and see it by
yourself if it works or not.

Until then... *stay safe*!


[p11]: https://adventofcode.com/2016/day/11
[aoc2016]: https://adventofcode.com/2016/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
[New representation]: {{ '/2021/01/12/aoc2016-11-new-representation/' | prepend: site.baseurl }}
[tail call optimization]: https://en.wikipedia.org/wiki/Tail_call
[local version here]: {{ '/assets/code/aoc2016-11-03.pl' | prepend: site.baseurl }}
