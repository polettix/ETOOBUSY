---
title: PWC103 - Chinese Zodiac
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-03-10 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#103][]. Enjoy!

# The challenge

> You are given a year `$year`. Write a script to determine the Chinese Zodiac
> for the given year `$year`. Please check out [wikipage][] for more information
> about it.
>
>> The animal cycle: Rat, Ox, Tiger, Rabbit, Dragon, Snake, Horse, Goat,
>> Monkey, Rooster, Dog, Pig.
>
>> The element cycle: Wood, Fire, Earth, Metal, Water.

# The questions

Considering that each element goes through for two years, because it has a
*Yin* and a *Yang* alternative, one question is whether we should also take
that into account in the answer. The examples do not show it, so we'll use
*standard error* to print out the full year name 😄

Next, the Chinese calendar does not match the western calendar exactly, so
saying `1972` might mean one year or another depending on whether we are
talking before or after the Chinese New Year. Considering that most of the
year overlaps *after*, we will assume that `1972` refers to the part of the
western year that comes after the Chinese New Year.

The input format for the `$year` is also something that should be specified
to a greater detail. Should we accept negative numbers? Accept `AD` and
`BC`? Default to `AD` in lack of a sign? We'll try to address them all.

Last... we trust that the algorithm explained in the [wikipedia page][] is
correct! Right...?

# The solution

Here's my attempt at a solution:

```perl
sub chinese_zodiac ($year) {
   my ($s, $y, $acbc) = $year =~ m{
      \A \s*
      (-?) \s*
      ([1-9]\d*) \s*
      ((?:ad|bc)?)
      \s* \z
   }imxs;
   die "invalid input date '$year'\n"
      if (! defined $y) || ($s eq '-' && length $acbc);
   $year = $s eq '-' || lc($acbc) eq 'bc' ? -$y : $y;
   my $r = $year > 0 ? (($year + 56) % 60) : 59 - ((2 - $year) % 60);
   my $yin_yang = (qw< Yang Yin >)[$r % 2];
   my $element  = (qw< Wood Fire Earth Metal Water >)[int($r / 2) % 5];
   my $animal   = (qw< Rat Ox Tiger Rabbit Dragon Snake
      Horse Goat Monkey Rooster Dog Pig >)[$r % 12];
   return ($yin_yang, $element, $animal);
}
```

The first part tries to parse the input, accepting different formats like
`-246`, `246 BC`, etc. and to flag errors (e.g. `-3 AD` is rejected). This
allows us to normalize the input `$year` to a signed integer we can work on.

The [wikipedia page][] talks about remainder modulo 60 but adopts a
numbering that starts from 1, which is suboptimal in my opinion. So the
implementation above adopts a slight modification of the algorithm that
takes into account the shift and eases the following calculations.

The *Yin*/*Yang* decision is straighforward, because they alternate each
year. Hence, a simple remainder modulo 2 suffices.

The *element* is a bit trickier because it follows a two-years cycle, so we
have to first divide by 2 (in the *integer* sense) and then take a remainder
modulo 5, that is the number of different elements in a cycle.

Last, the *animal* can be easily derived using a modulo 12 operation.

In all cases, we use the same idiom to get the text value on the fly, i.e.
using the index to get an element inside a list, on the fly:

```perl
( ... list ... )[ index ]
```

I hope it's readable 🙄

The full program, should you be curious:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub chinese_zodiac ($year) {
   my ($s, $y, $acbc) = $year =~ m{
      \A \s*
      (-?) \s*
      ([1-9]\d*) \s*
      ((?:ad|bc)?)
      \s* \z
   }imxs;
   die "invalid input date '$year'\n"
      if (! defined $y) || ($s eq '-' && length $acbc);
   $year = $s eq '-' || lc($acbc) eq 'bc' ? -$y : $y;
   my $r = $year > 0 ? (($year + 56) % 60) : 59 - ((2 - $year) % 60);
   my $yin_yang = (qw< Yang Yin >)[$r % 2];
   my $element  = (qw< Wood Fire Earth Metal Water >)[int($r / 2) % 5];
   my $animal   = (qw< Rat Ox Tiger Rabbit Dragon Snake
      Horse Goat Monkey Rooster Dog Pig >)[$r % 12];
   return ($yin_yang, $element, $animal);
}

my $y = "@ARGV" || 1972;
my ($yin_yang, $element, $animal) = chinese_zodiac($y);
say "$element $animal";
say {*STDERR} "$yin_yang $element $animal";
```

Stay safe please!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#103]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-103/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-103/#TASK1
[Perl]: https://www.perl.org/
[wikipage]: https://en.wikipedia.org/wiki/Chinese_zodiac
[wikipedia page]: https://en.wikipedia.org/wiki/Sexagenary_cycle
