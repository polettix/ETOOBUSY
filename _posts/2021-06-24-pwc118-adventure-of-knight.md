---
title: PWC118 - Adventure of Knight
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-06-24 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#118][].
> Enjoy!

# The challenge

> A knight is restricted to move on an 8×8 chessboard. The knight is
> denoted by `N` and its way of movement is the same as what it is
> defined in Chess. `*` represents an empty square. `x` represents a
> square with treasure.
>
>> The Knight’s movement is unique. It may move two squares vertically
>> and one square horizontally, or two squares horizontally and one
>> square vertically (with both forming the shape of an L).
>
> There are `6 squares` with treasures.
>
> Write a script to find the path such that Knight can capture all
> treasures. The Knight can start from the top-left square.
>
>       a b c d e f g h
>     8 N * * * * * * * 8
>     7 * * * * * * * * 7
>     6 * * * * x * * * 6
>     5 * * * * * * * * 5
>     4 * * x * * * * * 4
>     3 * x * * * * * * 3
>     2 x x * * * * * * 2
>     1 * x * * * * * * 1
>       a b c d e f g h
>
> **BONUS: If you believe that your algorithm can output one of the
> shortest possible path.**

# The questions

There is an overall fuzzyness in this challenge as to the input/output
that is expected and, by extension, to how extensible this should be.

For example, it is not entirely clear whether the provided arrangement
is an *example* or is the only possible input to this challenge. On the
one hand, we're writing code here, so considering that an example would
be fair. Why be explicit about where the knight starts then? Why be
explicit about the number of treasures? Well, it allows framing the
challenge and possibly choosing your algorithms, but still...

Another possible extension would be in the size of the board. This too
is fixed at 8x8, which is another white swan that "confirms" that there
are no black swans. Until you go to Australia, apparently.

# The solution

As anticipated, there is in my opinion a gray area about the input
(fixed or general), so I initially thought of providing a *cheating
solution* in [Raku][] like this:

```
put "a8.N c7 e6.x c5 b3.x c1 a2.x c3 b1.x a3 c4.x b2.x";
put "11 moves";
```

The initial position is marked with `.N` to indicate the knight, while
treasure positions are marked with `.x`.

Well... no. It's *too much cheating* even by my standards.

So we'll do this the hard, long, possibly boring way. Reusing whatever
we can reuse. Which, as of today, means [Perl][] only 🙄

## The plan

This challenge can be seen as a multi-layer one.

At the higher level, we start by assuming that one solution is possible.
So it's a matter of deciding in which order we want to collect the
treasures. Any order will do, although the *bonus* asks for optimality
and we don't want to miss it. So yeah, we need to decide the order of
collection.

To do this, we need data. We need to know how "distant" the knight and
all treasures are from each other (along with the exact moves to go from
one to the other): if we know it, then we can (for example!) try all
possible orderings, calculating the total distance walked (well...
*trot* maybe?) by the knight in the quest and getting the path
associated to the minimum distance.

This leads us to the chessboard and to the knight's peculiar way of
moving, which is our starting point to find the information that we need
for what we just described. We can observe that the problem can be
represented as an undirected graph, where each location in the
chessboard is a vertex, and edges are provided by the knight's move.

At this point, we have "just" to calculate the minimum path between all
pairs of "important" locations, i.e. the knight's starting position as
well as the treasures' locations.

I considered two alternatives:

- using a *single source shortest path* algorithm (like [Dijkstra's
  algorithm][]) applied multiple times (one for each "important" location);
- using an *all sources shortest path* algorithm (like
  [Floyd-Warshall][]), applied once.

To do the selection we should consider several factors, like the number
of treasures in the board. Anyway, I decided to go with
[Floyd-Warshall][] because I have an implementation for both algorithms
([here][da] and [here][fwa]) and this is the one requiring less additional
code. Call me lazy 😎

OK, let's move on!

## Parsing

First of all, we need to understand our input right?

Again, it was tempting to consider the puzzle as... *fixed*, but I
decided to go for a full parser of the input as shown in the example:

