---
title: PWC120 - Clock Angle
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-07-08 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#120][].
> Enjoy!

# The challenge

> You are given time `$T` in the format `hh:mm`.
> 
> Write a script to find the smaller angle formed by the hands of an
> analog clock at a given time.
> 
>> HINT: A analog clock is divided up into 12 sectors. One sector
>> represents 30 degree (360/12 = 30).
>
> **Example**
>
>     Input: $T = '03:10'
>     Output: 35 degree
>     
>     The distance between the 2 and the 3 on the clock is 30 degree.
>     For the 10 minutes i.e. 1/6 of an hour that have passed.
>     The hour hand has also moved 1/6 of the distance between the 3 and the 4, which adds 5 degree (1/6 of 30).
>     The total measure of the angle is 35 degree.
>     
>     Input: $T = '04:00'
>     Output: 120 degree

# The questions

The input format is a bit foggy as to what are the possible values. As
there is no indication of `AM` or `PM`, it can be that:

- this bit of information has been left out because it has little to do
  with the required angle. In this case, `hh` would range from `01` to
  `12`;
- a 24-hours format is adopted, i.e. `hh` would range from `00` to `23`;
- there is some other possibility that I can't think of now.

We will also assume a *regular analog clock* where there are 12 sectors.
This seems to be supported by the *HINT* in the challenge text.

We will assume that the requested angle should be the *smaller
non-negative* one - otherwise we would have *fun*.

Last, we will assume that the movement of the hands is continuous, with
particular reference to the hours hand. This seems consistent with the
first example.

# The solution

First of all, we can get rid of the ambiguity in the `hh` part by taking
the remainder to the division by 12. We will always get an integer
between 0 and 11 included, and this is what we need.

Assuming that we count an *absolute* angle from the vertical and going
in the clockwise direction, we can calculate the angles at which the two
hands are at:

- for the minutes, it's just the number of minutes times 6, because
  there are 60 minutes to be mapped onto 360 degrees;
- for the hours, we have to take into account the value we get (filtered
  as explained above) multiplying it by 30 (according to the *HINT*),
  plus the additional rotation due to the minutes, which is equal to
  $\frac{m}{60} \frac{360}{12} = \frac{m}{2}$ degrees.

Last, we can take the absolute value of their difference and compare
with 180 degrees: if greater, we take the complement of that angle to
360 degrees, so that we find the *smallest non-negative* angle.

On to the implementation, then!

[Raku][] goes first, in an effort to learn more:

```raku
#!/usr/bin/env raku
use v6;
sub clock-angle ($t) {
   my ($hrs, $mins) = $t.split(/\:/);
   my $angle = ($mins * 6) - (($hrs % 12) * 30 + $mins / 2);
   $angle = -$angle if $angle < 0;
   return $angle <= 180 ?? $angle !! 360 - $angle;
}
put "{clock-angle($_)} degree" for @*ARGS ?? @*ARGS !! qw< 03:10 04:00 >;
```

Yes, yes... I know... there's an [abs routine][] that's perfect for
taking the absolute value! Silly me 😊

The printout allows showing off the use of `{...}` inside double quotes,
which allows calling code and expanding the result in the string.
Something similar in [Perl][] would be one of the [secret operators][]
(not real operators, but compositions of basic ones!) like the [baby
cart operator][babycart] `@{[...]}` or so.

[Perl][] now:

```perl
#!/usr/bin/env perl
use v5.24;
sub clock_angle {
   my ($hrs, $mins) = split m{:}mxs, $_[0];
   my $angle = ($mins * 6) - (($hrs % 12) * 30 + $mins / 2);
   $angle = -$angle if $angle < 0;
   return $angle <= 180 ? $angle : 360 - $angle;
}
say clock_angle($_) . ' degree' for @ARGV ? @ARGV : qw< 03:10 04:00 >;
```

This time I opted with an implementation that provides a clear view of
the extreme similarity to the [Raku][] counterpart. I'm not including
`warnings` (which I usually do) and signatures, but the input is only
used once so it's OK*ish* 🙄 And yes, I'm forgetting that [Perl][] too
has its own [abs function][] 😊 

The two lines with formulas are copied verbatim from the [Raku][]
solution. The return line only changes due to the new ternary operator
(`?? !!` vs [Perl][]'s `? :`).

Stay safe everyone, and have fun!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#120]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-120/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-120/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[secret operators]: https://github.com/book/perlsecret/blob/master/lib/perlsecret.pod
[babycart]: https://github.com/book/perlsecret/blob/master/lib/perlsecret.pod#baby-cart
[abs routine]: https://docs.raku.org/routine/abs
[abs function]: https://perldoc.perl.org/functions/abs
