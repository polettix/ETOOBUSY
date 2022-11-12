---
title: PWC089 - Magical Matrix
type: post
tags: [ perl weekly challenge, perl ]
comment: true
date: 2020-12-02 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#089][].
> Enjoy!

# The challenge

> Write a script to display matrix as below with numbers `1` - `9`. Please
> make sure numbers are used once.
>
>     [ a b c ]
>     [ d e f ]
>     [ g h i ]
>
> So that it satisfies the following:
>
>     a + b + c = 15
>     d + e + f = 15
>     g + h + i = 15
>     a + d + g = 15
>     b + e + h = 15
>     c + f + i = 15
>     a + e + i = 15
>     c + e + g = 15

# The questions

Well... I guess that *at last* I nagged [manwar][] so much with my silly
questions that the challenge is spotless. (Actually, I love the
incompleteness of the challenges, they stimulate the thought process).

But now that I think of it... here's one! *Why not call it a [Magic
square][]*?!?

What a douche I am!

# The solution

This challenge has many possible solutions.

The super-lazy one is to just look for the solution somewhere, like [Magic
square][] in [Wikipedia][]. From a homework point of view it's a horrible
solution, I know; but from a work perspective I think that reuse is an
excellent skill. So there you have it:

```
#!/usr/bin/env perl
use 5.024;
use warnings;
print {*STDOUT} <<'END';
[ 2 7 6 ]
[ 9 5 1 ]
[ 4 3 8 ]
END
```

On the other side of the spectrum, that very page on the [Magic square][]
provides a lot of interesting hints on *how* to build these squares for any
side size, provided it's different from `2`. So, I guess, this is how this
challenge should be addressed: study these solutions, learn something, find
the most adherent one to the problem and use it.

Alas, the border of this blog is too narrow to do this 🙄

So... I'll take the middle way, the one that does not really challenge my
comfort zone, enjoys a bit of reuse but still it's general enough to adapt
to other situations, like different square sizes.

Yes, I'm talking about [constraint programming][]. We already saw this topic
in this blog (e.g. [More Constraint Programming][]) and it seems like the
*manual case* for it: find some values according to some constraints.

The *engine* for this solution is where I go for reuse:
[ConstraintSolver.pm][] will do the job. So... I'm *only* left with
providing a few things to the solver.

# The main function

```perl
sub magical_matrix ($N) {
   my $N2 = $N * $N;
   my $solution = solve_by_constraints(
      start => {
         not_allocated => { map {$_ => 1} 1 .. $N2 },
         field => [ (0) x $N2 ],
      },
      is_done => sub ($state) { keys($state->{not_allocated}->%*) == 0 },
      constraints => [
         (map {_constraint($N, $_ * $N,  1)} 0 .. ($N - 1)), # rows
         (map {_constraint($N, $_,      $N)} 0 .. ($N - 1)), # cols
         _constraint($N, 0,      $N + 1),                    # main diag
         _constraint($N, $N - 1, $N - 1),                    # other diag
      ],
      search_factory => \&_search_factory,
   ) or die "cannot find a solution for N = $N\n";
   my $field = $solution->{field};
   return [map {[splice $field->@*, 0, $N]} 1 .. $N];
}
```

There are a lot of ways to track the state and *iterate* through the
possibilities; I'm not sure I chose the most efficient one.

There are two data structures in `start` (which is the starting state):
`not_allocated` keeps track of the integers between `1` and `$N * $N` that
were not allocated yet, and `field` tracks their position (`0` means that a
position in the field has not been allocated yet).

The `field` array is easy to treat like a matrix, and in this case even more
so because iterating to find rows, columns and diagonals is only a matter of
coming up with the right distancing between elements in the array.

Figuring out if we're done in `is_done` is easy at this point: just check if
`not_allocated` still has something inside.

