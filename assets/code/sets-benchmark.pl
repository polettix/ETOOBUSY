#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use List::Util 'shuffle';
use Benchmark qw< :hireswallclock cmpthese >;
use constant DEFAULT_COUNT => -5; # 5 seconds
use constant NEVER  => 7;
use constant ALWAYS => 9;
use constant N_ARRANGEMENTS => 1000;

my $count = shift // DEFAULT_COUNT;

cmpthese($count,
   {
      'Hash'     => wrap('by_hash'),
      'Hash2'    => wrap('by_hash'),
      'Hash SA'  => \&by_hash_standalone,
      'Hash ESA' => \&by_hash_standalone,
      'Array'    => wrap('by_array'),
      'Array SA' => \&by_array_standalone,
      'Bits'     => wrap('by_bits'),
      'Bits SA'  => \&by_bits_standalone,
   }
);

sub wrap ($cb_name) {
   my $cb = __PACKAGE__->can($cb_name);
   return sub {
      my $ti = tests_iterator();
      while (my @input = $ti->()) {
         eval {
            $cb->(@input);
            1;
         } or do {
            warn "$cb_name: $EVAL_ERROR";
         }
      }
      return;
   }
}

sub by_hash (@input) {
   my %set = map { $_ => 1 } @input;
   $set{$input[rand @input]} or die 'fail in provided element';
   $set{+ALWAYS} or die 'fail on ALWAYS';
   $set{+NEVER} and die 'fail on NEVER';
}

sub by_hash2 (@input) {
   my %set;
   @set{@input} = (1) x @input;
   $set{$input[rand @input]} or die 'fail in provided element';
   $set{+ALWAYS} or die 'fail on ALWAYS';
   $set{+NEVER} and die 'fail on NEVER';
}

sub by_array (@input) {
   my @set;
   $set[$_] = 1 for @input;
   $set[$input[rand @input]] or die 'fail in provided element';
   $set[ALWAYS] or die 'fail on ALWAYS';
   $set[NEVER] and die 'fail on NEVER';
}

sub by_bits (@input) {
   my $set = 0;
   $set |= 0x01 << $_ for @input;
   $set & (1 << $input[rand @input]) or die 'fail in provided element';
   $set & (1 << ALWAYS) or die 'fail on ALWAYS';
   $set & (1 << NEVER) and die 'fail on NEVER';
}

sub by_hash_standalone (@input) {
   my $ti = tests_iterator();
   while (my @input = $ti->()) {
      my %set = map { $_ => 1 } @input;
      $set{$input[rand @input]} or die 'fail in provided element';
      $set{+ALWAYS} or die 'fail on ALWAYS';
      $set{+NEVER} and die 'fail on NEVER';
   }
   return;
}

sub by_hash_exists_standalone (@input) {
   my $ti = tests_iterator();
   while (my @input = $ti->()) {
      my %set = map { $_ => 1 } @input;
      exists $set{$input[rand @input]} or die 'fail in provided element';
      exists $set{+ALWAYS} or die 'fail on ALWAYS';
      exists $set{+NEVER} and die 'fail on NEVER';
   }
   return;
}

sub by_array_standalone (@input) {
   my $ti = tests_iterator();
   while (my @input = $ti->()) {
      my @set;
      $set[$_] = 1 for @input;
      $set[$input[rand @input]] or die 'fail in provided element';
      $set[ALWAYS] or die 'fail on ALWAYS';
      $set[NEVER] and die 'fail on NEVER';
   }
   return;
}

sub by_bits_standalone {
   my $ti = tests_iterator();
   while (my @input = $ti->()) {
      my $set = 0;
      $set |= 0x01 << $_ for @input;
      $set & (1 << $input[rand @input]) or die 'fail in provided element';
      $set & (1 << ALWAYS) or die 'fail on ALWAYS';
      $set & (1 << NEVER) and die 'fail on NEVER';
   }
   return;
}

sub tests_iterator {
   state $vs = [ grep { $_ != NEVER } 0 .. 31 ];
   state $tests = [
      map {
         my $n = 3 + int(rand(27));
         [ shuffle(ALWAYS, map { $vs->[rand $vs->@*] } 0 .. $n) ];
      } 1 .. N_ARRANGEMENTS
   ];
   my $i = 0;
   return sub { return $i < N_ARRANGEMENTS ? $tests->[$i++]->@* : () };
}
