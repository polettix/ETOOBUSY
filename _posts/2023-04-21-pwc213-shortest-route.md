---
title: PWC213 - Shortest Route
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-04-21 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#213][].
> Enjoy!

# The challenge

> You are given a list of bidirectional routes defining a network of nodes,
> as well as source and destination node numbers.
>
> Write a script to find the route from source to destination that passes
> through fewest nodes.
>
> **Example 1:**
>
>     Input: @routes = ([1,2,6], [5,6,7])
>            $source = 1
>            $destination = 7
>     
>     Output: (1,2,6,7)
>
>     Source (1) is part of route [1,2,6] so the journey looks like 1 -> 2 -> 6
>     then jump to route [5,6,7] and takes the route 6 -> 7.
>     So the final route is (1,2,6,7)
>
> **Example 2:**
>
>     Input: @routes = ([1,2,3], [4,5,6])
>            $source = 2
>            $destination = 5
>
>     Output: -1
>
> **Example 3:**
>
>     Input: @routes = ([1,2,3], [4,5,6], [3,8,9], [7,8])
>            $source = 1
>            $destination = 7
>     Output: (1,2,3,8,7)
>
>     Source (1) is part of route [1,2,3] so the journey looks like 1 -> 2 -> 3
>     then jump to route [3,8,9] and takes the route 3 -> 8
>     then jump to route [7,8] and takes the route 8 -> 7
>     So the final route is (1,2,3,8,7)

# The questions

None, but maybe a curiosity --why are all those called *routes*?

# The solution

Doing a lot of recreational programming made me code ready-made versions of
popular algorithms.

For the [Perl][] solution, we'll leverage the venerable A\*. I know, there's
no good candidate for the heuristic in this case, so it's basically
Dijkstra's algorithm.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

use Data::Dumper;

