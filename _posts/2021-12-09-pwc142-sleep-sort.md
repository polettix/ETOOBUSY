---
title: PWC142 - Sleep Sort
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-12-09 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#142][].
> Enjoy!

# The challenge

> Another joke sort similar to JortSort suggested by champion `Adam
> Russell`.
>
> You are given a list of numbers.
>
> Write a script to implement `Sleep Sort`. For more information, please
> checkout this [post][sleep-sort].

# The questions

Oh! Where do I st...

*It's a joke, you old t**t!*

**AHEM** no questions!


# The solution

We'll use `fork` in [Perl][] because... well, I like it. This is very
bare-bones, stuff is printed out by each child directly and it works
because they all share the same standard output channel.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

for my $n (@ARGV) {
   defined(my $pid = fork()) or die "fork(): $!\n";
   next if $pid;
   sleep $n;
   say $n;
   exit 0;
}
wait for 1 .. @ARGV;
```

To make sure to wait for all children to finish, we just... `wait for`
all of them.

This cannot be immediately translated into [Raku][] because there's no
valuable `fork`. The page on [concurrency][] gets the job done on
getting us started though:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) {
   await @args.map: -> $x { Promise.in($x).then({$x.put}) }
}
```

The `in` part sets the timer, and `then` we just print. We might just as
easily `take`, anyway. Again, we wait (well, `await`) at the end for all
promises to have completed before exiting the main thread.

I guess this is it... stay safe and have `-Ofun`!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#142]: https://theweeklychallenge.org/blog/perl-weekly-challenge-142/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-142/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[sleep-sort]: https://iq.opengenus.org/sleep-sort
[concurrency]: https://docs.raku.org/language/concurrency
