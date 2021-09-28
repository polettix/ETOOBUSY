---
title: PWC132 - Mirror Dates
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-09-29 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#132][]. Enjoy!

# The challenge

> You are given a date (yyyy/mm/dd).
> 
> Assuming, the given date is your date of birth. Write a script to find the
> mirror dates of the given date.
> 
> `Dave Cross` has built cool [site][] that does something similar.
>
>> Assuming today is 2021/09/22.
>
> **Example 1:**
>
>     Input: 2021/09/18
>     Output: 2021/09/14, 2021/09/26
>     
>     On the date you were born, someone who was your current age,
>     would have been born on 2021/09/14.
>     Someone born today will be your current age on 2021/09/26.
>
> **Example 2:**
>
>     Input: 1975/10/10
>     Output: 1929/10/27, 2067/09/05
>     
>     On the date you were born, someone who was your current age,
>     would have been born on 1929/10/27.
>     Someone born today will be your current age on 2067/09/05.
>
> **Example 3:**
>
>     Input: 1967/02/14
>     Output: 1912/07/08, 2076/04/30
>     
>     On the date you were born, someone who was your current age,
>     would have been born on 1912/07/08.
>     Someone born today will be your current age on 2076/04/30.

# The questions

Well well well... I live in Italy in 2021 and I'll stick to a [Gregorian
calendar][] and to people whose birthday was in the XX century or later.
This is non-negotiable.


# The solution

[Raku][] has a nice [Date][] class that supports arithmetics, so it's as
easy as doing some basic maths:

```raku
#!/usr/bin/env raku
use v6;
sub mirror-dates ($birth-date is copy) {
   $birth-date = Date.new(|($birth-date.comb(/\d+/)));
   my $today = Date.new(DateTime.now);
   my $delta = $today - $birth-date;
   return ($birth-date - $delta, $today + $delta);
}
sub MAIN ($d = '1967/02/14') { mirror-dates($d).join(', ').put }
```

[Perl][] follows suit, with just a little more effort and about half of
the [CPAN][] to install [DateTime][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use DateTime;
sub mirror_dates ($birth_date) {
   my %bd;
   @bd{qw< year month day >} = split m{\D+}mxs, $birth_date;
   $birth_date = DateTime->new(%bd, hour => 12, minute => 0, second => 0);
   my $today = DateTime->now;
   my $delta = $today->delta_days($birth_date);
   return (
      $birth_date->subtract_duration($delta)->ymd('/'),
      $today->add_duration($delta)->ymd('/'),
   );
}
say join ', ', mirror_dates(shift // '1967-02-14');
```

The logic is the same, just with a bit more verbose operations. There
must be care in choosing [`delta_days`][] or the result will be
incorrect - don't ask me why, I only know that date and time stuff are a
headache.

So... enjoy your *time*!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#132]: https://theweeklychallenge.org/blog/perl-weekly-challenge-132/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-132/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[site]: https://davorg.dev/mirroryear
[Gregorian calendar]: https://en.wikipedia.org/wiki/Gregorian_calendar
[Date]: https://docs.raku.org/type/Date
[CPAN]: https://metacpan.org/
[DateTime]: https://metacpan.org/pod/DateTime
[`delta_days`]: https://metacpan.org/pod/DateTime#$dt-%3Edelta_days($datetime)
