---
title: IPC::Cmd considered harmful
type: post
tags: [ perl, rant ]
comment: true
date: 2021-02-27 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A rant about [IPC::Cmd][]. Don't use it.

Recently, I had to do some command-line invocations from [Perl][]. Well,
let's see what we have at our disposal then...

- [system][] is fine, but too limited. E.g. it does not allow grabbing
  the output of a command, which I might need;
- [qx][] is a joke from the past. I mean, **not** having a list-oriented
  alternative and forcing the user to do (and possibly forget)
  `quotemeta` is something I can't bear in 2021;
- [IPC::Open2][] and [IPC::Open3][] are in CORE but require some effort
  to be used, which I'd like to avoid;
- [IPC::Cmd][] seems interesting, because it's in CORE and its
  `run_forked` seems to hit the sweet spot: it supports providing the
  command as an array reference, has a bunch of options and provides
  back everything that's needed;
- [IPC::Run][], [IPC::Run3][], *insert your favourite module here* all
  seem very interesting and flexible, but they are not in CORE and are
  probably overkill in my case.

Well then, we're done! [IPC::Cmd][]'s `run_forked` for the win... right?!?

Well... not so fast.

# Interface inconsistency?

One first thing that struck me is the inconsistency in the interface. I
mean, function `run` has the following signature:

```perl
run(command => COMMAND, [ optional stuff... ])
```

i.e. the `COMMAND` MUST be preceded by the `command` keyword, whereas
`run_forked` has this:

```perl
run_forked(COMMAND, \%options)
```

Anyway, my intention is to use one of the two only, so let's move on...

# What's with that newline

Another weird thing I noticed is that providing some text using the
`child_stdin` option *adds a newline at the end*.

Well, in my specific case I'm not terribly annoyed, except that I am
because I can't anticipate everything and that stray newline might break
something in the future.

# Cram the command in a string? REALLY?!?

The thing I could not believe was the following in the code though:

```
    if (ref($cmd) eq 'ARRAY') {
        $cmd = join(" ", @{$cmd});
    }
```

What. The. [Fraking][Frak]. [Frak][].

After having learned about how I should *always* force the use of the
[system][]/[exec][] that avoids invoking the shell... I consider this a
stab on the back.

I don't know the reasons - maybe backwards compability? - but this is so
unexpected in a CORE module with 16+ signs of appreciation in
[metacpan][] that's almost unbelievable.

# Conclusion

**Don't use [IPC::Cmd][]**.


[IPC::Cmd]: https://metacpan.org/pod/IPC::Cmd
[IPC::Open2]: https://metacpan.org/pod/IPC::Open2
[IPC::Open3]: https://metacpan.org/pod/IPC::Open3
[IPC::Run]: https://metacpan.org/pod/IPC::Run
[IPC::Run3]: https://metacpan.org/pod/IPC::Run3
[Perl]: https://www.perl.org/
[Frak]: https://en.wikipedia.org/wiki/Frak_(expletive)
[metacpan]: https://metacpan.org/
[exec]: https://perldoc.perl.org/functions/exec
[system]: https://perldoc.perl.org/functions/system
[qx]: https://perldoc.perl.org/perlop#qx/STRING/
