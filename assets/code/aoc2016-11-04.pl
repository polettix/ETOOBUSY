#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use autodie;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use File::Basename qw< basename >;
use Data::Dumper;
$Data::Dumper::Indent = 1;
use Storable 'dclone';
$|++;

my $generators = 0;
my $microchips = 0;
my $n_elements = 0;

my %floor_shift_of = (
   fourth => 0,
   third  => 8,
   second => 16,
   first  => 24,
);
my %mask_of    = ();
my $next_mask  = 0x1;

my $filename   = shift || basename(__FILE__) =~ s{\.pl\z}{.tmp}rmxs;
open my $fh, '<', $filename;
while (<$fh>) {
   s{\A The \s+ (\S+) \s+ floor \s+ contains \s+}{}mxs;
   my $floor_shift = $floor_shift_of{$1};

   for my $group (
      [qr{(\S+)-compatible}mxs, \$microchips],
      [qr{(\S+) \s+ generator}mxs, \$generators],
   ) {
      while (s{$group->[0]}{}mxs) {
         my $element = $1;
         if (!exists $mask_of{$element}) {
            $mask_of{$element} = $next_mask;
            $next_mask <<= 1;
            ++$n_elements;
         }
         ${$group->[1]} |= ($mask_of{$element} << $floor_shift);
      }
   }
} ## end while (<$fh>)
close $fh;

my $start = {
   elevator   => 3,
   generators => $generators,
   microchips => $microchips,
   n_elements => $n_elements
};

my $goal_strip = 0;
my $last_mask  = $next_mask;
$goal_strip |= $last_mask while $last_mask >>= 1;

my $goal = {
   elevator   => 0,
   generators => $goal_strip,
   microchips => $goal_strip,
   n_elements => $n_elements
};

my $outcome = astar(
   start      => $start,
   goal       => $goal,
   distance   => sub { return 1 },
   heuristic  => \&distance_to_goal,
   identifier => \&id_of,
   successors => \&successors_for,
);
say scalar($outcome->@*) - 1;

sub id_of ($state) {
   state $floor_idx_of = {
      map {
         my $mask = 0x01 << $_;
         map { (($mask << (8 * $_)) => $_) } 0 .. 3;
      } 0 .. 7
   };
   my ($generators, $microchips) = $state->@{qw< generators microchips >};
   return join ',', $state->{elevator},
      map { $_->@* }
      sort { ($a->[0] <=> $b->[0]) || ($a->[1] <=> $b->[1]) }
      map {
         my $mask = 0x01010101 << $_;
         [
            $floor_idx_of->{$generators & $mask},
            $floor_idx_of->{$microchips & $mask},
         ];
      } 0 .. ($state->{n_elements} - 1);
}

sub new_candidate ($state, $ne, @masks) {
   my $target_shift = 8 * ($ne - $state->{elevator});    # shift: <<
   my %retval = (elevator => $ne, n_elements => $state->{n_elements});
   for my $type (qw< generators microchips >) {
      my $v = $state->{$type};
      for (1 .. 2) {
         my $mask = shift @masks or next;
         $v = ($v & ~$mask) | ($mask << $target_shift);
      }
      $retval{$type} = $v;
   } ## end for my $type (qw< generators microchips >)

   # now check if the new candidate is viable
   state $mf4 = 0xFF;
   state $mf3 = $mf4 << 8;
   state $mf2 = $mf3 << 8;
   state $mf1 = $mf2 << 8;
   my $generators       = $retval{generators};
   my $naked_microchips = $retval{microchips} & ~$generators;
   return
     if ((($naked_microchips & $mf1) && ($generators & $mf1))
      || (($naked_microchips & $mf2) && ($generators & $mf2))
      || (($naked_microchips & $mf3) && ($generators & $mf3))
      || (($naked_microchips & $mf4) && ($generators & $mf4)));
   return \%retval;
} ## end sub new_candidate

sub successors_for ($state) {
   my ($elevator, $generators, $microchips) =
     $state->@{qw<elevator generators microchips>};
   my $floor_start_mask = 0x01 << 8 * $state->{elevator};
   my @retval;
   for my $ne ($elevator - 1, $elevator + 1) {
      next unless 0 <= $ne && $ne <= 3;

      # I can move (g), (m), (gg), (mm), (gm)*
      # (gm)* means matching and only 1 move makes sense (prune others)
      my $outer_mask = $floor_start_mask;
      my $did_mixed  = 0;
      for my $outer_element (1 .. $state->{n_elements}) {
         my @masks_prefix = ();
         for my $type (qw< generators microchips >)
         {    # (g), (gg), (m), (mm)
            if ($state->{$type} & $outer_mask) {
               push @retval,
                 new_candidate($state, $ne, @masks_prefix, $outer_mask)
                 ;    # (x)
               my $inner_mask = $outer_mask << 1;
               for my $inner_element (
                  $outer_element + 1 .. $state->{n_elements})
               {
                  if ($state->{$type} & $inner_mask) {
                     push @retval,
                       new_candidate($state, $ne, @masks_prefix,
                        $outer_mask, $inner_mask);    # (xx)
                  }
                  $inner_mask <<= 1;
               } ## end for my $inner_element (...)
            } ## end if ($state->{$type} & ...)
            push @masks_prefix, 0, 0;
         } ## end for my $type (qw< generators microchips >)
         if (  !$did_mixed
            && ($generators & $outer_mask)
            && ($microchips & $outer_mask))
         {
            $did_mixed = 1;
            push @retval,
              new_candidate($state, $ne, $outer_mask, 0, $outer_mask, 0);
         } ## end if (!$did_mixed && ($generators...))

         $outer_mask <<= 1;    # move to next position
      } ## end for my $outer_element (...)
   } ## end for my $ne ($elevator -...)
   return @retval;
} ## end sub successors_for ($state)

sub distance_to_goal ($node, $goal) { # we *know* what the goal is
   my ($g, $m) = $node->@{qw< generators microchips >};
   my $d     = 0;
   my $mask  = 0x80000000;
   my $count = 0;
   for my $w (3, 2, 1) {
      for (1 .. 8) {
         $count++ if $g & $mask;
         $count++ if $m & $mask;
         $mask >>= 1;
      }
      next unless $count;
      $d++;    # at least one movevement with one or two items
      $d += 2 * ($count - 2) if $count > 2;   # back and forth for the rest
   } ## end for my $w (3, 2, 1)
   return $d;
} ## end sub distance_to_goal

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
die 'search failed';
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
