#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;

use Mojo::JSON 'j';
use Mojo::File 'path';
use Mojolicious::Lite;

no warnings qw< experimental::postderef experimental::signatures >;

use constant DEFAULT_FILENAME => 'quotes.json';

my $config = load_config();

get '/' => sub ($c) {
   my $quote = get_quote($config);
   $c->render(
      footer => undef,
      header => undef,
      url => undef,
      title => 'Change Title!',
      template => 'quote',
      $quote->%*,
   );
};

app->start;

sub get_quote ($conf) {
   my $aref = $conf->{quotes};
   return {
      $conf->%*,
      quote => $aref->[rand $aref->@*],
   };
}

sub load_config (@args) {
   my $quotes_path = shift(@args) // get_default_path()
      // die "Can't find a suitable quotes file to serve";
   return j path($quotes_path)->slurp;
}

sub get_default_path {
   for my $dir_candidate ('.', path(__FILE__)->dirname->to_string) {
      my $path = path($dir_candidate)->child(DEFAULT_FILENAME)->to_string;
      return $path if -e $path;
   }
   return;
}

__DATA__

@@ quote.html.ep
%# Starting from boilerplate at
%# https://github.com/lukehaas/HTML5-Minimal-Boilerplate
<!doctype html>
<html lang="en">
   <head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <title><%= $title %></title>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <meta property="og:title" content="<%= $title %>">
      <style type="text/css">
body {
   margin: 0;
   padding: 0;
}
div.wrapper {
   text-size: 10px;
   margin: auto;
   padding: 1em;
   width: 500px;
}
header {
   text-align: center;
}
blockquote#quotation {
   font-family: monospace;
}
main ul {
   text-align: center;
}
main ul li {
   display: inline;
   list-style-type: none;
   padding: 0 0.5em;
}
      </style>
   </head>
   <body>
      <div class="wrapper">
         <header><h1><%= $header // $title %></h1></header>
         <main>
            <blockquote id="quotation"><%= $quote->{text} %></blockquote>
            <ul id="further">
            <% if (defined $quote->{url}) { %>
               <li><a href="<%= $quote->{url} %>">original</a></li>
            <% } %>
            <% if (defined $url) { %>
               <li><a href="<%= $url %>">see also...</a></li>
            <% } %>
               <li><a href="">again</a></li>
            </ul>
         </main>
         <footer>
         </footer>
      </div>
   </body>
</html>