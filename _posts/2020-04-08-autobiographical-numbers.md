---
title: Autobiographical numbers
type: post
tags: [ constraint programming, cglib, perl, algorithm ]
comment: true
date: 2020-04-08 08:14:42 +0200
mathjax: true
published: true
---

**TL;DR**

> Let's look at an example of using [ConstraintSolver.pm][], introduced in
> previous post [More constrint programming][].

But first... a confession: I'm quite *not* satisfied with the code that I'm
going to show... but time is a limited resource, so I'll stick with it
because it shows how to use [ConstraintSolver.pm][] on a real problem and
gets the job done.

# Autobiographical numbers?

It *sort of* started from video [Can you solve the Leonardo da Vinci riddle? - Tanya Khovanova][],
but *not really*. It's *complicated* 🙄

Sure, the name *autobiographical numbers* comes from that video. But full
credits have to be given to the *stellar* [Coursera][] online course
[Discrete Optimization][], by [Professor Pascal Van Hentenryck][] and [Dr.
Carleton Coffrin][]. It's taking more time than I anticipated, but it's
totally worth the effort.

In particular, class 6 *CP 6 - redundant constraints, magic series, market
split* in week 3 deals about *magic series*... which are exactly the same
concept.

So, in a nutshell, assume you have an array of $N$ elements, indexed starting
from `0`:

```
  0   1   2   3   4        n-2 n-1 
+---+---+---+---+---+ ... +---+---+
|   |   |   |   |   |     |   |   |
+---+---+---+---+---+ ... +---+---+
```

Each slot in the array is supposed to contain a non-negative integer number,
representing the number of times that the slot's index appears in the array
itself. I guess [Douglas Richard Hofstadter][] would feel at home.

Example? Let's consider $N = 4$, this would be a solution:

```
  0   1   2   3
+---+---+---+---+
| 1 | 2 | 1 | 0 |
+---+---+---+---+
```

As you can see:

- slot `0` contains a $1$, which means that there is exactly one $0$ the
  array. This is true indeed, it's in slot `3`;
- slot `1` contains a $2$, which is consistent with the fact that $1$
  appears exactly two times in the array (in slot `0` and in slot `2`)
- you get the idea for slots `2` and `3` 😅


# Let's solve this!

Let's use [ConstraintSolver.pm][] then:

```perl
 1 sub autobiographical_numbers ($n) {
 2    my $solution = [
 3       map {
 4          +{map { $_ => 1 } 0 .. $n - 1}
 5       } 1 .. $n
 6    ];
 7    my @constraints = map { main->can('constraint_' . $_) }
 8      (qw< basic total_sum weighted_sum last_is_zero >);
 9    my $state = solve_by_constraints(
10       constraints    => \@constraints,
11       is_done        => \&is_done,
12       search_factory => \&explore,
13       start          => {solution => $solution},
14       logger         => ($ENV{VERBOSE} ? \&printout : undef),
15    );
16 } ## end sub autobiographical_numbers ($n)
```

The function `solve_by_constraints` does the overall orchestration, but the
heavy lifting is up to us: think about a data structure, as well as
providing suitable callback functions for the different stages of the
constraints programming search.

Our *solution* starts as an Array of Arrays where each slot contains the
*candidates* for the specific slot. It's initialized with all integers
between $0$ and $N-1$ (both included) because there can be no less than $0$
and no more tha $N-1$, right?

The data structure is a hash reference passed via `start` (line 13). It's a
reference to a hash with a few keys inside. It's initialized with
`solution`, an array reference containing hashes whose keys are the possible
candidate values to occupy the slot. This choice is probably something that
should be revisited, because it makes it easier to look for specific
elements, but it makes it very bad to e.g. look for the minimum or the
maximum element. As anticipated, I'm not exactly proud of this code!

# Accessories

The logger functions is quite simple:

```perl
 1 sub printout ($phase, $status, $exception = undef) {
 2    if ($phase eq 'backtrack') {
 3       if ($@) {
 4          (my $e = $@) =~ s{\sat\s.*?\sline\s[0-9]+\.\s+\z}{}mxs;
 5          $phase = "backtrack[$e]";
 6       }
 7       else {
 8          $phase = 'explore';
 9       }
10    }
11    say $phase, ' => ', encode_json [
12       map {
13          my @candidates = sort { $a <=> $b } keys $_->%*;
14          @candidates > 1 ? \@candidates
15          : @candidates > 0 ? 0 + $candidates[0]
16          : '[]'
17       } $status->{solution}->@*
18    ];
19 } ## end sub printout
```

Each hash reference is transformed back to a sorted array before being put
in the output array, whose reference is encoded with json and then printed
out. The logging function receives the *step* as the first argument, so we
print that too; additionally, when backtracking, the function also receives
the exception that was thrown, so we make sure to include it (line 5) or to
mark this as a simple search start (line 8).

Function `is_done` tells us whether our quest is complete or not:

```perl
sub is_done ($status) {
   return scalar(grep { keys $_->%* > 1 } $status->{solution}->@*) == 0;
}
```

It basically counts the number of slots where we don't have a decision yet
(i.e. where there is more than one alternative), and gives green light only
when all slots are decided.

# Exploring

The `search_factory` function is supposed to give out a sub that iterates
over possible alternative decisions at a specific level in our depth search.
In this case, each level addresses one slot.


```perl
 1 sub explore ($status) {
 2    my $solution = dclone($status->{solution});    # our working solution
 3    my $n        = $solution->@*;
 4 
 5    # this investigates a single slot...
 6    my $slot_id = 0;
 7    while ($slot_id < $n) {
 8       last if keys $solution->[$slot_id]->%* > 1;
 9       $slot_id++;
10    }
11    die 'wtf?!?' if $slot_id >= $n;
12    my @candidates = sort { $a <=> $b } keys $solution->[$slot_id]->%*;
13    my $amount;
14    return sub ($status) {                         # get "next" solution
15       return unless @candidates;
16       $amount = shift @candidates;
17       $status->{solution} = dclone($solution);
18       $status->{solution}[$slot_id] = {$amount => 1};
19       return 1;
20    };
21 } ## end sub explore ($status)
```

This is why line 14 returns a `sub`. In the preparation phase (lines 2 to
13) we set up for a search in a suitable slot, i.e. a slot where we still
have to take a decision (hence the test in line 8). When this slot is found
in `$slot_id`, we take all of its alternatives and populate `@candidates`,
which we will use for iterating different alternatives *inside* the iterator
function.

At each step, we will first of all restore the status as in the beginning
(line 17, to *undo* any pruning that was attempted in the previous step),
then set the specific slot to a hash that has one single choice among the
candidates (line 18). 


# Curious?

We're at the end of this post now... if you're curious about the
constraints, please hold on until the next post, or take a sneak peek at the
[repository][].

**Update** fix code with latest changes, and add reference to repository.


[cglib]: https://github.com/polettix/cglib-perl/
[CodinGame]: https://www.codingame.com/
[ConstraintSolver.pm]: https://github.com/polettix/cglib-perl/blob/master/ConstraintSolver.pm
[ConstraintSolver.pod]: https://github.com/polettix/cglib-perl/blob/master/ConstraintSolver.pod
[More constraint programming]: {{ '/2020/04/07/more-constraint-programming/' | prepend: site.baseurl | prepend: site.url }}
[Can you solve the Leonardo da Vinci riddle? - Tanya Khovanova]: https://www.youtube.com/watch?v=lRfdMiURV4s
[Discrete Optimization]: https://www.coursera.org/learn/discrete-optimization/home/welcome
[Coursera]: https://www.coursera.org/
[Professor Pascal Van Hentenryck]: https://www.coursera.org/instructor/~1289035
[Dr. Carleton Coffrin]: https://www.coursera.org/instructor/carletoncoffrin
[Douglas Richard Hofstadter]: https://en.wikipedia.org/wiki/Douglas_Hofstadter
[repository]: https://gitlab.com/polettix/autobiographical-numbers