```
  a b c d e f g h
8 N * * * * * * * 8
7 * * * * * * * * 7
6 * * * * x * * * 6
5 * * * * * * * * 5
4 * * x * * * * * 4
3 * x * * * * * * 3
2 x x * * * * * * 2
1 * x * * * * * * 1
  a b c d e f g h
```

This is the parser:

```perl
sub parse_input ($fof) {
   my $fh = ref($fof) eq 'GLOB' ? $fof
      : (! ref($fof) && ($fof eq '-')) ? \*STDIN
      : do { open my $x, '<', $fof or die 'file...'; $x };
   my ($knight, @treasures, @row_names, @col_names);
   while (<$fh>) {
      s{\A\s+|\s+\z}{}gmxs;
      my @row = split m{\s+}mxs;

      if (m{\A \s* \d}mxs) {
         my $i = @row_names;
         push @row_names, shift @row;
         pop @row;

         for my $j (0 .. $#row) {
            my $char = $row[$j];
            if ($char eq 'N') {
               die "too many knights\n" if defined $knight;
               $knight = [$j, $i];
            }
            elsif ($char eq 'x') {
               push @treasures, [$j, $i];
            }
            elsif ($char ne '*') {
               die "invalid character '$char'\n";
            }
         }
      }
      elsif (! @col_names) {
         @col_names = @row;
      }
   }
   return {
      knight => $knight,
      treasures => \@treasures,
      row_names => \@row_names,
      col_names => \@col_names,
   };
}
```

I chose to adopt an internal representation based on X and Y
coordinates, with Y increasing downwards. We still keep the right labels
for rows and columns though (see `row_names` and `col_names` in the
output), so that we can translate our internal positions back to the
chessboard representation when we have to print out something.

As we go through the input, we collect the knight's and treasures'
positions, keeping them separated (treasures all go into a single array
`@treasures`).

The first and last line are "special" and carry the names of the
columns. It' easy to tell those two lines from the other ones though,
because all rows of the chessboard start with a digit; this is the sense
of the test `m{\A \s* \d}mxs`.

## Analyzing the chessboard

Now that we have our input as a data structure, it's time to implement
our plan!

In our first step, we analyze the whole chessboard to find the shortest
path from each position to each other position, leveraging the
[Floyd-Warshall][] algorithm. You can find the implementation at
[FloydWarshall.pm][], along with its companion [PriorityQueue.pm][], so
I will spare you with their code here!

At this point, we *just* have to call it:

```perl
my $max_X = $input->{row_names}->$#*;
my $max_Y = $input->{col_names}->$#*;
my $analysis = floyd_warshall(
   distance => sub { 1 },
   identifier => sub ($node) { join ',', $node->@* },
   start => $input->{knight},
   successors => sub ($node) {
      my ($x, $y) = $node->@*;
      my @succs;
      for my $long (-2, +2) {
         for my $short (-1, +1) {
            for my $p ([$long, $short], [$short, $long]) {
               my ($X, $Y) = ($x + $p->[0], $y + $p->[1]);
               push @succs, [$X, $Y]
                  if ($X >= 0) && ($X <= $max_X)
                  && ($Y >= 0) && ($Y <= $max_Y);
            }
         }
      }
      return @succs;
   },
);
```

The mapping facilities `row_names` and `col_names` come handy here to
tell us the exact shape of the chessboard. This makes our solution ready
to be applied to different chessboard sizes, even rectangular ones.

The function requires us to provide a few things:

- `distance` represents the distance function between to *adjacent*
  nodes. In our case, two adjacent nodes are just `1` step apart, so we
  return `1` whatever the input nodes;
- `identifier` is a way to tell two positions apart. As we are using
  anonymous arrays to hold the X and Y positions, we provide an
  identifier by joining the two coordinates with a comma;
- `start` can be any position on the graph. The algorithm can work also
  on graphs that are not connected, so we have to give it one or more
  starting positions; we opt to start from the knight because we have it
  at hand;
- `successors` is the real star here, getting a node (i.e. a position in
  our case) as input and providing back a list of all adjacent nodes.
  This is where we implement the knight's move to find out up to 8
  positions around the starting one, filtering out those that would fall
  outside the board.

The `floyd_warshall` function gives us back an anonymous hash with three
keys:

