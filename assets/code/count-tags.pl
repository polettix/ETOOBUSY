#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

my %count_for;
for my $filename (@ARGV) {
   open my $fh, '<', $filename;
   while (<$fh>) {
      my ($tags) = m{\A tags: \s* \[ (.*?) \]}mxs or next;
      for (split m{,}mxs, $tags) {
         (my $tag = $_) =~ s{\A\s+|\s+\z}{}gmxs;
         $count_for{$tag}++;
      }
   }
}

print "$_: $count_for{$_}\n" for sort {$a cmp $b} keys %count_for;
