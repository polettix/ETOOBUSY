#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub int_sums_iterator ($N, $max = undef) {
   if ($N < 1) {
      my @retvals = ([]);
      return sub { shift @retvals };
   }
   $max //= $N;
   my $first = $N < $max ? $N : $max;
   my $rit   = undef;
   return sub {
      my @retval;
      while ($first > 0) {
         $rit //= int_sums_iterator($N - $first, $first);
         if (my $rest = $rit->()) {
            return [$first, $rest->@*];
         }
         ($first, $rit) = ($first - 1, undef);
      }
      return;
   }
}

sub expander ($it) { return sub { return ($it->() // [])->@* } }

sub int_sums_recursive ($N, $max = undef, $indent = 0) {
   return ([]) unless $N;
   my $I = '  ' x $indent;
   $max = $N if ! defined($max) || $max > $N;
   my @retval;
   for my $first (reverse 1 .. $max) {
      push @retval, [$first, $_->@*]
         for int_sums_recursive($N - $first, $first, $indent + 1);
   }
   return @retval;
}

sub compactify ($it) {
   return sub {
      my $list = $it->() or return;
      my @retval;
      for my $item ($list->@*) {
         if (@retval && $item == $retval[-1][1]) {
            $retval[-1][0]++;
         }
         else {
            push @retval, [1, $item];
         }
      }
      return \@retval;
   }
}

sub combinations_iterator ($k, @items) {
   my @indexes = (0 .. ($k - 1));
   my $n = @items;
   return sub {
      return unless @indexes;
      my (@combination, @remaining);
      my $j = 0;
      for my $i (0 .. ($n - 1)) {
         if ($j < $k && $i == $indexes[$j]) {
            push @combination, $items[$i];
            ++$j;
         }
         else {
            push @remaining, $items[$i];
         }
      }
      for my $incc (reverse(-1, 0 .. ($k - 1))) {
         if ($incc < 0) {
            @indexes = (); # finished!
         }
         elsif ((my $v = $indexes[$incc]) < $incc - $k + $n) {
            $indexes[$_] = ++$v for $incc .. ($k - 1);
            last;
         }
      }
      return (\@combination, \@remaining);
   }
}

sub equalsets_partition_iterator ($k, @items) {
   if ($k == 1) { # there's only one way to do this... let's do it!
      my @retval = map { [$_] } @items;
      return sub {
         (my @rv, @retval) = @retval;
         return @rv;
      };
   }
   if ($k == @items) {
      my @retvals = ([@items]);
      return sub { @retvals ? shift @retvals : () };
   }
   my @leader = shift @items;
   my $cit = combinations_iterator($k - 1, @items);
   my $rit;
   return sub {
      return unless $cit;
      while ('necessary') {
         $rit //= do {
            my ($lref, $rref) = $cit->() or do {
               $cit = undef;
               return;
            };
            splice @leader, 1; # keep first item (only)
            push @leader, $lref->@*;
            equalsets_partition_iterator($k, $rref->@*);
         };
         my @sequence = $rit->() or do {
            $rit = undef;
            next;
         };
         return ([@leader], @sequence);
      }
   };
}

sub differsets_partition_iterator ($sizs, @items) {
   my ($fs, @sizes) = $sizs->@*;
   return equalsets_partition_iterator($fs->[1], @items)
      if @sizes == 0;
   my $cit = combinations_iterator($fs->[0] * $fs->[1], @items);
   my ($leader_it, $rest_it);
   my @leader;
   my $rref; # "rest" after leader
   return sub {
      return unless $cit;
      while ('necessary') {
         $leader_it //= do {
            (my $lref, $rref) = $cit->() or do {
               $cit = undef;
               return;
            };
            equalsets_partition_iterator($fs->[1], $lref->@*);
         };
         $rest_it //= do {
            @leader = $leader_it->() or do {
               $leader_it = undef;
               redo;
            };
            differsets_partition_iterator(\@sizes, $rref->@*);
         };
         my @sequence = $rest_it->() or do {
            $rest_it = undef;
            redo;
         };
         return (@leader, @sequence);
      }
   };
}

sub all_partitions_iterator (@items) {
   my $sit = compactify(int_sums_iterator(scalar @items));
   my $ssit;
   return sub {
      while ('necessary') {
         $ssit //= do {
            my $arrangement = $sit->() or return;
            #use Data::Dumper; say Dumper $arrangement;
            differsets_partition_iterator($arrangement, @items);
         };
         my @sequence = $ssit->() or do {
            $ssit = undef;
            redo;
         };
         return @sequence;
      }
   }
}

my @items = @ARGV ? @ARGV : qw< a b c >;
my $it = all_partitions_iterator(@items);
while (my @seq = $it->()) {
   printf "{ %s }\n", join(', ', map { "{$_->@*}" } @seq);
}
