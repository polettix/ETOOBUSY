---
title: Generic Graph Representation
type: post
tags: [ perl, coding, algorithm ]
comment: true
date: 2020-02-23 08:00:00 +0100
preview: true
---

**TL;DR**

> Where we discuss about a generic model for the graph.

I find it very instructive to study [#algorithm][]s, and also to try to code
them in the most generic way possible. I'm not sure why, actually: most of
the times the implementation can be easily tailored to the problem I have,
and sometimes this means just re-implementing the whole thing... but that's
life.

I'll gloss over a lot of pre-conditions here, assuming that you know... what
a [graph][] (in the *graph theory* sense) means.


# Representing the Graph - Generically

To remain general, we should aim for a representation that assumes nothing
about how the algorithm will be used. Will it be objects? Simple hashes?
Arrays? Anything else?

We will just do the following assumptions:

- a *node* is represented by a [Perl][] scalar (this was easy);
- the *nodes* that can be reached from a *node* `X` are in a list that can
  be retrieved through a function.

This should give us a model that is generic enough to use, while still being
simple enough to implement independently of the real graph representation.

# An example?

Let's make an example: suppose that the graph is represented like this:

- *nodes* are strings, representing places;
- *edges* are represented implicitly with a hash of arrays.

Something like this:

```perl
my %graph = (
   airport => [qw< work >],
   home    => [qw< work school >],
   park    => [qw< school >],
   school  => [qw< park home >],
   work    => [qw< home airport >],
);
```

This tells us that we can reach `work` from the `airport`, or that we can
reach both `park` and `home` from `school`. This representation is good for
a very generic graph, including directed graphs.

Our *nodes* in this case are the strings `airport`, `home`, `park`,
`school`, and `work`.  The list associated to each node allows representing
the edges.

In our representation, the following function would allow us to represent
these adjacencies through a function:

```perl
sub graph_dependencies_sub {
   my %graph = @_;
   return sub {
      my ($node) = @_;
      return @{$graph{$node}};
   }
}
my $graph_adjacencies = graph_adjacencies_sub(%graph);
```

Now `$graph_adjacencies` encapsulates our representation of the graph: when
provided a *node*, it gives out the list of *nodes* that can be reached from
it:

```perl
my @nodes_from_home = $graph_adjacencies->('home');
```

# Another example?

We might, of course, start from a different representation for the graph,
e.g. based on objects:

- *nodes* are objects;
- *edges* are represented as a list of adjacent nodes that each node holds.


```perl
package Graph;

sub new {
   my ($package, $name) = @_;
   return bless {name => $name, neighbors => {}}, $package;
};

sub name {
   my $self = shift;
   return $self->{name};
}

sub neighbors {
   my $self = shift;
   return @{$self->{neighbors}};
}

sub add_neighbors {
   my $self = shift;
   $self->{neighbors}{$_->name} = $_ for @_;
   return $self;
}

package main;

my ($airport, $home, $park, $school, $work) =
   map { Graph->new($_) } qw< airport home park school work >;
$airport->add_neighbors($work);
$home->add_neighbors($work, $school);
$park->add_neighbors($school);
$school->add_neighbors($park, $home);
$work->add_neighbors($home, $airport);
```

It's basically the same graph as before, only represented differently.
Again, it's easy to adapt to the generic representation, it's basically just
`Graph::neighbors`:

```perl
my $graph_adjacencies = \&Graph::neighbors;
```

Of course if you intend to inherit from `Graph` this will break, so the more
robust thing to do is to use a wrapper:

```perl
sub graph_dependencies_sub {
   return sub {
      my ($node) = @_;
      return $node->neighbors;
   };
}
my $graph_adjacencies = graph_adjacencies_sub();
```

# Edge lists anyone?

This representation is sub-optimal when edges are represented as stand-alone
elements, e.g.:

- *nodes* are strings;
- *edges* are represented as pairs of nodes in anonymous arrays `[$from, $to]`.

Something like this (for the same graph):

```perl
my @edges = (
   [ 'airport', 'work' ],
   [ 'home', 'work' ],
   [ 'home', 'school' ],
   [ 'park', 'school' ],
   [ 'school', 'park' ],
   [ 'school', 'home' ],
   [ 'work', 'home' ],
   [ 'work', 'airport' ],
);
```

The adaptation in this case is a bit... *clunky*:

```perl
my $graph_adjacencies = sub {
   my ($node) = @_;
   map { $_->[1] } grep { $_->[0] eq $node } @edges;
}
```

Every time... we are iterating through the whole of `@edges`. Of course we
can do some pre-computing:

```perl
sub graph_adjacencies_sub {
   my %graph;
   for my $edge (@_) {
      my ($from, $to) = @$edge;
      $graph{$from} = $to;
   }
   return sub {
      my ($node) = @_;
      return @{$graph{$node}};
   };
}
my $graph_adjacencies = graph_adjacencies_sub(@edges);
```

... at the expense of requiring some more space.

But hey! I promised that the representation would be generic and easy to
adapt to, not that it would solve every problem in the world!

# Summing Up

The representation that we introduced basically requires us to decide on
what we mean by *node* and provide a function that computes the list of
other *nodes* that can be reached from it. It allows us to represent
whatever graph, and it's fairly easy to adapt to... which we will leverage
in the future discussing a few [#algorithm][]s about graphs.

Cheers!

[#algorithm]: {{ '/tagged/#algorithm' | prepend: site.baseurl | prepend: site.url }}
[graph]: https://en.wikipedia.org/wiki/Graph_(discrete_mathematics)
[Perl]: https://www.perl.org/
