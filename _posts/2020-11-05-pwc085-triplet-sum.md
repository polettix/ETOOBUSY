---
title: PWC085 - Triplet Sum
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-11-05 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#085][]. Enjoy!

# The challenge

> You are given an array of real numbers greater than zero. Write a
> script to find if there exists a triplet `(a,b,c)` such that
> `1 < a+b+c < 2`. Print 1 if you succeed otherwise 0.

# The questions

This is one of those annoyingly great challenges! Those where you're too
lazy to find an optimized solution, sort of know that you can do better,
do some research but still the answers do not apply. So one question
might be... *can we solve [3SUM] instead*?

I guess the answer will be... *NO*.

OK, fair enough. Legitimate question then:

- should we be wary of corner cases involving the imperfect
  representation of floating point numbers in computers? Something
  related to this, for example:

```
$ perl -E 'say 0.1 + 0.2 == 0.3 ? "equal" : "different"'
different
```

- how big is the input list of numbers? In other terms: does it make
  sense to look for an optimized solution or is it sufficient to give a
  correct but less scalable one?

- (I'm getting tired of this) how should we treat incorrect inputs?

# The solution

The very boring, hence good level-0, algorithm that comes to mind is:
*take every possible subset of three items from the input array,
calculate the sum and check against the allowed range. Return 1 as soon
as you find a match, return 0 otherwise.*

Generating all the subsets is a challenge by itself, but I think that in
this case we should take extra care to generate only the really needed
ones. I mean, if we get a list with `0.5` repeated 10000 times, any
three of them will do... and we don't really need to generate all the
possible $\binom{10000}{3} = \frac{10000 \cdot 9999 \cdot
9998}{3 \cdot 2} = 166616670000$ combinations beforehand, right?!?

For this reason, the best here would be to have a way to generate new
combinations on the spot, just when they are needed. We need an
*iterator*.

Luckily enough, CPAN provides us with [Math::Combinatorics][]: it's
pure-[Perl][] (which makes it easy to install everywhere) and provides
us with an iterator-based implementation to get combinations. Yay!

This is the solving function:

```
 1 sub triplet_sum {
 2    my @R = grep { $_ <= 2.0 } @_; # remove cruft
 3    my $combiner = Math::Combinatorics->new(count => 3, data => \@R);
 4    while (my ($x, $y, $z) = $combiner->next_combination) {
 5       $x += $y + $z;
 6       return 1 if 1 <= $x && $x <= 2;
 7    }
 8    return 0;
 9 };
```

Line 2 collects the input, making sure to keep only the ones that can
possibly contribute to a successful sum. This means that everything
above `2.0` will get filtered out.

Line 3 creates a [Math::Combinatorics][] object that  will be suitable
to generate combinations of three items (option `count`) out of our
(filtered) input data `@R`.

From this point, it's just a matter of applying our algorithm above:

- take the next triplet (line 4);
- do the sum (line 5);
- check against the target range (line 6).

And until I get an answer to the need for something more efficient...
I'll stick with this solution 😇

The full code, should you be interested into it, is the following:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use FindBin '$Bin';
use lib "$Bin/local/lib/perl5";

use Math::Combinatorics ();

sub triplet_sum {
   my @R = grep { $_ <= 2.0 } @_; # remove cruft
   my $combiner = Math::Combinatorics->new(count => 3, data => \@R);
   while (my ($x, $y, $z) = $combiner->next_combination) {
      $x += $y + $z;
      return 1 if 1 <= $x && $x <= 2;
   }
   return 0;
};

my @input = scalar @ARGV ? @ARGV : (0.5, 1.1, 0.3, 0.7);
say triplet_sum(@input);
```

It assumes that the [Math::Combinatorics][] module is installed in
`local/lib/perl5` starting from the same position as where the program
is saved.

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#085]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-085/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-085/#TASK1
[3SUM]: https://en.wikipedia.org/wiki/3SUM
[Math::Combinatorics]: https://metacpan.org/pod/Math::Combinatorics
[Perl]: https://www.perl.org/
