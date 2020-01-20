#!/usr/bin/env perl

# usage: ./df-get-words.pl [<type> [<filename>]]
#
# type can be ADJ (default), NOUN, VERB, ... anything you find in the file
# filename defaults to "language_words.txt", to be found in the current dir

use 5.024;
use warnings;
my $type = quotemeta(shift // 'ADJ');
my $data = do { local (@ARGV, $/) = shift // 'language_words.txt'; <> };
say for $data =~ m{\[$type:(.*?)\]}igmxs;
