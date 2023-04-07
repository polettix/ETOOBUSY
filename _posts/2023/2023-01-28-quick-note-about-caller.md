---
title: Quick note about caller
type: post
tags: [ perl ]
comment: true
date: 2023-01-28 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A quick note about [caller][].

This is mostly a *mute* post, as the code below should say it all
*SYNOPSIS*-style:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

internal('top', 0);
___balk('something', 'else');
__balk('complaint from top');

external();

sub external {
   internal('external', 0);
   __balk('complaint from external');
}

sub internal ($hint, $condition) {
   my $caller = ___caller();
   say defined($caller) ? "hint<$hint> caller<$caller>"
      : "hint<$hint> undefined caller";
   validate($condition);
}

sub validate ($condition) {
   ___balk(___caller(2), 'validation failed') unless $condition;
}

sub ___caller ($n = 1) {
   my (undef, undef, undef, $subname) = caller($n + 1);
   return defined($subname) ? ($subname =~ s{\A .* ::}{}rmxs) : '(top)';
}

sub ___balk ($prefix, $msg) { say "$prefix: $msg"        }
sub __balk  (         $msg) { ___balk(___caller(), $msg) }
```

The gist of it is that I want to figure out the name of the function
that is complaining about something, and [caller][] lets me get that
name without forcing me to pass it explicitly (this is implemented by
`__balk`, which wraps `___balk`).

So `___caller` gives us the name of the caller. As it is itself another
call to a function, we have to increment the `$n` value to get hold of
what `___caller`'s caller actually wants. This is shown, as an example,
in `validate`, which is meant to be called to do validation of stuff *on
behalf* of its caller `internal`, which in turn is gets its inputs from
its caller (either the top level or `external`).

The output of the proof of concept above is the following:

```
hint<top> caller<(top)>
(top): validation failed
something: else
(top): complaint from top
hint<external> caller<external>
external: validation failed
external: complaint from external
```

This is not a perfect mechanism, as it will not "work" inside anonymous
functions, which is a drag for dispatch tables. I usually turn to making
the package my dispatch table, usually with a specific prefix to the
function names (that I eventually strip off); in this case, checking for
the proper callback is as easy as calling `__PACKAGE__->can($key)`, so
no big deal.

Cheers!

[Perl]: https://www.perl.org/
[caller]: https://perldoc.perl.org/functions/caller
