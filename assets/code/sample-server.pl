#!/usr/bin/env perl
use Mojolicious::Lite;
get '/' => sub { $_[0]->render(text => "Hello, World!\n") };
app->start;
