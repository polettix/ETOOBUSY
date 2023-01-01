---
title: PWC149 - Largest Square
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-01-27 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#149][].
> Enjoy!

# The challenge

> Given a number base, derive the largest perfect square with no
> repeated digits and return it as a string. (For base>10, use
> ‘A’..‘Z’.)
>
> **Example:**
>
>     f(2)="1"
>     f(4)="3201"
>     f(10)="9814072356"
>     f(12)="B8750A649321"

# The questions

Well, also here I guess "number" means "integer", although for
non-integers it's probably next to impossible to find something that
adheres to the "no repeated digits" in the representation. Or is it?

Another thing that is not clear is what to do with bases beyond 36 -
there are 26 letters in the English alphabet, so that is the maximum
base we can allow for a representation with "standard" western digits
and letters.

# The solution

I had two possible approaches in mind when thinking about this
challenge:

- square-root testing of arrangements of the different digits, in
  decreasing order;
- squaring numbers until one provides an "all-different-digits"
  solution.

I eventually went for the second alternative, although my
implementation(s) is not terribly fast and, I guess, efficient. I did
not benchmark the two.

Anyway.

The [Perl][] solution is the following:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use Math::BigInt;

my $base = shift || 10;
my @ls = largest_square($base);
if ($base <= 36) {
   say join '', turn_to_letters(@ls);
}
else {
   say join ' ', @ls;
}

sub turn_to_letters (@sequence) {
   state $alphabet = ['0' .. '9', 'A' .. 'Z'];
   state $digit_for = {map { $_ => $alphabet->[$_]} 0 .. $alphabet->$#*};
   return map {$digit_for->{$_}} @sequence;
}

sub largest_square ($base = 10) {
   my $max = Math::BigInt->new(0);
   for my $n (reverse 0 .. $base - 1) {
      $max = $max * $base + $n;
   }
   my $candidate = 1 + $max->bsqrt;
   CANDIDATE:
   while ('necessary') {
      --$candidate;
      my $square = $candidate * $candidate;
      my (%flag, @retval);
      while ($square > 0) {
         unshift @retval, my $v = $square % $base;
         next CANDIDATE if $flag{$v}++;
         $square /= $base;
      }
      return @retval;
   }
}
```

The solution is general and not constrained by base, although it takes
more and more time as we move up (even at a meager 16-characters
alphabet it takes more time than I'm willing to admit). So it's not
restricted to the base-36 limit: you can just go up if you have a very
fast computer and a lot of time/energy to spend.

We start from the highest possible number in the given base that uses
*all* available digit characters. This is computed in `$max`, leveraging
[Math::BigInt][] to avoid restrictions.

Any number that is compliant will necessarily:

- be less than, or equal to, `$max`;
- be a perfect square;
- be composed of different digits only.

Bullet 2 means that the square root will have to be an integer and
bullet 1 means that this integer will be less than, or equal to, the
square root of `$max`. For this reason, instead of looking for matching
integers, we will look for their "perfect" integer square root, using
variable `$candidate`.

> Variable `$candidate` is initialized to be 1 over the square root
> because we decrease it as the first action inside the `while` loop, so
> we can be sure not to rule out the "equal to" alternative.

The `while` loop tests the different `$candidate`s in decreasing order,
so that we can ensure we find the *largest square* possible. So we
calculate the `$square`, then check it for the third requirements, i.e.
that it only has different extended digits. In this case, each "digit"
is actually represented by an integer from 0 to `$base - 1`, but this is
a technicality.

Variable `%flag` allows us to keep track of which "digits" we already
saw. The `next CANDIDATE...` line will actually go to the next iteration
only the second time a "digit" is seen, thanks to the post-increment
(the first time it sets the value to 1, but the expression itself
returns 0 that is a false value).

Function `turn_to_letters()` makes sure to return... letters, as
requested. This only happens in bases less than, or equal to, 36;
otherwise, we just print out the "digit identifier" as an integer from 0
up to `$base - 1`.

[Raku][] time:

{% raw %}
```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $base = 10) {
   my @ls = largest-square($base);
   if $base <= 36 {
      turn-to-letters(@ls).join('').put;
   }
   else {
      @ls.join(' ').put;
   }
}

sub turn-to-letters (@sequence) {
   state @alphabet = ('0' .. '9', 'A' .. 'Z').flat;
   state %digit-for = (^@alphabet).map: { ($_, @alphabet[$_]).Slip };
   return @sequence.map: {%digit-for{~$_}};
}

sub largest-square ($base) {
   my $max = 0;
   $max = $max * $base + $_ for (^$base).reverse;
   my $candidate = 1 + $max.sqrt.Int;
   CANDIDATE:
   while True {
      --$candidate;
      my $square = $candidate * $candidate;
      my $present = SetHash.new;
      my @retval;
      while $square > 0 {
         my $v = $square % $base;
         next CANDIDATE if $present.EXISTS-KEY($v);
         $present.set($v);
         @retval.unshift: $v;
         $square = ($square / $base).Int;
      }
      return @retval;
   }
}
```
{% endraw %}

This is pretty much a translation from the [Perl][] code, *except* that
it supports arbitrary integer maths out of the box, so there's no need
to fiddle with [Math::BigInt][]. And **hear hear it's faster**:

```
$ time perl perl/ch-2.pl 16
FED5B39A42706C81

real	2m5.166s
user	2m4.924s
sys	0m0.052s


$ time raku raku/ch-2.raku 16
FED5B39A42706C81

real	0m26.983s
user	0m27.096s
sys	0m0.064s
```

Stay safe folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#149]: https://theweeklychallenge.org/blog/perl-weekly-challenge-149/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-149/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Math::BigInt]: https://metacpan.org/pod/Math::BigInt
