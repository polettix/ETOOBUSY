---
title: 'Command::Template'
type: post
tags: [ perl, coding, run ]
comment: true
date: 2021-03-02 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Introducing [Command::Template][].

In recent post [IPC::Cmd considered harmful][] I expressed my (low)
opinion for [IPC::Cmd][]. The reason why I had to endure some time with
that module was that I was working on [Command::Template][].

This new module allows defining objects that ease the creation of
command lines based on a... *template*. As a useful twist, it's also
possible to get an object that actually *runs* those generated commands,
although with limitations.

The typical template resembles those in the examples, where angular
parentheses indicate mandatory parameters and square brackets optional
ones. Well... I might probably do better, so let's just consider the API
a little alpha so far.

As an example, let's consider the following:

```perl
use Command::Template 'command_template':
my $ct = command_template(qw{ ls [options=-l] <dir> });
```

This template above requires a parameter `dir` when invoked, and also
accepts an optional parameter `options` whose default value is `-l`. In
other terms, it represents invocations of the following kinds:

```
# the root dir with the default options
ls -l /

# just the plain dir
ls /

# another dir with different options
ls -la /etc

# another dir with different, separated options
ls -l -a /var
```

but not, for example, a plain `ls -l` (in the current directory) because
the `<dir>` parameter marks a required element.

To obtain the example expansions above we would need to call
`$ct->generate` with different *bindings*, i.e. name/value pairs that
tell it how to map each parameter's name to the corresponding value.
Bindings are passed as a list of alternating key/value pairs, so any
hash would do:

```
# the root dir with the default options
# ('ls', '-l', '/')
@cmd = $ct->generate(dir => '/');

# just the plain dir
# ('ls', '/')
@cmd = $ct->generate(dir => '/', options => []);    # OR
@cmd = $ct->generate(dir => '/', options => undef); # ALTERNATIVE FORM

# another dir with different options
# ('ls', '-la', '/etc')
@cmd = $ct->generate(dir => '/etc'), options => '-la');

# another dir with different, separated options
# ('ls', '-l', '-a', '/var')
@cmd = $ct->generate(dir => '/var', options => ['-l', '-a']);
```

The command that is generated can then be used in facilities that accept
an array for executing, e.g. [system][], [exec][], [IPC::Run][] (and
`IPC::Cmd`, of course, although [that would not actually use it as a
real array][IPC::Cmd considered harmful]):

```perl
my $exit_value = system {$cmd[0]} @cmd;
```

Well, enough for today I guess... stay safe and hold on, spring is
coming!


[Command::Template]: https://metacpan.org/pod/Command::Template
[IPC::Cmd considered harmful]: {{ '/2021/02/27/ipc-cmd-considered-harmful/' | prepend: site.baseurl }}
[IPC::Cmd]: https://metacpan.org/pod/IPC::Cmd
[system]: https://perldoc.perl.org/functions/system
[exec]: https://perldoc.perl.org/functions/exec
[IPC::Run]: https://metacpan.org/pod/IPC::Run
