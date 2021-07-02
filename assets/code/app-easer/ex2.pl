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
               environment => 'EX2_FOO',
               default     => 'bar',
            },
         ],
         execute => sub ($global, $conf, $args) {
            my $foo = $conf->{foo};
            say "Hello, $foo!";
            return 0;
         },
         'default-child' => '',    # run execute by default
         children => [qw< bar date >],
      },
      bar => {
         name => 'bar',
         supports => [qw< bar Bar BAR >],
         help => 'sub command to bar your gaahs',
         description => <<'END',
What should we say more about sub-command bar?

Have you ever needed to bar something? Now you can!
END
         options => [
            {
               getopt => 'what|w=i',
               description => 'number of times to say what',
               environment => 'EX2_BAR_WHAT',
               default => 3,
            },
            {
               getopt => 'ever|e!',
               description => 'say ever at the end or not',
               environment => 'EX2_BAR_EVER',
               default => 0,
            }
         ],
         'default-child' => '',
         'no-auto' => '*',
         execute => sub ($global, $conf, $args) {
            say join ' ', ('what') x $conf->{what};
            say 'ever!' if $conf->{ever};
            return 0;
         },
      },
      date => {
         supports => [qw< date time now wtii >],
         help => 'print the current date and time',
         description => 'Just the plain date from Perl',
         options => [
            {
               getopt => 'gm|g!',
               description => 'print in GMT instead of local',
               environment => 'EX2_DATE_GM',
               default => 0,
            },
         ],
         'default-child' => '',
         'no-auto' => '*',
         execute => sub ($global, $conf, $args) {
            my $time = $conf->{gm} ? gmtime() : localtime();
            # $conf->{foo} comes from the parent command!!!
            say "$conf->{foo} says: $time";
         },
      },
   },
};
exit run($app, [@ARGV]);
