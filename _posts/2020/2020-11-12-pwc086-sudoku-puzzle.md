---
title: PWC086 - Sudoku Puzzle
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-11-12 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#086][].
> Enjoy!

# The challenge

> You are given Sudoku puzzle (9x9). Write a script to complete the puzzle
> and must respect the following rules: ...

Well... we all know the rules for [Sudoku][], right?!?

# The questions

Questions I would ask here are all related to the input and output formats.
Apart from this... nothing more.

# The solution

There's a ton of solvers for [Sudoku][] and I definitely remember that
there's even a regular expression to do this. I think I know *who* will
propose this solution.

As always, I've gone the good old boring way. Which is recognize that this
is a [constraint programming][] problem, remember that is something I
already addressed in the past in the blog, and that I've written a generic
solver ([More constraint programming][]).

So... it's a matter of filling in the voids! This is the main function:

```perl
sub sudoku_puzzle ($puzzle) {
   $puzzle = dclone($puzzle); # don't mess with the original!
   my %missing; # records how many alternatives are for undecided positions
   for my $row (0 .. 8) {
      for my $col (0 .. 8) {
         next unless $puzzle->[$row][$col] eq '_';
         $puzzle->[$row][$col] = [ 1 .. 9 ];
         $missing{"$row-$col"} = 9;
      }
   }
   my $state = solve_by_constraints(
      is_done => sub ($state) { # we're done when there's no more missing
         return keys $state->{missing}->%* == 0;
      },
      constraints => [
         constraint_group_factory( # rows
            [map { [$_, 0] } 0 .. 8], # outer loop
            [map { [0, $_] } 0 .. 8], # inner loop
         ),
         constraint_group_factory( # columns
            [map { [0, $_] } 0 .. 8], # outer loop
            [map { [$_, 0] } 0 .. 8], # inner loop
         ),
         constraint_group_factory( # 3x3 blocks
            [map { ([$_, 0], [$_, 3], [$_, 6]) } (0, 3, 6)], # outer
            [map { ([$_, 0], [$_, 1], [$_, 2]) } (0, 1, 2)], # inner
         ),
      ],
      search_factory => \&search_factory,
      start => {
         field => $puzzle,
         missing => \%missing,
      },
   );
   return $state->{field};
}
```

It begins with a little preparation, getting all locations where there is
the need for a digit and changing the puzzle to store all possible
alternatives. Apart from this... it's all handed over to
`solve_by_constraints`.

## State tracking data structure

```perl
      start => {
         field => $puzzle,
         missing => \%missing,
      },
```

The state is tracked with an anonymous hash that keeps the following:

- `field` is an Array of Arrays holding the current status of the field.
  Each *undecided* slots are further array references that keep the possible
  candidates for that specific location; this array is pruned by the
  application of conditions or, when no more pruning is possible, is *fixed*
  with an attempt (that might be backtracked later);
- `missing` is a hash whose keys are locations inside the field (in the form
  of a string with the row number, a dash, the column number) and whose
  values are the number of candidates in that location. It only keeps
  locations where a decision might be necessary.


## Ending condition

```perl
      is_done => sub ($state) { # we're done when there's no more missing
         return keys $state->{missing}->%* == 0;
      },
```

The ending condition is simple: when there's nothing left as `missing`,
every location has been assigned a value and the whole thing is compliant to
the rules. Hence, it suffices to check that the `missing` hash reference in
the state is empty.

## Constraints

```perl
      constraints => [
         constraint_group_factory( # rows
            [map { [$_, 0] } 0 .. 8], # outer loop
            [map { [0, $_] } 0 .. 8], # inner loop
         ),
         constraint_group_factory( # columns
            [map { [0, $_] } 0 .. 8], # outer loop
            [map { [$_, 0] } 0 .. 8], # inner loop
         ),
         constraint_group_factory( # 3x3 blocks
            [map { ([$_, 0], [$_, 3], [$_, 6]) } (0, 3, 6)], # outer
            [map { ([$_, 0], [$_, 1], [$_, 2]) } (0, 1, 2)], # inner
         ),
      ],
```

