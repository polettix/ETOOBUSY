#!/usr/bin/env perl
use v5.24;
use experimental 'signatures';
use App::Easer 'run';
my $app = {
   commands => {
      MAIN => {
         name        => 'main app',
         help        => 'this is the main app',
         description => 'Yes, this really is the main app',
         options     => [
            {
               name        => 'foo',
               description => 'option foo!',
               getopt      => 'foo|f=s',
               environment => 'FOO',
               default     => 'bar',
            },
         ],
         execute => sub ($global, $conf, $args) {
            my $foo = $conf->{foo};
            say "Hello, $foo!";
            return 0;
         },
         'default-child' => '',    # run execute by default
      },
   },
};
exit run($app, [@ARGV]);
