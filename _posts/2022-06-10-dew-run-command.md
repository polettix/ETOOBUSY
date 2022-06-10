---
title: Dew - running a command, lazily
type: post
tags: [ perl, curses, terminal ]
series: Terminal data viewer
comment: true
date: 2022-06-10 22:23:24 +0200
mathjax: false
published: true
---

**TL;DR**

> The lazy approach to run an external command in [dew][].

One of the handy things that [dew][] does is accept a shell command in
the top part, execute it and then parse the JSON result to show it in
the middle and lower sections.

So, of course, it needs to support *executing* the command.

I was initially thinking about parsing the command line, taking care of
single and double quotes to properly get all parameters right, when I
suddenly realized that I already had a solution.

It's `/bin/sh -c`.

So there we have it, at [line 152][]:

```perl
my $runner = sub { system {'/bin/sh'} '/bin/sh', '-c', $command };
```

This allows passing the shell a whole command line as a single string;
the shell will take care to parse it properly and execute it. Hence, we
"just" have to execute it and get the results back, which is done in two
possible ways depending on whether we want to capture the standard error
(e.g. to show it in a dialog box) or we're fine with printing it outside
our curses environment:

```perl
if ($self->{get_stderr}) {
   ($stdout, $stderr, $exit) = capture { $runner->() };
}
else {
   ($stdout, $exit) = capture_stdout { $runner->() };
}
```

The first one will capture STDERR (placing it in `$stderr`), while the
second will pass the STDERR directly to the terminal.

It's interesting that `capture` and `capture_stdout` from
[Capture::Tiny][] are defined with *prototypes* that allow using the
fancy syntax a-la `grep`/`map` and the like. Alas, the similarity is not
perfect, so I was initially doing this:

```perl
capture $runner;
```

just to receive an error. We have to put an explicit block of code
there! Whatever, it does its job, so it's good for me.

Stay safe!

[Perl]: https://www.perl.org/
[dew]: https://gitlab.com/polettix/dew
[line 152]: https://gitlab.com/polettix/dew/-/blob/601f3f2d14f9d21dd98f3056a9ba68ffb15fccb6/dew#L152
[Capture::Tiny]: https://metacpan.org/pod/Capture::Tiny
