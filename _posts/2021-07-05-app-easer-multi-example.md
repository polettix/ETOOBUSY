---
title: 'App::Easer "multilevel" example'
type: post
tags: [ perl, client, terminal ]
series: 'App::Easer'
comment: true
date: 2021-07-05 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Another example on [App-Easer][], this time with additional
> sub-commands.

In last post [App::Easer example][] we took a look at a simple example
where the main "upper level" command had two sub-commands only, i.e. the
ones generated automatically (`help` and `commands`).

In the following example, we extend to add two more sub-commands, `bar`
and `date`.

```perl
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
```

The code above is available as [ex2.pl][].

Let's first take a look at the help for the new commands:

```
$ ./ex2.pl help
this is the main app

Description:
    Yes, this really is the main app

Options:
            foo: 
                 command-line: mandatory string option
                               --foo <value>
                               -f <value>
                 environment : EX2_FOO
                 default     : bar

Sub commands:
            bar: sub command to bar your gaahs
                 (also as: Bar, BAR)
           date: print the current date and time
                 (also as: time, now, wtii)
           help: print a help message
       commands: list sub-commands
```

One thing that we can note is that the two new sub-commands can be
invoked using multiple aliases, e.g. `bar` can also be invoked as `Bar`
or `BAR` (but not `baR`):

```
$ ./ex2.pl bar --what 5 --ever
what what what what what
ever!

$ ./ex2.pl Bar --what 5 --ever
what what what what what
ever!

$ ./ex2.pl BAR --what 5 --ever
what what what what what
ever!

$ ./ex2.pl baR --what 5 --ever
cannot find sub-command 'baR'
```

The sub-commands get their help too:

```
$ ./ex2.pl help BAR
sub command to bar your gaahs

Description:
    What should we say more about sub-command bar?
    
    Have you ever needed to bar something? Now you can!

Can be called as: bar, Bar, BAR

Options:
           what: 
                 command-line: mandatory integer option
                               --what <value>
                               -w <value>
                 environment : EX2_BAR_WHAT
                 default     : 3
           ever: 
                 command-line: boolean option
                               --ever | --no-ever
                               -e
                 environment : EX2_BAR_EVER
                 default     : 0

$ ./ex2.pl help time
print the current date and time

Description:
    Just the plain date from Perl

Can be called as: date, time, now, wtii

Options:
             gm: 
                 command-line: boolean option
                               --gm | --no-gm
                               -g
                 environment : EX2_DATE_GM
                 default     : 0
```

Command `date`/`time`/... shows that descendant commands inherit
option values from parents:

```perl
execute => sub ($global, $conf, $args) {
   my $time = $conf->{gm} ? gmtime() : localtime();
   # $conf->{foo} comes from the parent command!!!
   say "$conf->{foo} says: $time";
},
```

The resulting execution is:

```
$ ./ex2.pl date
bar says: Sat Jul  3 00:08:28 2021

$ ./ex2.pl --foo Oyeee date
Oyeee says: Sat Jul  3 00:08:32 2021
```

So... it seems that [App-Easer][] works fine, now I have to write a ton
of tests!

[App::Easer example]: {{ '/2021/07/04/app-easer-example/' | prepend: site.baseurl }}
[App-Easer]: https://github.com/polettix/App-Easer
[ex2.pl]: {{ '/assets/code/app-easer/example.pl' | prepend: site.baseurl }}