This comes a little cryptic, but bear with me a moment.

Each of the three constraints according to the rules apply to a partition of
the field, where each group contains exactly nine elements. Moreover, there
is some structure: the elements in a set either lie on the same row, or in
the same column, or in a tight 3x3 block.

The juice of the constraint is the same in all cases: make sure that each
group only contains nine distinct values. Hence, apart from figuring out the
items that belong to a group, the check to be done is the same in the three
cases.

This is why we leverage a *factory function* `constraint_group_factory`,
which takes as input a way to do the *right iteration* over the group and
inside each group, and returns a subroutine that does exactly that and
applies the constraint rules. Here is the function:

```
 1 sub constraint_group_factory ($bases, $deltas) {
 2    return sub ($state) {
 3       my $field = $state->{field};
 4       my $changes = 0;
 5       for my $group (0 .. 8) {
 6          my ($row, $col) = $bases->[$group]->@*;
 7          my (%present, @vague);
 8          for my $delta ($deltas->@*) {
 9             my ($r, $c) = ($row + $delta->[0], $col + $delta->[1]);
10             my $item = $field->[$r][$c];
11             if (ref $item) { push @vague, [$r, $c] }
12             elsif ($present{$item}) { die 'overlap!' }
13             else { $present{$item} = 1 }
14          }
15          for my $pair (@vague) {
16             my ($r, $c, @kept) = $pair->@*;
17             for my $candidate ($field->[$r][$c]->@*) {
18                if ($present{$candidate}) { $changes++ }
19                else { push @kept, $candidate }
20             }
21             if (@kept == 0) { die 'no way forward here' }
22             elsif (@kept == 1) {
23                $field->[$r][$c] = $kept[0];
24                $present{$kept[0]} = 1;
25                delete $state->{missing}{"$r-$c"};
26             }
27             else {
28                $field->[$r][$c] = \@kept;
29                $state->{missing}{"$r-$c"} = scalar @kept;
30             }
31          }
32       }
33       return $changes;
34    };
35 }
```

As we said, we use `$bases` and `$deltas` to do the group iteration (via
`$bases`) and the iteration inside a group (via `$deltas`). This will
eventually resolve to iterating by row, by column, or by block.

Lines 7 to 14 do a first pass to collect what the pre-existing constraints
might be, i.e. to collect which items are already `%present` and which are
still undecided (`@vague`). Line 12 is very important, because it makes sure
to complain loudly if there is any overlapping, triggering a backtrack (when
the exception is caught).

After this first pass, it's time to do some pruning by eliminating the
`%present` items from the undecided ones (lines 15 through 32). The list of
remaining candidate for each of the is computed (lines 17 through 20), then
analyzed:

- no more candidates? No solution! (line 21)
- one single candidate? Very well, we have decided something (lines 22
  through 26). Note that we have one more `%present` at this point (line
  24), as well as one less `missing` (line 25);
- still several candidates? No worries, let's keep them (lines 27 through
  30).

Note that line 18 increases the number of *changes* we did in this pass:
this is because we are *removing* a candidate, which is a change!

## Guessing

Alas, constraints in [constraint programming][] can only do *this much*.
Sometimes we can get stuck in a situation where all constraints are
satisfied, and yet we're not on a final solution.

For these cases, the algorithm needs a way to iterate through different
possible *guesses*. In practice, one of the not-yet-decided positions is
selected, and one of the elements inside is tried. If this leads us to a
solution... good for us. If this choice eventually leads us to break our
constraints... we backtrack and try another guess.

In our case, the *guessing* function is the following:

```
 1 sub search_factory ($state) {
 2    my $field = $state->{field};
 3    my %missing = $state->{missing}->%*;
 4    my ($target, $tn);
 5    for my $candidate (keys %missing) {
 6       ($target, $tn) = ($candidate, $missing{$candidate})
 7          if (! defined $target) || ($tn > $missing{$candidate});
 8    }
 9    delete $missing{$target};
10    my ($row, $col) = split m{-}mxs, $target;
11    my @values = $field->[$row][$col]->@*;
12    return sub ($state) {
13       return unless @values;
14       $state->{missing} = { %missing };
15       my $f = $state->{field} = dclone($field);
16       $f->[$row][$col] = shift @values;
17       return 1;
18    },
19 }
```

