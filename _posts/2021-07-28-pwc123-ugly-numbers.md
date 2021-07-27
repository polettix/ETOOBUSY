---
title: PWC123 - Ugly Numbers
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-07-28 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#123][]. Enjoy!

# The challenge


> You are given an integer `$n` >= 1.
> 
> Write a script to find the $nth element of Ugly Numbers.
> 
>> Ugly numbers are those number whose prime factors are 2, 3 or 5.
>> For example, the first 10 Ugly Numbers are 1, 2, 3, 4, 5, 6, 8,
>> 9, 10, 12.
> 
> **Example**
>
>     Input: $n = 7
>     Output: 8
>     
>     Input: $n = 10
>     Output: 12

# The questions

Well, I have a few!

First of all, I totally love low numbers from 1 to 6... I saw them
growing one by one and they always seemed beautiful to me! How dare you
call them *ugly*?!?

Then, on a more serious note, the way the puzzle is phrased is
debatable. It's surely very subtle to make reference to the *prime
factors* of course, but that "*are*" in my opinion implies that at least
one of them should be present. I've seen less obscure definitions
around, although I'd probably say that:

> Ugly numbers are of the form $2^x 3^y 5^z$, with $x$, $y$, and $z$
> being non-negative integers.

This easily accounts for that pesky 1 at the beginning, being it the
only one of the lot that is *not* divisible by any of 2, 3, or 5.

And, of course, this also stresses something that is *indeed* also in
the original definition: whatever is divisible *also* by any other prime
number is *not* ugly. So, for example, 14 is *not* ugly because it's
divisible by prime factor 7.


# The solution

We'll go [Raku][] first. In pure bottom-up spirit let's first take a
look at a test for checking whether a number is *ugly* or not:

```raku
# check that $x is of the form 2^x * 3^y * 5^z
sub is-ugly (Int() $k is copy) {
   # remove all 2, 3, and 5 factors in $k
   for 2, 3, 5 -> $d {
      $k /= $d while $k %% $d;
   }

   # if we're left with anything that's not 1, the number is *not* ugly
   return $k == 1;
}
```

The idea is to divide our input value `$k` by the highest possible
powers of 2, 3, and 5 and see what's left. If the number is *ugly*, i.e.
of the form $2^x 3^y 5^z$, we will be left with nothing else than 1,
otherwise we will have some *other* factor (we don't care which).

The attentive reader surely noted that the signature of `is-ugly` is
super-interesting:

```raku
sub is-ugly (Int() $k is copy) { ...
```

What's with this `Int()` with the parentheses? By all means this is
taking advantage of the teachings of [gfldex][], which you can read
about in previous post [Raku community answered to shift || 5][].

The gist of it is that doing `$k /= $d` tries to fit a `Rat` into `$k`.
If we *just* declare `Int $k` this yields an error; with the
parentheses, though, [Raku][] is told to *coerce* the result of the
division into an `Int`.

OK, enough showing off of my latest trembling skills!

Now we just have to use this test in another function that takes care to
calculate the *n*-th of these *alleged* ugly numbers. To do this, we
keep a *cache* of numbers, so that we don't have to re-calculate the
first items over and over; we also warm-up the cache with the initial
few elements, i.e. all integers from 1 to 6 included:

```raku
sub ugly-number-at-position (Int:D $n where * > 0) {
   # keep a cache of values for fun and profit
   state @cache = 1 .. 6;

   # We add elements to the cache as we need them, otherwise leveraging
   # previous calculations
   while $n > @cache.elems {
      # we start testing immediately after the latest element we put
      my $c = 1 + @cache[*-1];

      # anything that yields a rest when divided by 2 and by 3 and by 5
      # is not ugly and gets us to look for the next candidate
      $c++ until is-ugly($c);

      # our candidate $c is divisible by one of 2, 3, or 5, so it's
      # "ugly" and we add it to the lot, in order
      @cache.push: $c;
   }

   # our input $n has an off-by-one difference from how we index arrays
   return @cache[$n - 1];
}
```

Here's an interesting twist to one of my *house rules*, i.e. I
practically never use `until`. Well... *until* now, where I think that
it fits perfectly 🙄

So much for [Raku][], let's move on to [Perl][]. The test first:

```perl
sub is_ugly ($k) {
   for my $d (2, 3, 5) {
      $k /= $d until $k % $d;
   }
   return $k == 1;
}
```

It's extremely hard to fail using something that is not present, and in
this case the lack of [Raku][]'s sophisticated, incremental type system
is an advantage because we don't have to fight against type mismatches
between integers and rationals, nor to call coercions to our help.

[Perl][] sports a superior whipuptitude in this case, not because we
cannot do the same in [Raku][] (of course *incremental* means that we
can just stop at *no type system at all*), but because it does not lure
us to use it.

> I know, it might exist only in my head... but it does not make it any
> less real, right?!?

One fun thing is that I'm using `until` again here. [Perl][] does not
have an *is divisble by* operator `%%` like [Raku][], so we can resort
to the negation of *has a rest in the division by*, i.e. our old friend
`%` operator. The negation being expressed by `until`.

The other function to calculate the *n*-th position is pretty much a
translation of [Raku][]'s corresponding code:

```perl
sub ugly_number_at_position ($n) {
   die "invalid input '$n'\n" if $n !~ m{\A [1-9]\d* \z}mxs;
   state $cache = [1..6];
   while ($n > $cache->@*) {
      my $c = 1 + $cache->[-1];
      $c++ until is_ugly($c);
      push $cache->@*, $c;
   }
   return $cache->[$n - 1];
}
```

The test on the input takes one line only, so I decided to put it 😅.
[Raku][] is superior here, because we can put the constraint directly in
the signature, which I find useful in way more than 80% of the cases.

We have to take into account that `state` variables needed to be scalars
until 5.28, and I'm still using 5.24. For this reason, I'm using an
array reference `$cache` instead of a full-fledged array here, which
sacrifices something on the altar of readability. It's not [Perl][]'s
fault though, only my laziness in upgrading it.

Well... I guess it's everything for this post!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#123]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-123/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-123/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[gfldex]: https://gfldex.wordpress.com/
[Raku community answered to shift || 5]: {{ '/2021/07/26/raku-community-answered/' | prepend: site.baseurl }}