- `has_path` accepts two positions and tells us if they are connected. In
  our case we will disregard it as chessoboards whose sides are 3 or
  more are always "fully knight-connected";
- `distance` accepts two positions and tells us how far they are, which
  in our case means how many steps are needed to go from one to the
  other;
- `path` gives us the actual path between the two input nodes.

The last two... are what we need for our next steps!

## Find the optimal treasure collecting sequence

Now that we know the cost of going from any location to any other
location, we can move on to figure out the optimal path to collect all
treasures.

Without thinking *too much* to it, it seems something similar to the
[Travelling Salesman Problem][]. It might not be, of course, and there
might be some optimal algorithm that does not require us to look into
all the possible arrangement to find the best one. For sure, there exist
algorithms that would allow us to avoid some calculations by *pruning
the search space* in some way.

In our case, though, we will have to address a few treasures; for 6 of
them, we would have to look into "only" 720 possible arrangements, so a
brute-force attack is fine which means: find all possible ordering of
the treasure locations, calculate their total distance and keep the
minimum.

This said, here's the implementation:

```perl
my $pit = permutations_iterator(items => $input->{treasures});
my ($min_distance, @min_path);
while (my @path = $pit->()) {
   unshift @path, $input->{knight};
   my $distance = sum map {
      $analysis->{distance}->(@path[$_ - 1, $_]);
   } 1 .. $#path;
   ($min_distance, @min_path) = ($distance, @path)
      if ! defined($min_distance) || $distance < $min_distance;
}
```