In [ConstraintSolver.pod][] we are told that our *guessing machine* should
be a function that produces other functions (i.e. a *factory*); the produced
functions will be passed a `$state` and are supposed to modify it according
to the *next item* to be tried at a certain level. Hence, the factory
function and the produced function have to make sure that the state is the
correct one, without making assumption as to what is the previous state -
unless, of course, they *know* they can.

As an example, we get a reference to the `$field` (line 2) and later use it
to restore the field by doing a *deep copy* (line 15) and changing it a bit
to actually make the *guess*.

The hash of missing items is the real star here. We use it to select our
*best* candidate, for whatever *best* means. Here, we are assuming that it's
better to take a candidate with as few remaining choices as possible, hoping
this will reduce the branching factor. Are we too optimistic? I really don't
know.

The selected not-yet-decided cell contains a few items that are put in array
`@values` (line 11); this array is then used *inside* the generated sub to
iterate through all of them (line 13 and line 16).


## Everything together

I guess it's time at this point to get all pieces together:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use Storable qw< dclone >;
use autodie;

sub sudoku_puzzle ($puzzle) {
   $puzzle = dclone($puzzle); # don't mess with the original!
   my %missing; # records how many alternatives are for undecided positions
   for my $row (0 .. 8) {
      for my $col (0 .. 8) {
         next unless $puzzle->[$row][$col] eq '_';
         $puzzle->[$row][$col] = [ 1 .. 9 ];
         $missing{"$row-$col"} = 9;
      }
   }
   my $state = solve_by_constraints(
      is_done => sub ($state) { # we're done when there's no more missing
         return keys $state->{missing}->%* == 0;
      },
      constraints => [
         constraint_group_factory( # rows
            [map { [$_, 0] } 0 .. 8], # outer loop
            [map { [0, $_] } 0 .. 8], # inner loop
         ),
         constraint_group_factory( # columns
            [map { [0, $_] } 0 .. 8], # outer loop
            [map { [$_, 0] } 0 .. 8], # inner loop
         ),
         constraint_group_factory( # 3x3 blocks
            [map { ([$_, 0], [$_, 3], [$_, 6]) } (0, 3, 6)], # outer
            [map { ([$_, 0], [$_, 1], [$_, 2]) } (0, 1, 2)], # inner
         ),
      ],
      search_factory => \&search_factory,
      start => {
         field => $puzzle,
         missing => \%missing,
      },
   );
   return $state->{field};
}

# this sub generates sub references that can be used to iterate over
# different "alternatives" in undecided locations.
sub search_factory ($state) {
   my $field = $state->{field};
   my %missing = $state->{missing}->%*;
   my ($target, $tn);
   for my $candidate (keys %missing) {
      ($target, $tn) = ($candidate, $missing{$candidate})
         if (! defined $target) || ($tn > $missing{$candidate});
   }
   delete $missing{$target};
   my ($row, $col) = split m{-}mxs, $target;
   my @values = $field->[$row][$col]->@*;
   return sub ($state) {
      return unless @values;
      $state->{missing} = { %missing };
      my $f = $state->{field} = dclone($field);
      $f->[$row][$col] = shift @values;
      return 1;
   },
}

sub constraint_group_factory ($bases, $deltas) {
   return sub ($state) {
      my $field = $state->{field};
      my $changes = 0;
      for my $group (0 .. 8) {
         my ($row, $col) = $bases->[$group]->@*;
         my (%present, @vague);
         for my $delta ($deltas->@*) {
            my ($r, $c) = ($row + $delta->[0], $col + $delta->[1]);
            my $item = $field->[$r][$c];
            if (ref $item) { push @vague, [$r, $c] }
            elsif ($present{$item}) { die 'overlap!' }
            else { $present{$item} = 1 }
         }
         for my $pair (@vague) {
            my ($r, $c, @kept) = $pair->@*;
            for my $candidate ($field->[$r][$c]->@*) {
               if ($present{$candidate}) { $changes++ }
               else { push @kept, $candidate }
            }
            if (@kept == 0) { die 'no way forward here' }
            elsif (@kept == 1) {
               $field->[$r][$c] = $kept[0];
               $present{$kept[0]} = 1;
               delete $state->{missing}{"$r-$c"};
            }
            else {
               $field->[$r][$c] = \@kept;
               $state->{missing}{"$r-$c"} = scalar @kept;
            }
         }
      }
      return $changes;
   };
}

