#!/usr/bin/env raku
use v6;

sub roll-die (Int:D $sides where * > 0 = 6) { (1 .. $sides).pick }

sub simulation-round () {
   return [+] gather {
      loop {
         my $value = roll-die();
         take $value;
         last if $value < 3;
      }
   }
}

my $N = @*ARGS.shift || 100;
my $total = [+] gather { take simulation-round() for 1 .. $N };
put 'average gain: ', $total / $N;
