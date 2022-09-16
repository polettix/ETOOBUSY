---
title: Cryptopals Diversion 2 - Simulating Time Leaks
type: post
tags: [ security, cryptography ]
series: Cryptopals
comment: true
date: 2022-09-18 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A little detour that will help in [Challenge 31][] in [Cryptopals][].

[Cryptopals][] [Challenge 31][] is about taking advantage of
programmers' instinct on making stuff as efficient as possible.

In this case, if we're comparing two strings char by char and find two
differing ones, what's the point of going forward to compare the other
ones? *Of course* we can just return *false* and move on.

Except that this leaks information. If an attacker tries all characters
and one of them takes *longer*, it's a big hint that this is the right
one. Pair this with the fact that giving the right string is your key to
validate a request and you have a perfect recipe for being pwned.

Well, *not that fast*. Or, better, *not **when** fast*.

If the difference is in the realm of micro or nanoseconds, and we're
doing a remote attack on a web service with typical millisecond-range
answer times, is the attacker really going to exploit us? Maybe not, but
let's not be lazy.

To warm up our attacking skills, the challenge suggests this:

> Write a function, call it `insecure_compare`, that implements the ==
> operation by doing byte-at-a-time comparisons with early exit (ie,
> return false at the first non-matching byte).
>
> In the loop for `insecure_compare`, add a 50ms sleep (sleep 50ms after
> each byte). 

This is where the **artificial time leak** comes out in the challenge's
title.

[Perl][]'s default [sleep][] function takes an integer number of seconds
as input, which is a bit too much in our case. Luckily enough, CORE
module [Time::HiRes][] comes to the rescue, providing us support for
*floating point* inputs, resulting in sub-second capabilities.

I initially coded `insecure_compare` --well, `unsafe_compare` as I
actually named it-- like this:

```perl
use Time::HiRes qw< sleep >;
our $DRAG_DELAY = $ENV{DRAG_DELAY} // (50 / 1000); # 50 ms default

sub unsafe_compare ($x, $y) {
   return 0 if length($x) != length($y); # early exit
   drag();

   for my $i (0 .. length($x) - 1) {
      return 0 if substr($x, $i, 1) ne substr($y, $i, 1);
      drag();
   }

   return 1;
}

sub drag { sleep $DRAG_DELAY }
```
After each successful comparison (starting with the string
length) we have a delay, simulating the *huge* amount of operations to
compare two characters.

The delay is introduced using the `drag` function, driven by the
`$DRAG_DELAY` which is set to 50 ms by default.

> We might argue that the delay should actually come **before** the
> comparison, as it should simulate a slow comparison function.
> Whatever, in my code there's a call to `drag()` before comparing the
> first pair, so the only "wrong" thing is calling it after the last
> pair was successful. Whatever.

This proved to be problematic while attacking the code. Fact is, the
time length I could get out of it were sometimes quite impredictable. On
the one hand this was a bless, because it forced me to find a better
algorithm to code the attack, but this is for another post.

There are two aspects that make this approach a questionable candidate
for simulating a leaking comparison function:

- the `sleep` function introduces noise of itself, which should hardly
  appear in the original leaky comparison function where the operations
  should be much more deterministic. This means that we will generally
  end up with *more* time. Calling this multiple times will spread out
  the uncertainty, up to the point where the uncertainty can give us
  *false positives*.
- The `sleep` function might be interrupted, so we might end up with
  *less* time, which might lead to *false negatives*.

I have to admit that I didn't explicitly test for the latter. I don't
know if an interrupted call to `sleep` is restarted automatically, but
still it might be worth to defend against this, especially considering
that different platforms might behave differently.

So I decided to enhance the simulation and do this instead:

- accumulate how much delay to introduce by counting the number of equal
  characters;
- perform the delay all in one sweep, based on the count in the bullet
  above. Additionally, make sure to *at least* wait what is expected,
  doing more sleeping in case it was not enough (e.g. due to some
  interruption).

This is the resulting code:

```perl
use Time::HiRes qw< sleep time >;
our $DRAG_DELAY = $ENV{DRAG_DELAY} // (50 / 1000); # 50 ms default

sub unsafe_compare ($x, $y) {
   return 0 if length($x) != length($y);

   my $n = 1;
   for my $i (0 .. length($x) - 1) {
      last if substr($x, $i, 1) ne substr($y, $i, 1);
      ++$n;
   }

   drag($n);
   return $n > length($x);
}

sub drag ($n) {
   my $amount = $n * $DRAG_DELAY;
   while ($amount > 0) {
      my $start = time();
      sleep $amount;
      $amount -= (time() - $start);
   }
}
```

This proved to be a better simulation, which also resulted in *better*
performance from my algorithm for cracking it. This is, anyway, matter
for another post.

Stay safe *and secure*!

[Perl]: https://www.perl.org/
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[Challenge 31]: https://cryptopals.com/sets/4/challenges/31
[sleep]: https://perldoc.perl.org/functions/sleep
[Time::HiRes]: https://metacpan.org/pod/Time::HiRes
