#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef >;
no warnings qw< experimental::postderef >;
use JSON::PP;

my $data = do { local (@ARGV, $/) = shift // 'language_words.txt'; <> };
my @pairs = $data =~ m{\[(ADJ|NOUN|VERB):(.*?)\]}gmxs;

my %words;
while (@pairs) {
   my ($type, $payload) = splice @pairs, 0, 2;
   if ($type eq 'ADJ') {
      push $words{adjectives}->@*, $payload;
   }
   elsif ($type eq 'NOUN') {
      my ($singular, $plural) = split m{:}mxs, $payload;
      push $words{nouns}->@*,
        {
         singular => $singular,
         plural   => $plural,
        };
   } ## end elsif ($type eq 'NOUN')
   elsif ($type eq 'VERB') {
      my ($pr, $pr3, $pa, $pp, $ing) = split m{:}mxs, $payload;
      push $words{verbs}->@*,
        {
         present    => $pr,
         present_3  => $pr3,
         past       => $pa,
         participle => $pp,
         ing        => $ing,
        };
   } ## end elsif ($type eq 'VERB')
} ## end while (my ($type, $payload...))

say encode_json(\%words);