my @routes = ([1,2,3], [4,5,6], [3,8,9], [7,8]);
my $source = 1;
my $destination = 7;
my $route = shortest_route(\@routes, $source, $destination) // [];
{ local $" = ','; say $route->@* ? "($route->@*)" : -1 }

sub shortest_route ($routes, $src, $dst) {
   my $graph = routes_to_graph($routes);
   return scalar astar(
      start => $src,
      goal  => $dst,
      distance => sub { return 1 },
      successors => sub ($v) { keys $graph->{$v}->%* },
      identifier => sub ($v) { $v },
   );
}

sub routes_to_graph ($routes) {
   my %adjacents_for;
   for my $route ($routes->@*) {
      my $prev = $route->[0];
      for my $i (1 .. $route->$#*) {
         my $curr = $route->[$i];
         $adjacents_for{$prev}{$curr} = $adjacents_for{$curr}{$prev} = 1;
         $prev = $curr;
      }
   }
   return \%adjacents_for;
}

sub astar {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< start goal distance successors >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my ($start, $goal, $dist, $succs) = @args{@reqs};
   my $h     = $args{heuristic}  || $dist;
   my $id_of = $args{identifier} || sub { return "$_[0]" };

   my ($id, $gid) = ($id_of->($start), $id_of->($goal));
   my %node_for = ($id => {value => $start, g => 0});
   my $queue = bless ['-', {id => $id, f => 0}], __PACKAGE__;

   while (!$queue->_is_empty) {
      my $cid = $queue->_dequeue->{id};
      my $cx  = $node_for{$cid};
      next if $cx->{visited}++;

      my $cv = $cx->{value};
      return __unroll($cx, \%node_for) if $cid eq $gid;

      for my $sv ($succs->($cv)) {
         my $sid = $id_of->($sv);
         my $sx = $node_for{$sid} ||= {value => $sv};
         next if $sx->{visited};
         my $g = $cx->{g} + $dist->($cv, $sv);
         next if defined($sx->{g}) && ($g >= $sx->{g});
         @{$sx}{qw< p g >} = ($cid, $g);    # p: id of best "previous"
         $queue->_enqueue({id => $sid, f => $g + $h->($sv, $goal)});
      } ## end for my $sv ($succs->($cv...))
   } ## end while (!$queue->_is_empty)

   return;
} ## end sub astar

sub _dequeue {                              # includes "sink"
   my ($k, $self) = (1, @_);
   my $r = ($#$self > 1) ? (splice @$self, 1, 1, pop @$self) : pop @$self;
   while ((my $j = $k * 2) <= $#$self) {
      ++$j if ($j < $#$self) && ($self->[$j + 1]{f} < $self->[$j]{f});
      last if $self->[$k]{f} < $self->[$j]{f};
      (@{$self}[$j, $k], $k) = (@{$self}[$k, $j], $j);
   }
   return $r;
} ## end sub _dequeue

sub _enqueue {                              # includes "swim"
   my ($self, $node) = @_;
   push @$self, $node;
   my $k = $#$self;
   (@{$self}[$k / 2, $k], $k) = (@{$self}[$k, $k / 2], int($k / 2))
     while ($k > 1) && ($self->[$k]{f} < $self->[$k / 2]{f});
} ## end sub _enqueue

sub _is_empty { return !$#{$_[0]} }

sub __unroll {    # unroll the path from start to goal
   my ($node, $node_for, @path) = ($_[0], $_[1], $_[0]{value});
   while (defined(my $p = $node->{p})) {
      $node = $node_for->{$p};
      unshift @path, $node->{value};
   }
   return wantarray ? @path : \@path;
} ## end sub __unroll
```

For the [Raku][] solution, then, we're using Dijkstra's algorithm:

```raku
#!/usr/bin/env raku
use v6;

sub MAIN {
   my @routes = [1,2,3], [4,5,6], [3,8,9], [7,8];
   my $source = 1;
   my $destination = 6;
   my $route = shortest-route(@routes, $source, $destination) // -1;
   say $route;
}

class Dijkstra { ... }
class PriorityQueue { ... }

sub shortest-route (@routes, $src, $dst) {
   my $graph = routes-to-graph(@routes);
   my $d = Dijkstra.new(
      distance => { $graph{$^a}{$^b} },
      successors => { $graph{$^a}.keys },
      start => $src,
      goals => [ $dst ],
   );
   return $d.path-to($dst);
}

sub routes-to-graph (@routes) {
   my %adjacents_for;
   for @routes -> $route {
      my $prev = $route[0];
      for (1 ..^ @$route) -> $i {
         my $curr = $route[$i];
         %adjacents_for{$prev}{$curr} = %adjacents_for{$curr}{$prev} = 1;
         $prev = $curr;
      }
   }
   return %adjacents_for;
}

class Dijkstra {
   has %!thread-to is built; # thread to a destination
   has $!start     is built;     # starting node
   has &!id-of     is built;     # turn a node into an identifier

   method new (:&distance!, :&successors!, :$start!, :@goals,
         :$more-goals is copy, :&id-of = -> $n { $n.Str }) {
      my %is-goal = @goals.map: { &id-of($_) => 1 };
      $more-goals //= (sub ($id) { %is-goal{$id}:delete; %is-goal.elems })
         if %is-goal.elems;
      my $id = &id-of($start);
      my $queue = PriorityQueue.new(
         before => sub ($a, $b) { $a<d> < $b<d> },
         id-of  => sub ($n) { $n<id> },
         items  => [{v => $start, id => $id, d => 0},],
      );
      my %thr-to = $id => {d => 0, p => Nil, pid => $id};
      while ! $queue.is-empty {
         my ($ug, $uid, $ud) = $queue.dequeue<v id d>;
         for &successors($ug) -> $vg {
            my ($vid, $alt) = &id-of($vg), $ud + &distance($ug, $vg);
            next if ($queue.contains-id($vid)
               ?? ($alt >= (%thr-to{$vid}<d> //= $alt + 1))
               !! (%thr-to{$vid}:exists));
            $queue.enqueue({v => $vg, id => $vid, d => $alt});
            %thr-to{$vid} = {d => $alt, p => $ug, pid => $uid};
         }
      }
      self.bless(thread-to => %thr-to, :&id-of, :$start);
   }

   method path-to ($v is copy) {
      my $vid = &!id-of($v);
      my $thr = %!thread-to{$vid} or return;
      my @retval;
      while defined $v {
         @retval.unshift: $v;
         ($v, $vid) = $thr<p pid>;
         $thr = %!thread-to{$vid};
      }
      return @retval;
   }
   method distance-to ($v) { (%!thread-to{&!id-of($v)} // {})<d> }
}

class PriorityQueue {
   has @!items;
   has %!pos-of;
   has %!item-of;
   has &!before;
   has &!id-of;

   submethod BUILD (
      :&!before = {$^a < $^b},
      :&!id-of  = {~$^a},
      :@items
   ) {
      @!items = '-';
      self.enqueue($_) for @items;
   }

   method contains ($obj --> Bool) { self.contains-id(&!id-of($obj)) }
   method contains-id ($id --> Bool) { %!item-of{$id}:exists }
   method dequeue { self!remove-kth(1) }
   method elems { @!items.end }
   # method enqueue ($obj) <-- see below
   method is-empty { @!items.elems == 1 }
   method item-of ($id) { %!item-of{$id}:exists ?? %!item-of{$id} !! Any }
   method remove ($obj) { self.remove-id(&!id-of($obj)) }
   method remove-id ($id) { self!remove-kth(%!pos-of{$id}) }
   method size  { @!items.end }
   method top { @!items.end ?? @!items[1] !! Any }
   method top-id { @!items.end ?? &!id-of(@!items[1]) !! Any }

   method enqueue ($obj) {
      my $id = &!id-of($obj);
      %!item-of{$id} = $obj; # keep track of this item
      @!items[my $k = %!pos-of{$id} ||= @!items.end + 1] = $obj;
      self!adjust($k);
      return $id;
   }
   method !adjust ($k is copy) { # assumption: $k <= @!items.end
      $k = self!swap(($k / 2).Int, $k)
         while ($k > 1) && &!before(@!items[$k], @!items[$k / 2]);
      while (my $j = $k * 2) <= @!items.end {
         ++$j if ($j < @!items.end) && &!before(@!items[$j+1], @!items[$j]);
         last if &!before(@!items[$k], @!items[$j]); # parent is OK
         $k = self!swap($j, $k);
      }
      return self;
   }
   method !remove-kth (Int:D $k where 0 < $k <= @!items.end) {
      self!swap($k, @!items.end);
      my $r = @!items.pop;
      self!adjust($k) if $k <= @!items.end; # no adjust for last element
      my $id = &!id-of($r);
      %!item-of{$id}:delete;
      %!pos-of{$id}:delete;
      return $r;
   }
   method !swap ($i, $j) {
      my ($I, $J) = @!items[$i, $j] = @!items[$j, $i];
      %!pos-of{&!id-of($I)} = $i;
      %!pos-of{&!id-of($J)} = $j;
      return $i;
   }
}
```

Stay safe and minimal!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#213]: https://theweeklychallenge.org/blog/perl-weekly-challenge-213/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-213/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
