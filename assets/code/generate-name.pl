#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use JSON::PP 'decode_json';

my $words = read_json(shift // 'words.json');
my $pair = generate_pair($words);
say join ' ', $pair->@*;

sub generate_pair ($words) {
   my $noun_hash = $words->{nouns}[rand $words->{nouns}->@*];
   my @alts = grep {defined && length} values $noun_hash->%*;
   my $term = $alts[rand @alts];

   my @adjectives = (
      $words->{adjectives}->@*,
      map { $_->@{qw< participle ing >} } $words->{verbs}->@*,
   );
   my $adjective = $adjectives[rand @adjectives];

   return [$adjective, $term];
}

sub read_json ($filepath) {
   open my $fh, '<', $filepath or die "open('$filepath'): $!\n";
   my $text = do { local $/; <$fh> };
   return decode_json $text;
}