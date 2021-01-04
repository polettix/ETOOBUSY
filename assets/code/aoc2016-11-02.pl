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
my $elevator_floor = 0; # default
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
   $elevator_floor = $floor_idx if m{the \s+ elevator}mxs;
}
close $fh;

my $n_slots = scalar(keys %slot_idx_of) * 2 + 1;

my @start = map { [(0) x $n_slots] } 1 .. 4;
$start[$elevator_floor][0] = 1; # elevator
while (my ($element, $floor) = each $floor_for{m}->%*) {
   $start[$floor][$slot_idx_of{$element}] = 1;
}
while (my ($element, $floor) = each $floor_for{g}->%*) {
   $start[$floor][$slot_idx_of{$element} + 1] = 1;
}

my @goal = map { [(0) x $n_slots] } 1 .. 3;
push @goal, [(1) x $n_slots];

my $outcome2 = astar(
   start => [@start],
   goal  => [@goal],
   distance => sub { return 1 },
   heuristic => sub ($v, $goal) {
      my $d = 0;
      for my $fid (0 .. 2) {
         my $weight = 3 - $fid;
         $d += $weight * scalar grep {$_} $v->[$fid]->@*;
      }
      return $d;
   },
   identifier => \&id_of,
   successors => \&successors_for,
);
say scalar($outcome2->@*) - 1;

sub successors_for ($node) {
   my $cidx = elevator_floor_idx($node);
   my $cfloor = $node->[$cidx];
   my @successors;
   my $double_paired = 0;
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
            my $matching = ($i + 1 == $j) && ($i % 2);
            next if $double_paired && $matching;
            if (my @new = move($node, $cidx, $tidx, $i, $j)) {
               push @successors, \@new;
               $double_paired = 1 if $matching;
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
   state %memo;
   my $fid = join '', $floor->@*;
   if (! exists $memo{$fid}) {
      $memo{$fid} = 1;
      if (grep {$floor->[2 * $_]} 1 .. $#$floor / 2) {
         for my $midx (1 .. $#$floor / 2) {
            if ($floor->[$midx * 2 - 1] && !$floor->[$midx * 2]) {
               $memo{$fid} = 0;
               last;
            }
         }
      }
   }
   return $memo{$fid};
}

sub id_of { join "\n", '---', reverse map { join '', $_->@*} $_[0]->@* }

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
