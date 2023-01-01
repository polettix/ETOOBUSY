---
title: PWC193 - Binary String
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-12-01 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#193][]. Enjoy!

# The challenge

> You are given an integer, `$n > 0`.
>
> Write a script to find all possible binary numbers of size `$n`.
>
> **Example 1**
>
>     Input: $n = 2
>     Output: 00, 11, 01, 10
>
> **Example 2**
>
>     Input: $n = 3
>     Output: 000, 001, 010, 100, 111, 110, 101, 011

# The questions

I think that by "all possible binary numbers" we mean "all possible
strings of length `$n` that can be build over an alphabet comprising `0`
and `1` only". This is because I'm not sure I would consider `0123` a
decimal number of size 4, to be honest.

Also... I'm not sure how we're supposed to produce the strings. I guess
any order will do.

# The solution

Each challenge lives on its own little monad, and has its own rules. But
(you knew there was a *but*) I can't help observing that the binary
strings *here* can happily start with a string of `0` characters, while
no later than the last week they had to definitely start with a `1`, or
bad things would have happened.

So shouldn't this go in the *questions* sections somehow? Well, no. The
challenge is subtly worded as to find all possible binary numbers of
size `$n`, which means that we don't get to do any conversion if we
don't want to.

OK, as usual let's start with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $n where * > 0 = 2) { .put for binary-strings($n) }

sub binary-strings (Int:D $n where * > 0) {
   my $prefix = '0' x ($n - 1);
   my $i = 0;
   return gather loop {
      my $raw = ($i++).base(2).Str;
      my $len = $raw.chars;
      last if $len > $n;
      take ('0' x ($n - $len)) ~ $raw;
   };
}
```

We're just counting from 0 upwards, stopping when the binary
representation gets too long. To cope with the length requirement, we
just pre-pend each produced string with a suitable number of `0`
characters.

I know, this solution is neither efficient nor scalable. [Raku][] has
built-in big integers, but we're computing/accumulating all strings
up-front and we're also using `gather`/`take`, which is not the best
efficiency-wise. I like it too much though.

For the [Perl][] alternative we move on to good old iterators - they
play nicer for bigger values of the input `$n`, as we start seeing stuff
immediately and we keep memory consumption to a minimum.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Math::BigInt;

my $it = binary_strings_iterator(shift // 2);
while (defined(my $binary_string = $it->())) {
   say $binary_string;
}

sub binary_strings_iterator ($n) {
   my $i = Math::BigInt->bzero;
   return sub {
      return unless defined $i;
      my $raw = ($i++)->to_bin;
      my $len = length $raw;
      return $i = undef if $len > $n;
      return ('0' x ($n - $len)) . $raw;
   };
}
```

So go ahead, feed it with 1000 as input and stop it when you've got
enough!

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#193]: https://theweeklychallenge.org/blog/perl-weekly-challenge-193/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-193/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
