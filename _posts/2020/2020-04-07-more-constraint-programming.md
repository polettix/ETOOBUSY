---
title: More constraint programming
type: post
tags: [ algorithm, constraint programming, cglib, coding, perl ]
comment: true
date: 2020-04-07 00:01:45 +0200
published: true
---

**TL;DR**

> Inspired by the train of posts about [aquarium][] (see the last one here:
> [Aquarium - exploiting redundant constraints][]), I decided to encapsulate
> a tiny constraint programming support function in [cglib][] (my
> copy-and-paste library for [CodinGame][]).

And you can find it where you think: [ConstraintSolver.pm][].

Let's take a look at the function:

```perl
 1 sub solve_by_constraints {
 2    my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
 3    my @reqs = qw< constraints is_done search_factory start >;
 4    exists($args{$_}) || die "missing parameter '$_'" for @reqs;
 5    my ($constraints, $done, $factory, $state, @stack) = @args{@reqs};
 6    my $logger = $args{logger} // undef;
 7    while ('necessary') {
 8       last if eval {    # eval - constraints might complain loudly...
 9          $logger->(validating => $state) if $logger;
10          my $changed = -1;
11          while ($changed != 0) {
12             $changed = 0;
13             $changed += $_->($state) for @$constraints;
14             $logger->(pruned => $state) if $logger;
15          } ## end while ($changed != 0)
16          $done->($state) || (push(@stack, $factory->($state)) && undef);
17       };
18       $logger->(backtrack => $state, $@) if $logger;
19       while (@stack) {
20          last if $stack[-1]->($state);
21          pop @stack;
22       }
23       return unless @stack;
24    } ## end while ('necessary')
25    return $state;
26 } ## end sub solve_by_constraints
```

Parameters unfolding (lines 2..6) is the same as described in the past: some
arguments are mandatory and an exception is thrown if they are missing. The
only pseudo-clever (read: less readable) concession to conciseness is the
definition of `@stack` in line 5: it gets no value, hence it starts empty
(as it is supposed to be).

The whole function is basically a loop that tries hard to find a solution or
bails out if it's not possible (line 23). In this case, `undef` is returned
to signal this error condition.

Lines 8 to 17 are executed in a *protected* environment because the
constraints might complain loudly about the specific condition. This is part
of the API for constraints: if anything is not fine, just throw an
exception.

Constraints are handled in lines 10 to 15. The sub-loop goes on until
constraints are no more capable of pruning away unneeded branches, which is
tracked by `$changed`. This is another aspect of the constraints API: they
are supposed to return `0` if no pruning happened, or a positive value if
some pruning happened (arguably, the number of modifications performed, but
it's not a hard and fast rule).

When constraints pruning is over, two mutually exclusive conditions might
happen:

- the search is complete and `$state` contains a solution. In this case,
  line 16 returns a true value (the *or* side is ignored) and the outer loop
  will be exited (remember `last if ...` in line 8). Well done! From there
  we jump to line 25 and we're done;

- the search is still *not* complete. In this case, line 16 will return
  `undef`, but only *after* pushing a new *exploration* function on the
  stack. `$factory`'s API, in fact, is to return a sub reference that will
  provide successive search hypotheses to investigate at a certain point of
  the investigation.

In the latter case, the search is not over and the *backtrack* in lines 18
to 23 kicks in. I know, I know... the very first time is not really
*backtracking*, but we have to do exactly the same operations, so why not?
Moreover, it's possible to understand whether it's the first time we call
the iterator, or it is a real backtracking, by looking at the third
parameter of the invoked logger function: upon backtracking it will contain
the exception!

If we find something more to investigate (line 20) then we can continue,
otherwise `@stack` will be depleted and we will return... *nothing* (line
23).

This is the skeleton... if you want to use it, you have to provide the
*meat*! Look at [ConstraintSolver.pod][] to look at the API, and wait some
more time... for an example 🙄 Until next time... happy coding!


**Update**: aligned code to latest version, which includes the exception in
invoking the logger upon backtracking.

[aquarium]: https://www.puzzle-aquarium.com/
[Aquarium - exploiting redundant constraints]: {{ '/2020/04/06/aquarium-redundancy/' | prepend: site.baseurl | prepend: site.url }}
[cglib]: https://github.com/polettix/cglib-perl/
[CodinGame]: https://www.codingame.com/
[ConstraintSolver.pm]: https://github.com/polettix/cglib-perl/blob/master/ConstraintSolver.pm
[ConstraintSolver.pod]: https://github.com/polettix/cglib-perl/blob/master/ConstraintSolver.pod