# https://github.com/polettix/cglib-perl/blob/master/ConstraintSolver.pm
# https://github.com/polettix/cglib-perl/blob/master/ConstraintSolver.pod
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
         }
         $done->($state) || (push(@stack, $factory->($state)) && undef);
      };
      $logger->(backtrack => $state, $@) if $logger;
      while (@stack) {
         last if $stack[-1]->($state);
         pop @stack;
      }
      return unless @stack;
   }
   return $state;
}

sub debug_puzzle ($puzzle) {
   my $i = 1;
   my $is_solving = 0;
   CHECK_FINAL:
   for my $row ($puzzle->@*) {
      for my $item ($row->@*) {
         next unless ref $item;
         $is_solving = 1;
         last CHECK_FINAL;
      }
   }
   for my $row ($puzzle->@*) {
      my @row = $row->@*;
      my @line = map { join ' ', '[', map ({
            $is_solving ? sprintf('%19s', ref $_ ? "{@$_}" : $_) : $_
         } splice(@row, 0, 3)), ']' } 1 .. 3;
      say {*STDERR} join ' ', @line;
      print {*STDERR} "\n" if ($i % 3 == 0) && ($i < 9);
      ++$i;
   } ## end for my $row ($puzzle->@*)
   return;
}

sub print_puzzle ($puzzle) {
   say {*STDOUT} join ' ', '[', $_->@*, ']' for $puzzle->@*;
   return;
}

sub main ($filename = undef) {
   my $fh =
       !defined($filename) ? \*DATA
     : ($filename eq '-')  ? \*STDIN
     :                       do { open my $fh, '<', $filename; $fh };
   my @puzzle;
   while (<$fh>) {
      my @line = grep { m{[_1-9]} } split m{\s+}mxs;
      die "wrong number of elements in line $.\n" unless @line == 9;
      push @puzzle, \@line;
      last if $. == 9;
   } ## end while (<$fh>)
   die "not enough rows\n" unless @puzzle == 9;
   debug_puzzle(\@puzzle);
   print {*STDERR} "\n";
   my $solved_puzzle = sudoku_puzzle(\@puzzle);
   print_puzzle($solved_puzzle);
   print {*STDERR} "\n";
   debug_puzzle($solved_puzzle);
   return;
} ## end sub main ($filename = undef)

main(@ARGV);

__DATA__
[ _ 4 9 7 3 _ _ _ _ ]
[ _ _ 8 _ _ _ 6 7 _ ]
[ _ 7 6 _ 5 _ _ _ _ ]
[ _ _ 7 9 _ _ _ _ _ ]
[ _ 6 _ _ _ _ _ 5 _ ]
[ _ _ _ _ _ 1 7 _ _ ]
[ _ _ _ _ 1 _ 8 2 _ ]
[ _ 9 1 _ _ _ 4 _ _ ]
[ _ _ _ _ 2 7 5 1 _ ]
```

It's a **huge** program compared to other [Perl Weekly Challenge][]
solutions... but it gave me the opportunity to look back at an interesting
topic and testing the flexibility of [ConstraintSolver.pod][], a piece of
code I wrote some time ago!

Cheers!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#086]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-086/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-086/#TASK2
[Perl]: https://www.perl.org/
[Sudoku]: https://en.wikipedia.org/wiki/Sudoku
[constraint programming]: https://www.coursera.org/learn/discrete-optimization/home/week/3/
[More Constraint Programming]: {{ '/2020/04/07/more-constraint-programming/' | prepend: site.baseurl }}
[ConstraintSolver.pod]: https://github.com/polettix/cglib-perl/blob/master/ConstraintSolver.pod
