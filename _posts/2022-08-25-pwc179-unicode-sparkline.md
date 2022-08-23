---
title: PWC179 - Unicode Sparkline
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-08-25 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#179][].
> Enjoy!

# The challenge

> You are given a list of positive numbers, `@n`.
>
> Write a script to print sparkline in Unicode for the given list of
> numbers.

# The questions

Why - *oh why?!?* - Unicode glyphs for half and full block are so
irregular with respect to the others?!? Luckily enough, the font I used
is great for this!

# The solution

With just a couple of hints from [Rosetta code][] (but taking into
accounts the possibility of a flat line), here we go with [Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @n = @ARGV ? @ARGV : qw<  2 3 4 5 6 7 8 9 8 7 6 5 4 3 2  >;
binmode STDOUT, ':encoding(UTF-8)';
say sparkline_string(@n);

sub sparkline_string (@n) {
   state $sparks = [map { chr($_) } 0x2581 .. 0x2588];
   state $n_sparks = $sparks->@*;

   my ($min, $max) = @n[0, 0];
   for my $i (@n) {
      if ($i < $min)    { $min = $i }
      elsif ($i > $max) { $max = $i }
   }

   my @chars;
   if (my $delta = ($max - $min)) {
      my $scale = ($n_sparks - 1) / $delta;
      @chars = map { $sparks->[($_ - $min) * $scale] } @n;
   }
   else {
      @chars = ($sparks->[$n_sparks / 2]) x @n;
   }

   return join '', @chars;
}
```

When the minimum and the maximum are the same, we need to generate a
flat line and we're putting it in the middle. For all other cases we
normalize and translate.

[Raku][] now:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@argv) {
   my @n = @argv ?? @argv.Slip !! < 2 3 4 5 6 7 8 9 8 7 6 5 4 3 2 >;
   put sparkline-string(@n);
}

sub sparkline-string (@n) {
   state @sparks = (0x2581 .. 0x2588).map({ .chr }) ;
   state $n-sparks = @sparks.elems;
   my ($min, $max) = @n.minmax.bounds;

   my @chars;
   if my $delta = ($max - $min) {
      my $scale = ($n-sparks - 1) / $delta;
      @chars = @n.map({ @sparks[($_ - $min) * $scale] });
   }
   else {
      @chars = @sparks[$n-sparks / 2] xx @n.elems;
   }

   return @chars.join('');
}
```

Same approach, slightly different syntax.

Stay safe folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#179]: https://theweeklychallenge.org/blog/perl-weekly-challenge-179/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-179/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Rosetta code]: https://rosettacode.org/wiki/Sparkline_in_unicode
