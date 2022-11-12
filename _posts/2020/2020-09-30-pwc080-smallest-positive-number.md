---
title: PWC080 - Smallest Positive Number
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-09-30 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> It's [Perl Weekly Challenge][] time again, now on issue [#080][] [TASK #1][].

And by the way... do you know that depending on the time zone you might
already start submitting pull requests for the [Hacktoberfest][]®?!?


# The challenge

> You are given unsorted list of integers @N. Write a script to find out
> the smallest positive number missing.

# The questions

There are not *too many* questions that can be asked, but...

- the list contains integers, but the question asks for a number...
  well, let's assume that it must be an integer!
- is it correct to assume that the answer to an empty list is `1`?
- how to deal with invalid inputs?

# The solution

To be honest, nothing clever came to mind. Which is probably good,
especially if I put myself in the shoes of someone doing a job
interview!

So my plan is pretty boring:

- sort the list
- go through it and find the lowest positive integer that's missing from
  it.

With one *little* twist... why sort the *whole* list? Negative integers
don't really matter, so we will filter them out beforehand.

After much talking, here's the core of the solution:

```perl
1 sub spnb {
2    my @Np = (0, sort(grep { $_ > 0 } @_));
3    push @Np, $Np[-1] + 2;
4    (($Np[$_] + 1 < $Np[$_ + 1]) && return $Np[$_] + 1) for 0 .. $#Np - 1;
5 }
```

Line 2 filters out non-positive input numbers and *then* sorts them. I
also force the addition of a `0` at the very beginning, it will not
alter the sorting of the whole thing *and* will allow me to simplify
looking through the array.

Line 3 adds another element that does not break the sorting *and* lets
me treat the *last* element as any other one (i.e. as an "internal"
element).

Line 4 is a concession to some golfing, let's take a closer look to its
alternative *unrolled and readable* form:

```perl
4.1 for my $index (0 .. $#Np - 1) {
4.2    my $candidate = $Np[$index] + 1;
4.3    if ($candidate < $Np[$index + 1]) {
4.4       return $candidate;
4.5    }
4.6 }
```

We iterate over all but the last element, which was added by us. At each
loop, we compute what would be the *candidate* value, i.e. our possible
return value, which would be one more than the element we are currently
analyzing (line 4.2).

If this candidate is *less* than the next element in the array (line
4.3), then it's indeed missing and we can return it (line 4.4).

If you want to cut-and-paste, here's a complete file for doing some
experimentation:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use experimental qw< postderef >;
no warnings qw< experimental::postderef >;

sub spnb {
   my @Np = (0, sort(grep { $_ > 0 } @_));
   push @Np, $Np[-1] + 2;
   (($Np[$_] + 1 < $Np[$_ + 1]) && return $Np[$_] + 1) for 0 .. $#Np - 1;
}

for my $test (
   [ 5, 2, -2, 0 ],
   [ 1, 8, -1 ],
   [2, 0, -1 ],
   [],
   [1, 2, 3],
   ) {
   say spnb($test->@*);
}
```

Cheers!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#080]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-080/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-080/#TASK1
[Hacktoberfest]: https://hacktoberfest.digitalocean.com/
