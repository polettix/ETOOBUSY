---
title: 'App::Easer example'
type: post
tags: [ perl, client, terminal ]
series: 'App::Easer'
comment: true
date: 2021-07-04 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> An example usage of [App-Easer][].

In previous post [App::Easer][previous] I introduced [App-Easer][], a
module to ease the implementation of command-line utilities that want to
take a *hierarchical* approach.

Let's see an example, straight from the SYNOPSIS:

```perl
#!/usr/bin/env perl
use v5.24;
use App::Easer 'run';
my $app = {
   commands => {
      MAIN => {
         name => 'main app',
         help => 'this is the main app',
         description => 'Yes, this really is the main app',
         options => [
            {
               name => 'foo',
               description => 'option foo!',
               getopt => 'foo|f=s',
               environment => 'FOO',
               default => 'bar',
            },
         ],
         execute => sub ($global, $conf, $args) {
            my $foo = $conf->{foo};
            say "Hello, $foo!";
            return 0;
         },
         'default-child' => '', # run execute by default
      },
   },
};
exit run($app, [@ARGV]);
```

Let's save this as [example.pl][].

This application contains one command, i.e. the entry point one. This
MUST be called `MAIN`.

Our main command supports two sub-commands, namely `help` and
`commands`. As such, it's already a hiearrchical CLI application! In
addition to this, though, the command itself has an `execute` field that
can be used to actually *execute* something.

Let's see how it behaves. First, we just call it:

```
$ ./example.pl
Hello, bar!
```

In this case, we are not providing any sub-command and we set the
`default-child` to the empty string (i.e. a *false* value), hence the
`execute` will be called.

This sub is passed three parameters (`$global`, `$conf`, and `$args`);
the first one is a global tracker for the whole application, which will
be overkill in most occasions; more interestingly, `$conf` and `$args`
contain the collected options for our command (`foo` in our case) and
the residual arguments after parsing the command-line arguments.

In our case we didn't set anything for `foo`, so it gets its default
value `bar`, hence the output message.

At this point we can start playing with `foo`:

```
$ ./example.pl --foo World
Hello, World!

$ FOO=whatever ./example.pl 
Hello, whatever!

$ FOO=whatever ./example.pl --foo World
Hello, World!
```

As expected, the value for option `foo` is collected from various
sources, including the command-line arguments (which has the highest
priority) and the environment (via variable `FOO`).

Let's now see which sub-commands are supported:

```
$ ./example.pl commands
$ perl lib/App/Easer.pm commands
           help: print a help message
       commands: list sub-commands
```

As expected, the two *stock* sub-commands for getting some help to use
the CLI program are there for us; `command` lists them, with the
synthetic `help.

Let's see the full `help` now:

```
$ ./example.pl help
this is the main app

Description:
    Yes, this really is the main app

Options:
            foo: 
                 command-line: mandatory string option
                               --foo <value>
                               -f <value>
                 environment : FOO
                 default     : bar

Sub commands:
           help: print a help message
       commands: list sub-commands
```

The `help` and the `description` are nicely printed out, along with an
automatically generated help section regarding the available options
and, when present, a list of supported sub-commands (just like
`commands` above).

It's also possible to look into the help for the sub-commands though,
including `help` and `commands` themselves:

```
$ ./example.pl help help
print a help message

Description:
    print help for (sub)command

This command has no options.

$ ./example.pl help commands
list sub-commands

Description:
    Print list of supported sub-commands

This command has no options.
```

Last, we can expect errors in typing sub-commands:

```
$ ./example.pl inexistent
cannot find sub-command 'inexistent'

$ ./example.pl help inexistent
cannot find sub-command 'inexistent'
```

I hope this has been a good *T-Easer* for [App-Easer][]... it will
surely benefit some *future me* that will be wondering how to use it!


[previous]: {{ '/2021/07/03/app-easer/' | prepend: site.baseurl }}
[App-Easer]: https://github.com/polettix/App-Easer
[example.pl]: {{ '/assets/code/app-easer/example.pl' | prepend: site.baseurl }}
