---
title: PWC179 - Ordinal Number Spelling
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-08-24 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#179][]. Enjoy!

# The challenge

> You are given a positive number, `$n`.
>
> Write a script to spell the ordinal number.
>
> For example,
>
>     11 => eleventh
>     62 => sixty-second
>     99 => ninety-ninth

# The questions

Is there any indication of how to correctly spell bigger numbers in
English, like for non-mother-tongue people?

Also: is there an upper limit? I mean, I don't know what magnitude comes
after the octillion - I'll end up there.

# The solution

I know for sure there's a module in [Perl][]. I suspect there's a module
in [Raku][] too, but I'm not sure.

So, of course I'm rolling my own.

The strategy will be to find out the cardinal number, *then* turn that
into the ordinal. Let's start with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $n where * > 0 = 99) {
   put spelled-ordinal($n);
}

sub spelled-ordinal (Int:D $n where * > 0) {
   state %corrective-for = <
      one first
      two second
      three third
      five fifth
      eight eighth
      nine ninth
      twelve twelfth
      twenty twentieth
      thirty thirtieth
      forty fortieth
      fifty fiftieth
      sixty sixtieth
      seventy seventieth
      eighty eightieth
      ninety ninetieth
   >;
   my $spelled = spelled-cardinal($n);
   if my $match = $spelled ~~ / ^ (.*) (<[ - \s ]>) (\w+) $ / {
      my @parts = $match[0..*]».Str;
      my $last := @parts[*-1];
      $last = %corrective-for{$last}:exists
         ?? %corrective-for{$last}
         !! $last ~ 'th';
      $spelled = @parts.join('');
   }
   else {
      $spelled = %corrective-for{$spelled}:exists
         ?? %corrective-for{$spelled}
         !! $spelled ~ 'th';
   }

   return $spelled;
}

sub spelled-cardinal (Int:D $n is copy where * > 0) {
   state %name-for = <
      1 one
      2 two
      3 three
      4 four
      5 five
      6 six
      7 seven
      8 eight
      9 nine
      10 ten
      11 eleven
      12 twelve
      13 thirteen
      14 fourteen
      15 fiftheen
      16 sixteen
      17 seventeen
      18 eighteen
      19 nineteen
      20 twenty
      30 thirty
      40 forty
      50 fifty
      60 sixty
      70 seventy
      80 eighty
      90 ninety
   >;
   my @magnitudes = '', <
      thousand million billion trillion quatrillion
      quintillion sextillion septillion octillion
   >.Slip;

   my @spelling;
   while $n > 0 {
      my $lower = $n % 100;
      $n = (($n - $lower) / 100).Int;
      my $hundredths = $n % 10;
      $n = (($n - $hundredths) / 10).Int;

      my @chunk;

      @chunk.push: "%name-for{$hundredths}-hundred" if $hundredths;

      if $lower {
         if %name-for{$lower}:exists {
            @chunk.push: %name-for{$lower};
         }
         else {
            my $units = $lower % 10;
            my $decs  = $lower - $units;
            @chunk.push: "%name-for{$decs}-%name-for{$units}";
         }
      }

      my $magnitude = @magnitudes.shift;
      @chunk.push: $magnitude if $magnitude.chars && @chunk.elems;

      @spelling.unshift: @chunk if @chunk;
   }

   return @spelling.join(', ');
}
```

I find the [Perl][] version slightly easier on the eyes:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my $n = shift // 99;
say spelled_ordinal($n);

sub spelled_ordinal ($n) {
   state $corrective_for = {
      qw<
         one first
         two second
         three third
         five fifth
         eight eighth
         nine ninth
         twelve twelfth
         twenty twentieth
         thirty thirtieth
         forty fortieth
         fifty fiftieth
         sixty sixtieth
         seventy seventieth
         eighty eightieth
         ninety ninetieth
      >
   };
   my $spelled = spelled_cardinal($n);
   my ($pre, $last) = $spelled =~ m{\A (.*[-\s]) (\w+) \z}mxs;
   ($pre, $last) = ('', $spelled) unless defined $last;

   $last = exists $corrective_for->{$last}
      ? $corrective_for->{$last}
      : $last . 'th';

   return $pre . $last;
}

sub spelled_cardinal ($n) {
   state $name_for = {
      qw<
         1 one
         2 two
         3 three
         4 four
         5 five
         6 six
         7 seven
         8 eight
         9 nine
         10 ten
         11 eleven
         12 twelve
         13 thirteen
         14 fourteen
         15 fiftheen
         16 sixteen
         17 seventeen
         18 eighteen
         19 nineteen
         20 twenty
         30 thirty
         40 forty
         50 fifty
         60 sixty
         70 seventy
         80 eighty
         90 ninety
      >
   };
   my @magnitudes = ('', qw<
         thousand million billion trillion quatrillion
         quintillion sextillion septillion octillion
      >
   );

   my @spelling;
   while ($n > 0) {
      my $lower = $n % 100;
      $n = int(($n - $lower) / 100);
      my $hundredths = $n % 10;
      $n = int(($n - $hundredths) / 10);

      my @chunk;

      push @chunk, "$name_for->{$hundredths}-hundred" if $hundredths;

      if ($lower) {
         if (exists $name_for->{$lower}) {
               push @chunk, $name_for->{$lower};
         }
         else {
            my $units = $lower % 10;
            my $decs  = $lower - $units;
            push @chunk, "$name_for->{$decs}-$name_for->{$units}";
         }
      }

      my $magnitude = shift @magnitudes;
      push @chunk, $magnitude if length($magnitude) && @chunk;

      unshift @spelling, join ' ', @chunk if @chunk;
   }

   return join ', ', @spelling;
}
```

My feeling about how complex data structures are handled keeps telling
me that I prefer the [Perl][] way. Maybe it's the fact that there are
only two ways of doing hierarchical things, while I always struggle in
understanding how things are assembled in [Raku][].

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#179]: https://theweeklychallenge.org/blog/perl-weekly-challenge-179/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-179/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