The constraints are quite basic and I think that more might be added, to
provide more pruning. Anyway, here I put only the strictly necessary ones,
checking that the sum in the right *subsets* is fine. Each check will
basically be the same, so I use a helper factory function `_constraint` to
generate the target constraint sub, passing the size, the starting position
for the subset, and the distance between elements in the subset. As we will
see, this is all we need to check a row (distance between elements is `1`),
a column (distance between elements is `$N`, or any of the two diagonals
(distance is `$N + 1` or `$N - 1` depending on the diagonal).

Last, the search factory to generate new *guesses* when all constraints are
OK but there's still no solution is handed over to a helper factory
function that we will look at shortly.

# The constraint

As anticipated, each constraint is basically a check on a specific subset of
elements inside the field array, each comprised of `$N` elements.

As an example, the first row starts at index `0` and takes `$N` consecutive
items, i.e. the distance between two close items is `1`. Similarly, the
second column will start at index `1` and items will be distanced by `$N`
inside the `field` array.

For this reason, the factory function needs to know:

- how big the side of the [Magical square][] is, i.e. `$N`;
- the start index `$start`;
- the distance between adjacent indexes `$delta`.

Here is this *factory function*:

```
 1 sub _constraint ($N, $start, $delta) {
 2    my $N2 = $N * $N;
 3    my $target_sum = ($N2 + 1) * $N / 2;
 4    return sub ($state) {
 5 
 6       my ($field, $not_allocated) = $state->@{qw< field not_allocated >};
 7       my $available = $target_sum;
 8       my @missing_indexes;
 9       my $j = 0;
10       while ($j < $N) {
11          my $i = $start + $delta * $j++;
12          if (my $v = $field->[$i]) { $available -= $v }
13          else                      { push @missing_indexes, $i }
14       }
15       die "wrong sum, too much" if $available < 0;
16       my $n_missing = scalar @missing_indexes;
17 
18       if ($n_missing == 0) { # every value is fixed here, check the sum
19          die 'wrong sum' if $available;
20 
21          return 0; # check OK, no change
22       }
23 
24       if ($n_missing == 1) { # fix the one that's left
25          die "invalid residual value"
26             unless exists $not_allocated->{$available};
27          delete $not_allocated->{$available};
28          $field->[$missing_indexes[0]] = $available;
29          return 1; # yes, we did one change
30       }
31 
32       return 0; # no change happened
33    }
34 }
```

Variable `$target_sum` (line 3) is the sum we want in each row, column, and
diagonal. It's the sum of *all* numbers in the [Magical square], divided by
the number of rows (or columns, of course), i.e.:

$$
T = \frac{(N^2 + 1) \cdot N^2}{2} \cdot \frac{1}{N} = \frac{(N^2 + 1) \cdot N}{2}
$$

Variable `$available` (line 7) keeps track of how much *sum* is left in the
specific subset. When all locations have been assigned, this *must* be `0`,
i.e. all of the `$target_sum` has been allocated. Variable
`@missing_indexes` (line 8) tracks which positions in the subset have not
been allocated.

The first loop (lines 10 through 14) scans the subset and:

- removes the value from `$available` if it has been assigned (line 12)
- records the missing index otherwise (line 13).

When done, there's a first sanity check: if the sum is too big then we have
to backtrack (line 15).

At this point we might have that:

- all positions have been allocated (line 18): here we just have to check
  that the sum is correct, i.e. that `$available` has dropped down to `0`
  (line 19);
- only *one* position is left empty (line 24): in this case we know that the
  *only* possible value for this position is `$available`, because otherwise
  the sum will not be right. Hence, we check that this is indeed a value
  that we still have to allocate (line 25 and 26), then remove from the pool
  of unassigned values (line 27), fix in the field (line 28) and return `1`
  to mark that we did some pruning (so that the outer loop will know that
  the constraints have to be run again because of the change).


# Guessing factory

The last piece of code is the *search factory* to guess values for positions
when we have squeezed everything from the constraints.

```
 1 sub _search_factory ($state) {
 2    my %not_allocated = $state->{not_allocated}->%*;
 3    my @candidates = keys %not_allocated;
 4    my $current = undef;
 5 
 6    my @field = $state->{field}->@*;
 7    my $pos = undef;
 8    for my $i (0 .. $#field) {
 9       next if $field[$i];
10       $pos = $i;
11       last;
12    }
13    die 'no unassigned position (WTF?!?)' unless defined $pos;
14 
15
16 
17    return sub ($state) {
18       return 0 unless @candidates;
19 
20       $not_allocated{$current} = 1 if defined $current;
21       $current = shift @candidates;
22       delete $not_allocated{$current};
23 
24       $field[$pos] = $current;
25       $state->{field}   = [@field];
26       $state->{not_allocated} = { %not_allocated };
27
28 
29       return 1;
30    };
31 }
```

The logic is the following:

- we keep a list of `@candidates`, i.e. values that have not been allocated
  yet (line 2 to 4)
- we select an empty position in the field (lines 6 through 13)
- in this specific search, we will iterate all the possible values for the
  `@candidates` inside that specific empty position.

The last bullet is implemented by the returned sub (line 17 through 30),
that takes care to adjust the input `$state` to set the right values.

# A little improvement

This implementation has a lot of space for improvement. For example, there
might be smarter constraints that yield more pruning. Or a better way to
select the empty spot for the search function; or a better way to iterate
through the candidates.

One thing that was apparent, though, is that the check for *good* subsets
was repeated over and over, even when successful. Hence, we can do better.

In the state, we track an additional hash keeping track of subsets that are
*fine* (aptly named `fine`):

```perl
      start => {
         not_allocated => { map {$_ => 1} 1 .. $N2 },
         field => [ (0) x $N2 ],
         fine  => {},
      },
```

In the *search factory*, we make sure that a *copy* of this hash is
available in the sub-searches, but is not propagated during backtracks
(otherwise it would mess things up).

Last, in the constraints, we will use it to cut a constraint if it is
already successful:

```
 1 sub _constraint ($N, $start, $delta) {
 2    my $N2 = $N * $N;
 3    my $target_sum = ($N2 + 1) * $N / 2;
 4    return sub ($state) {
 5       return 0 if $state->{fine}{"$start-$delta"};
 6       my ($field, $not_allocated) = $state->@{qw< field not_allocated >};
 7       my $available = $target_sum;
 8       my @missing_indexes;
 9       my $j = 0;
10       while ($j < $N) {
11          my $i = $start + $delta * $j++;
12          if (my $v = $field->[$i]) { $available -= $v }
13          else                      { push @missing_indexes, $i }
14       }
15       die "wrong sum, too much" if $available < 0;
16       my $n_missing = scalar @missing_indexes;
17 
18       if ($n_missing == 0) { # every value is fixed here, check the sum
19          die 'wrong sum' if $available;
20          $state->{fine}{"$start-$delta"} = 1;
21          return 0; # check OK, no change
22       }
23 
24       if ($n_missing == 1) { # fix the one that's left
25          die "invalid residual value"
26             unless exists $not_allocated->{$available};
27          delete $not_allocated->{$available};
28          $field->[$missing_indexes[0]] = $available;
29          return 1; # yes, we did one change
30       }
31 
32       return 0; # no change happened
33    }
34 }
```

Line 5 exits immediately if the specific constraint is already *fine*, while
line 20 sets the *fine* flag for the specific start/delta combination if the
test is successful and all items have been allocated.

# The whole thing, at the very last!

Here is the whole code, if you're interested:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use Storable 'dclone';

my $M = magical_matrix(shift || 3);
say {*STDOUT} '[ ', (map { sprintf '%3d', $_ } $_->@*), ' ]' for $M->@*;

sub magical_matrix ($N) {
   my $N2 = $N * $N;
   my $solution = solve_by_constraints(
      start => {
         not_allocated => { map {$_ => 1} 1 .. $N2 },
         field => [ (0) x $N2 ],
         fine  => {},
      },
      is_done => sub ($state) { keys($state->{not_allocated}->%*) == 0 },
      constraints => [
         (map {_constraint($N, $_ * $N,  1)} 0 .. ($N - 1)), # rows
         (map {_constraint($N, $_,      $N)} 0 .. ($N - 1)), # cols
         _constraint($N, 0,      $N + 1),                    # main diag
         _constraint($N, $N - 1, $N - 1),                    # other diag
      ],
      search_factory => \&_search_factory,
   ) or die "cannot find a solution for N = $N\n";
   my $field = $solution->{field};
   return [map {[splice $field->@*, 0, $N]} 1 .. $N];
}

sub _search_factory ($state) {
   my %not_allocated = $state->{not_allocated}->%*;
   my @candidates = keys %not_allocated;
   my $current = undef;

   my @field = $state->{field}->@*;
   my $pos = undef;
   for my $i (0 .. $#field) {
      next if $field[$i];
      $pos = $i;
      last;
   }
   die 'no unassigned position (WTF?!?)' unless defined $pos;

   my %fine = $state->{fine}->%*;

   return sub ($state) {
      return 0 unless @candidates;

      $not_allocated{$current} = 1 if defined $current;
      $current = shift @candidates;
      delete $not_allocated{$current};

      $field[$pos] = $current;
      $state->{field}   = [@field];
      $state->{not_allocated} = { %not_allocated };
      $state->{fine} = { %fine };

      return 1;
   };
}

sub _constraint ($N, $start, $delta) {
   my $N2 = $N * $N;
   my $target_sum = ($N2 + 1) * $N / 2;
   return sub ($state) {
      return 0 if $state->{fine}{"$start-$delta"};
      my ($field, $not_allocated) = $state->@{qw< field not_allocated >};
      my $available = $target_sum;
      my @missing_indexes;
      my $j = 0;
      while ($j < $N) {
         my $i = $start + $delta * $j++;
         if (my $v = $field->[$i]) { $available -= $v }
         else                      { push @missing_indexes, $i }
      }
      die "wrong sum, too much" if $available < 0;
      my $n_missing = scalar @missing_indexes;

      if ($n_missing == 0) { # every value is fixed here, check the sum
         die 'wrong sum' if $available;
         $state->{fine}{"$start-$delta"} = 1;
         return 0; # check OK, no change
      }

      if ($n_missing == 1) { # fix the one that's left
         die "invalid residual value"
            unless exists $not_allocated->{$available};
         delete $not_allocated->{$available};
         $field->[$missing_indexes[0]] = $available;
         return 1; # yes, we did one change
      }

      return 0; # no change happened
   }
}

sub solve_by_constraints {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< constraints is_done search_factory start >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my ($constraints, $done, $factory, $state, @stack) = @args{@reqs};
   my $logger = $args{logger} // undef;
   while ('necessary') {
      last if eval {    # eval - constraints might complain loudly...
         $logger->(validating => $state) if $logger;
         my $changed = -1;
         while ($changed != 0) {
            $changed = 0;
            $changed += $_->($state) for @$constraints;
            $logger->(pruned => $state) if $logger;
         } ## end while ($changed != 0)
         $done->($state) || (push(@stack, $factory->($state)) && undef);
      };
      $logger->(backtrack => $state, $@) if $logger;
      while (@stack) {
         last if $stack[-1]->($state);
         pop @stack;
      }
      return unless @stack;
   } ## end while ('necessary')
   return $state;
} ## end sub solve_by_constraints
```

Good by and... stay safe!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#089]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-089/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-089/#TASK2
[Perl]: https://www.perl.org/
[Magic square]: https://en.wikipedia.org/wiki/Magic_square
[Wikipedia]: https://en.wikipedia.org/
[manwar]: http://www.manwar.org/
[constraint programming]: https://www.coursera.org/learn/discrete-optimization/home/week/3/
[More Constraint Programming]: {{ '/2020/04/07/more-constraint-programming/' | prepend: site.baseurl }}
[ConstraintSolver.pod]: https://github.com/polettix/cglib-perl/blob/master/ConstraintSolver.pod
[ConstraintSolver.pm]: https://github.com/polettix/cglib-perl/blob/master/ConstraintSolver.pm
