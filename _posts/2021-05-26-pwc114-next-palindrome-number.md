---
title: PWC114 - Next Palindrome Number
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-05-26 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#114][]. Enjoy!

# The challenge

> You are given a positive integer `$N`.
> 
> Write a script to find out the next `Palindrome Number` higher than
> the given integer `$N`.
> 
> **Example**
> 
>     Input: $N = 1234 Output: 1331
> 
>     Input: $N = 999 Output: 1001

# The questions

I guess there are almost no question this time, assuming that:

- a `Palindrome Number` is an integer whose representation in base 10 is
  a [palindrome][] string
- we trust our inputs to contain a valid sequence of digits.


# The solution

As it often happens, this challenge can be addressed with a simple
*brute force* attack or something a bit more *aimed*.

The *brute force* in this case would be to start counting from `$N + 1`
on, checking for palindrome values and stopping at the first.

The *aimed* approach requires dealing with a few corner cases...

## How many digits?

First of all, there is a *corner* case that [manwar][] very gently
reminds us of: a sequence of all `9`s. This is the only case where the
*next* palindrome actually contains *one more* digit than `$N`, e.g. for
`999` we go to `1001`.

How do I know that this is the *only* case, you might be asking? Well,
if the starting `$N` contains any digit that is *not* a `9`, then `$N`
will surely be *less than* a sequence of `9`s that is long the same as
`$N`. Considering that a sequence of all `9`s *is* palindrome, surely
any number below it has a greater palindrome that has the same number of
digits.

OK, so we will treat a sequence of all `9`s as a special case, what to
do next?

## Even number of digits

If we have an even number of digits, then we only need to *count* on the
first half of the number, because the second half is constrained by the
palindrome constraint. To get the *lowest* number, it will be just
regular counting.

Whatever candidate we get for the first half, we can easily form the
full number and check it against `$N`. If it's greater than `$N` we're
done! Otherwise, just increasing the first half by one unit will
suffice.

## Odd number of digits

This case is *pretty much* similar to the previous, but not the same
because it's difficult to cut the string representation of `$N` *in
half*. So we will take just half-a-character less of one half and put it
into `$n`, and treat the middle character `$mid` specially.

As before, our first attempt is to work with what we have, i.e. merging
`$n`, `$mid` and the reverse of `$n`. If it's greater than `$N` we're
done.

Next, to get the *closest greater* one, we try to increase `$mid`. This
will work... unless `$mid` is equal to `9`, which forces us to increase
`$n` instead.

## Putting even and odd cases together

The two cases for even and odd alternatives are pretty similar, except
for some special handling of the middle character. Hence, with a few
special cases... we should be able to address both cases in a mostly
unified way.

## Perl solution

Let's start with the [Perl][] solution:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub next_palindrome_number ($N) {
   my $l = length $N;
   return '1' . ('0' x ($l - 1)) . '1' unless $N =~ m{[0-8]}mxs;
   my $n = substr $N, 0, $l / 2;
   my $mid = $l % 2 ? substr($N, $l / 2, 1) : '';

   # just try to build straight from the inputs...
   if ((my $candidate = $n . $mid . reverse($n)) > $N) {
      return $candidate;
   }

   # if there's a "$mid", try increasing that
   if ($l % 2) {
      return $n . ($mid + 1) . reverse($n) if $mid != 9;
      $mid = 0;
   }

   ++$n;
   return $n . $mid . reverse($n);
}

@ARGV = (1234) unless @ARGV;
say next_palindrome_number($_) for @ARGV;
```

I hope it has no surprises after the explanations above!

## Raku solution

So here's the *translation* of the solution in [Raku][]:

```raku
#!/usr/bin/env raku
use v6;

sub next-palindrome-number (IntStr $N) {
   my $l = $N.chars;
   return '1' ~ ('0' x ($l - 1)) ~ '1' unless $N ~~ m{<[0 .. 8]>};
   my $n = $N.substr(0, $l / 2);
   my $mid = $l % 2 ?? $N.substr($l / 2, 1) !! '';

   # just try to build straight from the inputs...
   if (my $candidate = $n ~ $mid ~ $n.flip) > $N {
      return $candidate;
   }

   # if there's a "$mid", try increasing that
   if ($l % 2) {
      return $n ~ ($mid + 1) ~ $n.flip if $mid < 9;
      $mid = 0;
   }

   ++$n;
   return $n ~ $mid ~ $n.flip;
}

sub MAIN (*@inputs is copy) {
   @inputs.push(1234) unless @inputs.elems;
   next-palindrome-number($_).say for @inputs;
}
```

This is basically my second (well... third) venture in [Raku][], and so
far it's been a bit *frustrating*.

Ok, ok, it was an occasion to break with the past and fix a few things.
Was it really necessary to move from `reverse` to `flip`? Change the
ternary operator that we all love from C into `?? !!`? Turn character
classes to something different from the rest of the world?

Probably yes, but it's frustrating. For me, at least.

Another nit-pick is about the signatures, especially for `MAIN`. I think
that there's been a substantial loss in *whipuptitude*, because it took
me a bit to figure how to replicate the *simple* input arguments passing
that we have in [Perl][].

I mean, I usually resort to [Getopt::Long][] for getting input
parameters, and I understand that the signature for `MAIN()` can help
with this. But, again... *whipuptitude* lost in my opinion.

Or, maybe... I didn't read enough 🙄


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#114]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-114/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-114/#TASK1
[Perl]: https://www.perl.org/
[palindrome]: https://en.wikipedia.org/wiki/Palindrome
[manwar]: http://www.manwar.org/
[Raku]: https://raku.org/
[Getopt::Long]: https://metacpan.org/pod/Getopt::Long
