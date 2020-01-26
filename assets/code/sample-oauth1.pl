#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use Mojo::UserAgent;
use WWW::OAuth;
use Mojo::JSON 'j';
use Mojo::File 'path';
use Mojo::URL;

my $term   = shift // 'arrow';
my $file   = shift // 'noun-project.json';
my $epbase = Mojo::URL->new('http://api.thenounproject.com');
my $data   = j path($file)->slurp;

my $oauth = WWW::OAuth->new(
   client_id     => $data->{key},
   client_secret => $data->{secret},
);

my $ua = Mojo::UserAgent->new;
$ua->on(start => sub { $oauth->authenticate($_[1]->req) });

my $url =
  $epbase->clone->path("/icons/$term")->query(limit_to_public_domain => 1);
my $res = $ua->get($url)->result;
die $res->message unless $res->is_success;

my $icons = $res->json->{icons};
my $rand_url = $icons->[rand $icons->@*]{icon_url};
$res = $ua->get($rand_url)->result;
die $res->message unless $res->is_success;
$res->save_to("$term.svg");
