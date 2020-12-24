---
title: The Definitive Conway's Game of Life
type: post
tags: [ perl, cglib ]
comment: true
date: 2020-12-24 16:25:45 +0100
mathjax: false
published: true
---

**TL;DR**

> My fourth take on [Conway's Game of Life][] this year, amounting to more
> tha 1% of all posts!

Well, the folks at [Advent of Code][] did it again: squeeze the [Conway's
Game of Life][] in a puzzle. This time we're talking about the second part
of [today's puzzle][], where the grid is hexagonal and each cell has six
neighbors instead of 8 as in "normal" play.

So, I thought it best to code a solution *once and for all* and put it
inside [cglib][] (as [ConwayGameOfLife.pm][], of course), so that the next
time *I'll surely* need it there will be an implementation waiting for me.

```
 1 sub conway_game_of_life {
 2    my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
 3    my @reqs = qw< existence_condition neighbors status >;
 4    exists($args{$_}) || die "missing parameter '$_'" for @reqs;
 5    my $iterations = defined $args{iterations} ? $args{iterations} : 1;
 6    my $ash = ref $args{status} eq 'HASH' ? 1
 7       : ref $args{status} eq 'ARRAY' ? 0 : die "invalid status";
 8    my $status = $ash ? $args{status} : {map {$_ => 1} @{$args{status}}};
 9    while ($iterations > 0) {
10       ($status, my $previous, my %count_for) = (\my %next, $status);
11       for my $key (keys %$previous) {
12          $count_for{$key} = 0 unless exists $count_for{$key};
13          $count_for{$_}++ for @{$args{neighbors}->($key)};
14       }
15       while (my ($k, $c) = each %count_for) {
16          $next{$k} = 1 if $args{existence_condition}->($k, $c, $previous);
17       }
18       --$iterations;
19    }
20    $args{status} = $ash ? $status : [keys %$status];
21    return \%args;
22 }
```

In pure [cglib][] spirit, I'm sacrifying a bit readability for compactness.
there is the usual arguments unpacking at the beginning, as well as checks
for obvious wrong inputs (lines 2 through 5).

The "current" status can be provided as a list of keys, or as a hash whose
keys are currently "active" ("alive" in Game of Life parlance). In both
cases, we expect it to be a reference to the data structure, placed in key
`status` (lines 6 and 7), although we then proceed to work with a reference
to a hash (line 8).

The loop iterates the required number of times, defaulting at 1 (line 5).

First of all we count the number of active neighbors for "whatever" cell.
This is in theory an infinite search, but we know that this count will be
non-zero only for neighbors of cells that are currently active, so this
helps a lot (line 11, we only consider the previous positions).

Positions are represented through opaque *keys*. In the counting loop (lines
11 through 14), we call the callback function at `$args{neighbors}` to
calculate the *keys* of the nodes that are neighbor to a given one. This is
the first place where this becomes generic, because here we can potentially
plug whatever proximity rule we want (e.g. arrange as a cube, a hypercube, a
hexagonal grid, ...).

After the counting phase, we do a *reaping* phase, where we analyze all
cells with some counting and run another *callback*
`$args{existence_condition}` to evaluate whether a node should be
active/alive in the next round or not (line 16).

Last, we make sure to return something that is compatible with the input,
setting `$arg{status}` to a reference to a hash or an array depending on
what we received in the first place.

Last (line 21) we return the whole thing, that might be possibly fed to
additional iterations, should we need to do them.

Happy Christmas everybody!

[Conway's Game of Life]: {{ '/2020/04/23/conway-life/' | prepend: site.baseurl }}
[Advent of Code]: https://adventofcode.com/
[today's puzzle]: https://adventofcode.com/2020/day/24
[cglib]: https://github.com/polettix/cglib-perl
[ConwayGameOfLife.pm]: https://github.com/polettix/cglib-perl/blob/master/ConwayGameOfLife.pm
