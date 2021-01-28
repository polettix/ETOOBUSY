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
use List::Util qw< min >;
$|++;

my @maze;
my @locations;

my $filename = shift || basename(__FILE__) =~ s{\.pl\z}{.tmp}rmxs;
open my $fh, '<', $filename;
while (<$fh>) {
   chomp;
   push @maze, [split m{}mxs];
   for my $x (0 .. $maze[-1]->$#*) {
      next unless $maze[-1][$x] =~ /\d/;
      $locations[$maze[-1][$x]] = [$x, $#maze];
   }
}
close $fh;

my @distance_between;
for my $i (0 .. $#locations) {
   for my $j ($i .. $#locations) {
      $distance_between[$i][$j] = $distance_between[$j][$i]
         = $i == $j ? 0 : distance_between(\@maze, @locations[$i, $j]);
   }
}

my $perms = permutations_iterator(items => [1 .. $#locations]);
my @min_ds;
while (my @perm = $perms->()) {
   for my $bounds ([0, [0], []], [1, [0], [0]]) {
      my ($id, $pre, $post) = $bounds->@*;
      my @full = ($pre->@*, @perm, $post->@*);
      my $previous = shift @full;
      my $dist = 0;
      for my $current (@full) {
         $dist += $distance_between[$previous][$current];
         $previous = $current;
      }
      $min_ds[$id] = $dist if (! defined $min_ds[$id]) || ($min_ds[$id] > $dist);
   }
}
say "@min_ds";

sub distance_between ($maze, $from, $to) {
   astar(
      start => $from,
      goal  => $to,
      identifier => sub ($n) { join ',', $n->@* },
      distance   => sub { 1 },
      heuristic  => sub ($p, $q) {
         return abs($p->[0] - $q->[0]) + abs($p->[1] - $q->[1]);
      },
      successors => sub ($n) {
         grep { $maze->[$_->[1]][$_->[0]] ne '#' }
         map { [$n->[0] + $_->[0], $n->[1] + $_->[1]] }
         ([-1, 0], [1, 0], [0, -1], [0, 1]);
      }
   )->$#*;
}

sub permutations_iterator {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   exists($args{items}) || die "missing parameter 'items'";
   my ($items, $filter) = @args{qw< items filter >};
   my @indexes = 0 .. $#$items;
   my @stack = (0) x @indexes;
   my $sp = undef;
   return sub {
      if (! defined $sp) { $sp = 0 }
      else {
         while ($sp < @indexes) {
            if ($stack[$sp] < $sp) {
               my $other = $sp % 2 ? $stack[$sp] : 0;
               @indexes[$sp, $other] = @indexes[$other, $sp];
               $stack[$sp]++;
               $sp = 0;
               last;
            }
            else {
               $stack[$sp++] = 0;
            }
         }
      }
      return if $sp >= @indexes;
      return $filter ? $filter->(@{$items}[@indexes])
         : wantarray ? @{$items}[@indexes] : [@{$items}[@indexes]];
   }
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
