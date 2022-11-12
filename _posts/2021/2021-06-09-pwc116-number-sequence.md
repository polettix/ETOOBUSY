---
title: PWC116 - Number Sequence
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-06-09 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#116][]. Enjoy!

# The challenge

> You are given a number `$N >= 10`.
> 
> Write a script to split the given number such that the difference
> between two consecutive numbers is always 1 and it shouldn’t have
> leading 0.
> 
> Print the given number if it impossible to split the number.
> 
> **Example**
>  
>     Input: $N = 1234
>     Output: 1,2,3,4
>
>     Input: $N = 91011
>     Output: 9,10,11
>
>     Input: $N = 10203
>     Output: 10203 as it is impossible to split satisfying the conditions.

# The questions

I have to admit that I didn't get the challenge just by reading it. In
my brain, *split a number* means dividing it into a sum; this time,
though, we're playing with the ambiguity of considering a number by its
string representation in base 10. As usual, anyway, the examples make an
excellent job of clarifying things.

It's also interesting to note that the output value for when there is no
way to *split* the input number is actually a valid number splitting -
one with one single element only. This makes the restriction about
`$N >= 10` a bit arbitrary but whatever, not counting e.g. that `-101` would
be a perfect fit. Whatever.

# The solution

We just do a plain search here, starting with the first character, then
two, etc. up to one half of the string representation. Anything beyond
would not be a good division and can be skipped.

One of the examples is a blessing: `91011`. It makes it perfectly clear
that the number of characters to be consumed is *variable* - in this
case, it starts from 1 and then lands on 2. Hence, there's no *evident*
way to rule out stuff - although something might be coded, admittedly.

Here's my solution in [Perl][]:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub number_sequence ($N) {
   my $length = length $N;
   SIZE:
   for my $l (1 .. $length / 2) {
      my @retval = my $x = substr $N, 0, $l;
      my $start = $l;
      ++$x;
      while ((my $available = $length - $start) > 0) {
         my $xlen = length $x;
         next SIZE if $xlen > $available || substr($N, $start, $xlen) ne $x;
         push @retval, $x;
         $start += $xlen;
         ++$x;
      }
      return @retval;
   }
   return $N;
}

my @inputs = @ARGV ? @ARGV : qw< 1234 91011 10203 >;
say join ',', number_sequence($_) for @inputs;
```

Here's the corresponding solution in [Raku][]:

```raku
#!/usr/bin/env raku
use v6;

sub number-sequence (Int $N where * >= 10) {
   my $Nlength = $N.chars;
   SIZE:
   for 1 .. ($Nlength / 2) -> $l {
      my @retval = my $x = $N.substr(0, $l);
      my $start = $l;
      ++$x;
      while (my $available = $Nlength - $start) > 0 {
         my $xlen = $x.chars;
         next SIZE if $xlen > $available || $N.substr($start, $xlen) ne $x;
         @retval.push($x);
         $start += $xlen;
         ++$x;
      }
      return @retval;
   }
   return $N;
}

sub MAIN (*@inputs) {
   @inputs = < 1234 91011 10203 > unless @inputs.elems;
   number-sequence($_).join(',').put for @inputs;
}
```

Stay safe!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#116]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-116/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-116/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