At the end of this chunk of code, we have the minimum distance in
`$min_distance` and the optimal sequence in `@min_path` (it might not be
the only one, but it's surely optimal).

The `permutations_iterator` is an old friend; should you be curious,
there's [a whole post about it][pit].

## Find the actual steps for treasure collection

The sequence from the previous section is provided in terms of treasure
locations only, so it's like a *macro-plan* of activities, where we
still have to fill-in the details of each single step.

This is easily solved by means of the `path` callback function that we
got back from `floyd_warshall` and still available in
`$analysis->{path}`:

```perl
my @sections = map {
   my @section = $analysis->{path}->(@min_path[$_ - 1, $_]);
   shift @section;
   \@section;
} 1 .. $#min_path;
```

The trick here is to remember that `@min_path` contains the full
sequence of stops, starting from the knight; hence, it's sufficient to
iterate starting from `1` to expand the path between each consecutive
pair (which means using indexes `$_ - 1` and `$_` to get two locations
from the `@min_path` array).

At this point, the array `@sections` contains the expansion of each
*section* of the knight's optimal journey to collect all treasures. Yay,
we're done!

## The complete Perl solution

The complete solution in [Perl][] is a tad too long to include here; you
can find it in the [canonical location][] or in the [local copy here][].

## So... no Raku this time?!?

Well... we can lower our expectations at this point and consider this
simplified setup:

- no parsing - let's assume that the inputs come as we need them;
- no performant algorithms - let's just get the job done in some way;
- fixed size chessboard.

In this case... here we go:

```raku
#!/usr/bin/env raku
use v6;

my $knight = (0, 0);
my @treasures = < 4 2 2 4 1 5 0 6 1 6 1 7 >.map({($^a, $^b)});
my $optimal = @*ARGS ?? True !! False;

my @path = adventure-of-knight($knight, @treasures, $optimal).flat;
@path.join(' ').put;
put @path.end, ' moves';

sub adventure-of-knight ($knight, @treasures, $optimal = False) {
   sub pos-to-pos ($p) {
      state @rows = (1..8).reverse;
      state @cols = 'a' .. 'h';
      return @cols[$p[0]] ~ @rows[$p[1]];
   }
   sub permutation-pass ($knight is copy, @treasures) {
      return gather {
         for @treasures -> $treasure {
            take path-between($knight, $treasure);
            $knight = $treasure;
         }
      }
   }
   my ($min_distance, @min_path);
   for permutations(@treasures) -> @perm {
      my @path = permutation-pass($knight, @perm).flat;
      my $distance = @path.map({$_.end}).sum;
      ($min_distance, @min_path) = ($distance, @path.Slip)
         if ! defined($min_distance) || $distance < $min_distance;
      last unless $optimal;
   }
   return gather {
      take pos-to-pos($knight) ~ '.N';
      for @min_path -> $sequence {
         my ($first, @rest) = @$sequence; # $first will be ignored
         my $treasure = @rest.pop;
         @rest.map({take pos-to-pos($_)});
         take pos-to-pos($treasure) ~ '.x';
      }
   }
}

sub path-between ($start, $stop) {
   sub same { ($^a <<->> $^b).map({$_²}).sum == 0 };
   return () if same($start, $stop);
   my $visited = SetHash.new();
   my @queue = (($start,),);
   while @queue.elems {
      my $subpath = @queue.shift;
      my ($x, $y) = @$subpath[*-1];
      for -2, 2 -> $long {
         for -1, 1 -> $short {
            for ($long, $short), ($short, $long) -> $pair {
               my ($X, $Y) = ($x + $pair[0], $y + $pair[1]);
               next unless (0 <= $X <= 7) && (0 <= $Y <= 7);
               my $pos = "$X,$Y";
               next if $visited{$pos};
               $visited.set($pos);
               my $newpath = ($subpath.Slip, ($X, $Y));
               return $newpath if same(($X, $Y), $stop);
               push @queue, $newpath;
            }
         }
      }
   }
   die 'no way';
}
```

The `path-between` function implements a simple breadth-first search
over the graph represented by the chessboard and the knight's moves, so
it is optimal. On the other hand it is called over and over, so this is
not *efficient*.

The mechanism to try out all the permutations is there in place,
although it can be short-cut by means of the `$optimal` boolean
variable. This means that we can ask to get *one solution* quickly, or
to crunch for more time and get an *optimal solution*.

At each pass, a different permutation is expanded by repeatedly calling
`path-between` for pairs of locations; after that, the new alternative
is available in `@path` and its total distance from beginning to end is
calculated, keeping the best one at each iteration.

The last part is the transformation from the winning solution back to a
sequence that can be easily printed.

This is how it goes:

```shell
$ time raku raku/ch-2.raku
a8.N c7 e6.x c7 a8 b6 c4.x a5 b3.x c1 a2.x b4 d3 b2.x a4 c3 b1.x
16 moves

real	0m0.494s
user	0m0.628s
sys	0m0.176s

$ time raku raku/ch-2.raku optimal
a8.N c7 e6.x c5 b3.x c1 a2.x c3 b1.x a3 c4.x b2.x
11 moves

real	0m21.280s
user	0m20.988s
sys	0m0.352s

$ time perl perl/ch-2.pl 
a8.N c7 e6.x d4 b3.x c1 a2.x c3 b1.x d2 c4.x b2.x
11 moves

real	0m0.114s
user	0m0.108s
sys	0m0.004s
```

> It is interesting that the two solutions are equivalent but not
> exactly the same.

I guess there is some time difference related to the [Perl][]/[Raku][]
difference in maturity, but most of it I hope it's due to the difference
in the algorithms adopted. We might see some evolution in the future...

# Conclusion

I hope this long ride was of interest from someone, otherwise... sorry!

Have fun and stay safe everybody 😄


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#118]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-118/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-118/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Dijkstra's algorithm]: https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
[Floyd-Warshall]: https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm
[da]: https://github.com/polettix/cglib-perl/blob/master/DijkstraFunction.pm
[fwa]: https://github.com/polettix/cglib-perl/blob/master/FloydWarshall.pm
[FloydWarshall.pm]: https://github.com/polettix/cglib-perl/blob/master/FloydWarshall.pm
[PriorityQueue.pm]: https://github.com/polettix/cglib-perl/blob/master/PriorityQueue.pm
[Travelling Salesman Problem]: https://en.wikipedia.org/wiki/Travelling_salesman_problem
[pit]: {{ '/2021/01/30/permutations-iterator/' | prepend: site.baseurl }}
[local copy here]: {{ '/assets/code/pwc118-ch-2.pl' | prepend: site.baseurl }}
[canonical location]: https://github.com/manwar/perlweeklychallenge-club/tree/master/challenge-118/polettix/perl/ch-2.pl
