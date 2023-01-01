---
title: PWC172 - Five-number Summary
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-07-07 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#172][].
> Enjoy!

# The challenge

> You are given an array of integers.
>
> Write a script to compute the `five-number` summary of the given set
> of integers.
>
> You can find the definition and example in the [wikipedia page][].

# The questions

Is this the start of a new trend? Statistics?

There are a few gray areas, the most important one is about *which
definition to take for the percentiles*. There seem to be four different
ways of calculating them, depending on the inclusion and/or exclusion of
stuff. I'll stick to the so-called **Tukey's hinges** way, because
[Tukey][] invented (with [Cooley][]) the [Fast Fourier Transform][] so
he surely knew what he was doing.

> He also seems to have invented the term **bit**. Awesome.

I'll also disregard corner cases with very little info etc.

# The solution

OK let's start with [Perl][].

We define a helper function to calculate the *median* and also provide
us back with the upper extreme of the lower half, as well as the lower
extreme of the upper half. All these values are really needed only upon
the first call (to evaluate the *median*), but whatever.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @values = (0, 0, 1, 2, 63, 61, 27, 13);
my @fives = five_number_summary(@values);
say "(@fives)";

sub five_number_summary (@input) {
   state $emedian = sub ($aref, $from, $to) {
      my $twom = $from + $to;
      my $rem  = $twom % 2;
      my $lo = ($twom - $rem) / 2;
      my $hi = $lo + 1;
      my $medn = $rem ? ($aref->[$lo] + $aref->[$hi]) / 2 : $aref->[$lo];

      # https://en.wikipedia.org/wiki/Quartile - Tukey's hinges
      return ($medn, $rem ? ($lo, $hi) : ($lo, $lo));
   };
   @input = sort { $a <=> $b } @input;

   my ($median, $lo, $hi) = $emedian->(\@input, 0, $#input);
   my ($lop) = $emedian->(\@input, 0, $lo);
   my ($hip) = $emedian->(\@input, $hi, $#input);

   return ($input[0], $lop, $median, $hip, $input[-1]);
}
```

In pure spirit of reuse, the [Raku][] version is copied almost verbatim.
I didn't want to venture into finding the equivalent of the `state
$emedian`, so I just put a sub and close upon the outer sub to get the
`@input` data. Apart from this, there's no difference with respect to
the [Perl][] version.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   my @values = (0, 0, 1, 2, 63, 61, 27, 13);
   my @fives = five-number-summary(@values);
   say @fives;
}

sub five-number-summary (*@input) {
   sub emedian ($from, $to) {
      my $twom = $from + $to;
      my $rem  = $twom % 2;
      my $lo = ($twom - $rem) / 2;
      my $hi = $lo + 1;
      my $medn = $rem ?? (@input[$lo] + @input[$hi]) / 2 !! @input[$lo];

      # https://en.wikipedia.org/wiki/Quartile - Tukey's hinges
      return [$medn, $rem ?? |($lo, $hi) !! |($lo, $lo)];
   }
   @input = @input.sort: { $^a <=> $^b };

   my ($median, $lo, $hi) = emedian(0, @input.end);
   my ($lop) = emedian(0, $lo);
   my ($hip) = emedian($hi, @input.end);

   return [@input[0], $lop, $median, $hip, @input[*-1]];
}
```

That's all for today... stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#172]: https://theweeklychallenge.org/blog/perl-weekly-challenge-172/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-172/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wikipedia page]: https://en.wikipedia.org/wiki/Five-number_summary
[Tukey]: https://en.wikipedia.org/wiki/John_Tukey
[Cooley]: https://en.wikipedia.org/wiki/James_Cooley
[Fast Fourier Transform]: https://en.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm
