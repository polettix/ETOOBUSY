#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use Mojo::JSON 'j';
use Mojo::File 'path';
use MojoX::Twitter;

my $id = shift // '1215710451343904768';

my $credentials = j path('twitter-credentials.json')->slurp;
my $client      = MojoX::Twitter->new(
   consumer_key        => $credentials->{'api-key'},
   consumer_secret     => $credentials->{'api-secret-key'},
   access_token        => $credentials->{'access-token'},
   access_token_secret => $credentials->{'access-token-secret'},
);
my $tweets = get_tweets_since($client, $id);
say j $tweets;

sub get_tweets_since ($client, $id) {
   my $tweet = $client->request(    # needed to get the user
      GET => "statuses/show/$id",
      {tweet_mode => 'extended'}
   );
   my @tweets;
   my %options = (
      user_id    => $tweet->{user}{id},
      since_id   => $id,
      count      => 200,                  # max value possible
      tweet_mode => 'extended',
   );
   while ('necessary') {
      my $chunk =
        $client->request(GET => 'statuses/user_timeline', \%options);
      my @chunk = sort { $a->{id} <=> $b->{id} } $chunk->@*;
      pop @chunk if exists $options{max_id};    # remove duplicate
      last unless @chunk;                       # no more available
      $options{max_id} = $chunk[0]{id};         # remark for next iteration
      unshift @tweets, @chunk;                  # older ones in front
   } ## end while ('necessary')
   unshift @tweets, $tweet;                     # the starting one...
   return \@tweets;
} ## end sub get_tweets_since
