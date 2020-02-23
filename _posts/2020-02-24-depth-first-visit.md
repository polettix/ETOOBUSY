---
title: Depth First Visit of a Graph
type: post
tags: [ perl, algorithm, coding ]
comment: true
date: 2020-02-24 08:00:00 +0100
published: false
---

**TL;DR**

> One fundamental [#algorithm][] for visiting graphs.

One [#algorithm][] implemented in [cglib-perl][] is the depth-first visit of
a graph. The implementation leverages the graph representation explained in
the previous post [Generic Graph Representation][], i.e. *nodes* are
considered (mostly) opaque scalars and the relationships between *nodes* are
encapsulated in a function.

# Implementation

This implementation is... dense (see [DepthFirstVisit.pm][]):

```perl
 1 sub depth_first_visit {
 2    my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
 3    my @reqs = qw< start successors >;
 4    exists($args{$_}) || die "missing parameter '$_'" for @reqs;
 5    my ($start, $succs) = @args{@reqs};
 6    my $id_of = $args{identifier} || sub { return "$_[0]" };
 7    my $pre_action  = $args{pre_action} || undef;
 8    my $post_action = $args{post_action} || undef;
 9    my $skip_action = $args{skip_action} || undef;
10    my %adjacents = ($id_of->($start) => [$succs->($start)]);
11    my @stack = ([$start, undef]);
12    $pre_action->($start, undef) if $pre_action;
13    while (@stack) {
14       my ($v, $pred) = @{$stack[-1]}; # "peek"
15       my $vid = $id_of->($v);
16       if (@{$adjacents{$vid}}) {
17          my $w = shift @{$adjacents{$vid}};
18          my $wid = $id_of->($w);
19          if (exists $adjacents{$wid}) { # already visited
20             $skip_action->($w, $v) if $skip_action;
21          }
22          else {                         # new node to be visited
23             $adjacents{$wid} = [$succs->($w)];
24             push @stack, [$w, $v];
25             $pre_action->($w, $v) if $pre_action;
26          }
27       }
28       else {
29          $post_action->($v, $pred) if $post_action;
30          pop @stack;
31       } # finished with this frame
32    }
33    return unless defined wantarray; # don't bother with void context
34    return keys %adjacents if wantarray;
35    return [keys %adjacents] if defined wantarray;
36 }
```

The function assumes that it will receive key-value pairs, either in a list
or in a hash reference. Line 2 takes care to normalize the inputs into
`%args`.

Lines 3 and 4 validate the input parameters: `start` and `successors` are
mandatory and the function will complain if they are not present in `%args`.

Lines 5 to 9 get the inputs or set defaults for the relevant actors in the
algorithm. During the visit, three actions can be performed:

- `pre_action` happens on a node as soon as it is discovered/visited (the
  two concepts overlap because this function implements a *depth-first*
  visit of the graph);
- `skip_action` happens when an already visited node is discovered again,
  should you need to track this;
- `post_action` happens when the algorithm is about to leave a node.

All nodes are tracked by their *identifier*. By default, the stringification
of the node is the identifier (line 6), but of course you can provide your
own action (e.g. to extract a field in a hash).

Hash `%adjacents` is used to track the adjacencies of the visited nodes and
doubles down to make sure that we don't visit the same node multiple times.
It is initialized with the starting node (line 10), which is also put in the
`@stack` that is used for the visit (line 11) and of course passed to
`pre_action` if defined.

Variable `@stack` helps track the visit to the graph without resorting to
recursion. As long as there are items, the top one will be taken and worked
on. Items inside are anonymous arrays that contain two items: a *node* and,
when possible, the *node* from where it was discovered. For this reason, the
very first pair has `undef` in this second position (line 11).

During the iteration, the last (i.e. *top*) element is considered, while
still keeping it in the stack (line 14). In a *depth-first* visit, we only
get rid of an item when we are finished with all its adjacencies, i.e. it
has to be kept in the stack for all that time. This gives us `$v` (the
*node* we are visiting) and `$pred` (the node from which we discovered `$v`
in the first place, if defined).

Tracking of adjacencies is performed through `%adjacents`, indexed through
*node identifiers* as computed by `$id_of` (line 10 and line 15) and
containing a list of adjacents for each node, that is progressively consumed
until it's empty. When this happens, it means that all adjacents for a
*node* have been visited, and we can get rid of the *node* itself.

For this reason, the test in line 16 checks for the number of adjacents
present for identifier `$vid`: if there are still nodes in the array, then
the first adjacent is considered (line 17) and acted upon: its identifier is
computed (line 18), then it is checked for already having been considered as
an adjacent from another node (line 19) and, in case, the `skip_action` is
triggered. If not already discovered, then it is added to `%adjacents` with
a list of successors, and a new element is pushed on the stack for the next
iteration. At this time, the `pre_action` is fired, because the node has
just been discovered.

When the list of adjacents for a node recorded in `%adjacents` is completely
emptied, we enter the `else` branch in line 28. Here, it's time to get rid
of the node `$v`: the `post_action` is executed (if any), and the item is
definitely removed from `@stack`. This node `$v` will never enter the
`@queue` again, anyway, because it is still associated with an (empty)
anonymous array in `%adjacents`.

When the loop is over, `pre_action`, `skip_action`, and `post_action` have
been called in due time. The function will anyway return a list of visited
nodes, either as a plain list (line 34) or as an anonymous array (line 35).

# Documentation

You don't have to re-read through the explanation of *how* it works to be
able and use `depth_first_search`. There's some documentation in
[DepthFirstVisit.pod][], with an hopefully clear SYNOPSIS section that
should get you started in no time.

# Conclusion

I don't know how many times I've used [DepthFirstVisit.pm][], copying and
pasting in [CodinGame][]... but I know it's been more than once. If you're
looking for something similar... be my guest!


[#algorithm]: {{ '/tagged/#algorithm' | prepend: site.baseurl | prepend: site.url }}
[Generic Graph Representation]: {{ '/2020/02/23/generic-graph-representation/' | prepend: site.baseurl | prepend: site.url }}
[cglib-perl]: https://github.com/polettix/cglib-perl
[DepthFirstVisit.pm]: https://github.com/polettix/cglib-perl/blob/master/DepthFirstVisit.pm
[DepthFirstVisit.pod]: https://github.com/polettix/cglib-perl/blob/master/DepthFirstVisit.pod
[CodinGame]: https://www.codingame.com/
