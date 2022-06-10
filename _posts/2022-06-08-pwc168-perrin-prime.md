---
title: PWC168 - Perrin Prime
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-06-08 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#168][]. Enjoy!

# The challenge

> The `Perrin sequence` is defined to start with `[3, 0, 2]`; after that, term
> N is the sum of terms `N-2` and `N-3`. (So it continues `3, 2, 5, 5, 7, …`.)
>
> A Perrin prime is a number in the Perrin sequence which is also a prime
> number.
>
> Calculate the first `13 Perrin Primes`.
>
>     f(13) = [2, 3, 5, 7, 17, 29, 277, 367, 853, 14197, 43721, 1442968193, 792606555396977]

# The questions

I guess that there's no *actual* question to ask, as the challenge
request is blunt but otherwise clear. As an example, one might think
that `3, 2, 3, 2, 5, 5` *might* be the first items, but otherwise the
*Perrin prime*, as defined, is just something that *belongs* to the
sequence, with no reference to ordering. So well, duplicates are out and
*first* can be easily seen as *first from lowest value to infinity*.


# The solution

In time, I've been often fascinated to how I could design somehow
complex solutions in [Perl][], whereas some similar solutions in C (by
others, of course) were much simpler. Even in BASIC, sometimes.

I guess this stems from two factors: my tendency to over-engineer stuff,
thinkig to some distant future where I *might* need an extension in a
direction that... is not going to happen. Not in the instance of the
multiverse, anyway.

Here we have such an example, in my opinion. It helps that we have
[Perl][] *and* [Raku][], where the latter is from many points of view
much powerful and expressive. So it's easier to conjure up classes, as
well as leveraging on multi-methods to cope with the initial "corner"
cases, getting stuff conditionally with `gather/take`, etc., and I
eventually ended up with this:

```raku
#!/usr/bin/env raku
use v6;

class PerrinSequence {
   has @!state = [3, 0, 2];
   method get () {
      @!state.push(@!state[0] + @!state[1]);
      return @!state.shift;
   }
}

multi sub MAIN (1) { put 2 }

multi sub MAIN (2) { put '2, 3' }

multi sub MAIN (3) { put '2, 3, 5' }

multi sub MAIN (Int:D $n is copy where * > 3 = 13) {
   my $ps = PerrinSequence.new;
   $ps.get for 1..7;
   my @n-primes = gather while $n > 3 {
      my $candidate = $ps.get;
      next unless $candidate.is-prime;
      take $candidate;
      --$n;
   }
   [2, 3, 5, |@n-primes].join(', ').put;
}
```

Oh boy how I wish it could be much simpler and elegant. Whatever.

[Perl][], on the other hand, does not give that stuff out of the box, so
there's not point in translating. Let's see what we have at our
disposal, and use that.

The result, I daresay, is superior this time, in pure *less is more*
spirit:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use ntheory 'is_prime';

my $n = shift // 13;
say join ', ', perrin_primes($n);

sub perrin_primes ($n) {
   my @pps = (2, 3, 5);
   my @state = (2, 5, 5);
   while (@pps < $n) {
      push @state, my $candidate = $state[0] + $state[1];
      shift @state;
      push @pps, $candidate if is_prime($candidate);
   }
   return @pps;
}
```

So there I got my lesson: having an amazing hammer does not mean that
everything should be treated as a nail. On the other hand, sometimes
using it means hitting the nail right in the head.

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#168]: https://theweeklychallenge.org/blog/perl-weekly-challenge-168/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-168/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
