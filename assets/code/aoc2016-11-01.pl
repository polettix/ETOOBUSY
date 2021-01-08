#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use autodie;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use File::Basename qw< basename >;
use Data::Dumper; $Data::Dumper::Indent = 1;
use Storable 'dclone';
$|++;

my %floor_idx_of = (
   first => 0,
   second => 1,
   third => 2,
   fourth => 3,
);
my %slot_idx_of = ();
my %floor_for;
my $filename = shift || basename(__FILE__) =~ s{\.pl\z}{.tmp}rmxs;
open my $fh, '<', $filename;
while (<$fh>) {
   my ($floor) = m{\A The \s+ (\S+) \s+ floor \s+ contains \s+}mxs;
   my $floor_idx = $floor_idx_of{$floor};
   while (s{(\S+)-compatible}{}mxs) {
      my $id = scalar keys %slot_idx_of;
      $slot_idx_of{$1} //= 2 * $id + 1;
      $floor_for{m}{$1} =  $floor_idx;
   }
   while (s{(\S+) \s+ generator}{}mxs) {
      $floor_for{g}{$1} = $floor_idx;
   }
}
close $fh;

my $n_slots = scalar(keys %slot_idx_of) * 2 + 1;

my @start = map { [(0) x $n_slots] } 1 .. 4;
$start[0][0] = 1; # elevator
while (my ($element, $floor) = each $floor_for{m}->%*) {
   $start[$floor][$slot_idx_of{$element}] = 1;
}
while (my ($element, $floor) = each $floor_for{g}->%*) {
   $start[$floor][$slot_idx_of{$element} + 1] = 1;
}

my @goal = map { [(0) x $n_slots] } 1 .. 3;
push @goal, [(1) x $n_slots];

my $outcome = dijkstra(
   start => \@start,
   goals => [\@goal],
   distance => sub { 1 },
   successors => \&successors_for,
   identifier => \&id_of,
);
say $outcome->{distance_to}->(\@goal);

sub successors_for ($node) {
   my $cidx = elevator_floor_idx($node);
   my $cfloor = $node->[$cidx];
   my @successors;
   for my $tidx ($cidx - 1, $cidx + 1) {
      next if $tidx < 0 || $#$node < $tidx;
      my $tfloor = $node->[$tidx];
      for my $i (1 .. $#$cfloor) {
         next unless $cfloor->[$i];

         # try to move only this one
         if (my @new = move($node, $cidx, $tidx, $i)) {
            push @successors, \@new;
         }

         # now try to move this one with another one
         for my $j ($i + 1 .. $#$cfloor) {
            next unless $cfloor->[$j];
            if (my @new = move($node, $cidx, $tidx, $i, $j)) {
               push @successors, \@new;
            }
         }
      }
   }
   return @successors;
}

sub move ($state, $cidx, $tidx, $i, $j = undef) {
   my @new = $state->@*; # shallow copy here
   $new[$_] = [$new[$_]->@*] for ($cidx, $tidx); # deep copy here
   for my $slot (0, $i, $j) {
      next unless defined $slot;
      $new[$cidx][$slot] = 0;
      $new[$tidx][$slot] = 1;
   }
   return @new if is_floor_safe($new[$cidx]) && is_floor_safe($new[$tidx]);
   return;
}

sub elevator_floor_idx ($node) {
   for my $candidate (0 .. 4) {
      next unless $node->[$candidate][0];
      return $candidate;
   }
   die "wtf?!?";
}

sub is_floor_safe ($floor) {
   my $ng = grep {$floor->[2 * $_]} 1 .. $#$floor / 2 or return 1;
   for my $midx (1 .. $#$floor / 2) {
      next unless $floor->[$midx * 2 - 1];
      return 0 unless $floor->[$midx * 2];
   }
   return 1;
}

sub id_of { join "\n", '---', reverse map { join '', $_->@*} $_[0]->@* }

