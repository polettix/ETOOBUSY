---
title: PWC102 - Hash-counting String
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-03-04 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#102][].
> Enjoy!

# The challenge

> You are given a positive integer `$N`. Write a script to produce
> Hash-counting string of that length.
>
> The definition of a hash-counting string is as follows:
> - the string consists only of digits 0-9 and hashes, ‘#’
> - there are no two consecutive hashes: ‘##’ does not appear in your string
> - the last character is a hash
> - the number immediately preceding each hash (if it exists) is the position of that hash in the string, with the position being counted up from 1
>
> It can be shown that for every positive integer N there is exactly one such length-N string.

# The questions

The formulation of the challenge contains everything that is needed,
*only* I would have re-added that the end string must be of length `$N`
in the list of characteristics that define what a hash-counting string
is.

Also... it would have been a plus to have a link to the demonstration
that such a string can always be produced. I tried a very superficial
search, but to no avail.

# The solution

The key to solving this challenge, for me, relies in these two
characteristics:

- the last character is a hash
- there are no two consecutive hashes

The first one basically tells us what should appear at the end: a hash.
It's a *start*! Ehr... it's an *end*! 🙄

The other one tells us that we have to put the 1-starting position
number, expressed as a decimal integer, immediately before, with the
possible exception of `$N` being 1 because in this case we would have
already exhausted the characters that we have to fill in.

So, if we have 123456789 as an input, we know that the hash-counting
string MUST end with the sequence `123456789#`.

How long is this sequence? It's 1 character for the `#`, plus the
*length* of the input number, that is `length $N` in [Perl][] terms.

At this point, we are left to figure out what to put *before* this last
part of the string. It MUST be a string that is `$N - (1 + length $N)`
characters long, because we already filled in `1 + length $N` characters
at the end of the final string.

Wait a minute... we now need to fill in a `$N_1 = $N - (1 + length $N)`
string with the rules for hash-counting strings, so we can just repeat
our reasoning!

This will land us with new values for `$N_x` that are always decreasing,
so we have to stop when we hit 1 or less (which should only be 0, if the
demonstration is correct). That 1 case is a special one, because it's
the only situation where we put a `#` *without* puttting an integer
before.

All in all, here's a possible solution:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub hash_counting_string ($N) {
   my $retval = '';
   ($retval, $N) = ("$N#$retval", $N - 1 - length $N) while $N > 1;
   return $N == 1 ? "#$retval" : $retval;
}

my $n = shift || 10;
say hash_counting_string($n);
```

I opted for a more compact and admittedly less readable solution because
it becomes so short that it's not difficult to figure out... like
leaving a small challenge for the casual reader 😅

Considering that I don't need to keep `$N` and all its "derivative"
values `$N_x` around, I just use it over and over to keep track of how
many characters I still have to put in the string. This is why `$N` is
updated at each loop, just like the `$retval` string.

Have a good day everyone!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#102]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-102/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-102/#TASK2
[Perl]: https://www.perl.org/