sub dijkstra {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< start distance successors >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my ($start, $dist, $succs) = @args{@reqs};
   my $id_of = $args{identifier} || sub { return "$_[0]" };
   my %is_goal = map { $id_of->($_) => 1 } @{$args{goals} || []};
   my $on_goal = scalar(keys %is_goal) ? $args{on_goal} || sub {
      delete $is_goal{$_[0]};
      return scalar keys %is_goal;
   } : undef;

   my $id      = $id_of->($start);
   my $queue   = PriorityQueue->new(
      before => sub { $_[0]{d} < $_[1]{d} },
      id_of  => sub { return $_[0]{id} },
      items => [{v => $start, id => $id, d => 0}],
   );

   my %thread_to = ($id => {d => 0, p => undef, pid => $id});
   while (!$queue->is_empty) {
      my ($ug, $uid, $ud) = @{$queue->dequeue}{qw< v id d >};
      last if $on_goal && $is_goal{$uid} && (!$on_goal->($uid));
      for my $vg ($succs->($ug)) {
         my ($vid, $alt) = ($id_of->($vg), $ud + $dist->($ug, $vg));
         $queue->contains_id($vid)
           ? ($alt >= ($thread_to{$vid}{d} //= $alt + 1))
           : exists($thread_to{$vid})
           and next;
         $queue->enqueue({v => $vg, id => $vid, d => $alt});
         $thread_to{$vid} = {d => $alt, p => $ug, pid => $uid};
      } ## end for my $vg ($succs->($ug...))
   } ## end while (!$queue->is_empty)

   return {
      path_to => sub {
         my ($v) = @_;
         my $vid = $id_of->($v);
         my $thr = $thread_to{$vid} || return; # connected?

         my @retval;
         while ($v) {
            unshift @retval, $v;
            ($v, $vid) = @{$thr}{qw< p pid >};
            $thr = $thread_to{$vid};
         }
         return wantarray ? @retval : \@retval;
      },
      distance_to => sub { ($thread_to{$id_of->($_[0])} || {})->{d} },
   };
} ## end sub dijkstra


package PriorityQueue;  # Adapted from https://algs4.cs.princeton.edu/24pq/
use strict;

sub contains    { return $_[0]->contains_id($_[0]{id_of}->($_[1])) }
sub contains_id { return exists $_[0]{item_of}{$_[1]} }
sub is_empty    { return !$#{$_[0]{items}} }
sub item_of { exists($_[0]{item_of}{$_[1]}) ? $_[0]{item_of}{$_[1]} : () }
sub new;                # see below
sub dequeue { return $_[0]->_remove_kth(1) }
sub enqueue;                # see below
sub remove    { return $_[0]->remove_id($_[0]{id_of}->($_[1])) }
sub remove_id { return $_[0]->_remove_kth($_[0]{pos_of}{$_[1]}) }
sub size      { return $#{$_[0]{items}} }
sub top       { return $_[0]->size ? $_[0]{items}[1] : () }
sub top_id    { return $_[0]->size ? $_[0]{id_of}->($_[0]{items}[1]) : () }

sub new {
   my $package = shift;
   my $self = bless {((@_ && ref($_[0])) ? %{$_[0]} : @_)}, $package;
   $self->{before} ||= sub { return $_[0] < $_[1] };
   $self->{id_of} ||= sub { return ref($_[0]) ? "$_[0]" : $_[0] };
   my $items = $self->{items} || [];
   @{$self}{qw< items pos_of item_of >} = (['-'], {}, {});
   $self->enqueue($_) for @$items;
   return $self;
} ## end sub new

sub enqueue {    # insert + update in one... DWIM
   my ($is, $id) = ($_[0]{items}, $_[0]{id_of}->($_[1]));
   $_[0]{item_of}{$id} = $_[1];    # keep track of this item
   my $k = $_[0]{pos_of}{$id} ||= do { push @$is, $_[1]; $#$is };
   $_[0]->_adjust($k);
   return $id;
} ## end sub enqueue

sub _adjust {                      # assumption: $k <= $#$is
   my ($is, $before, $self, $k) = (@{$_[0]}{qw< items before >}, @_);
   $k = $self->_swap(int($k / 2), $k)
     while ($k > 1) && $before->($is->[$k], $is->[$k / 2]);
   while ((my $j = $k * 2) <= $#$is) {
      ++$j if ($j < $#$is) && $before->($is->[$j + 1], $is->[$j]);
      last if $before->($is->[$k], $is->[$j]);    # parent is OK
      $k = $self->_swap($j, $k);
   }
   return $self;
} ## end sub _adjust

sub _remove_kth {
   my ($is, $self, $k) = ($_[0]{items}, @_);
   die 'no such item' if (!defined $k) || ($k <= 0) || ($k > $#$is);
   $self->_swap($k, $#$is);
   my $r = CORE::pop @$is;
   $self->_adjust($k) if $k <= $#$is;    # no adjust for last element
   my $id = $self->{id_of}->($r);
   delete $self->{$_}{$id} for qw< item_of pos_of >;
   return $r;
} ## end sub _remove_kth

sub _swap {
   my ($self,  $i,      $j)     = @_;
   my ($items, $pos_of, $id_of) = @{$self}{qw< items pos_of id_of >};
   my ($I, $J) = @{$items}[$i, $j] = @{$items}[$j, $i];
   @{$pos_of}{($id_of->($I), $id_of->($J))} = ($i, $j);
   return $i;
} ## end sub _swap
