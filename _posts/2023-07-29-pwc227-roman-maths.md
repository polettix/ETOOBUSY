---
title: PWC227 - Roman Maths
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-07-29 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#227][].
> Enjoy!

# The challenge

> Write a script to handle a 2-term arithmetic operation expressed in Roman
> numeral.
>
> **Example*
>
>     IV + V     => IX
>     M - I      => CMXCIX
>     X / II     => V
>     XI * VI    => LXVI
>     VII ** III => CCCXLIII
>     V - V      => nulla (they knew about zero but didn't have a symbol)
>     V / II     => non potest (they didn't do fractions)
>     MMM + M    => non potest (they only went up to 3999)
>     V - X      => non potest (they didn't do negative numbers)

# The questions

There are a lot of explanations for subtleties in the example, but I'd still
ask about the input format:

- can we trust it's correct? I'll assume yes.
- should we account for a variable amount of whitespaces? I'll assume yes.

# The solution

This was interesting, although it felt like a chore at a certain point. Yes,
yes... I know there's surely a plethora of modules to go to and from Roman
numberals, but I'm from Rome and I thought I owed this to the city I live
in.

At the end of the day, it's parse/calculate/encode, just with a few checks
here and there.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

say $_, ' => ', roman_maths($_) for @ARGV;

sub roman_maths ($expression) {
   my ($first, $op, $second) = $expression =~ m{
      \A\s* ([IVXLCDM]+) \s* ([-+/*] | \*\*) \s* ([IVXLCOM]+) \s*\z
   }mxs or return 'nescio';
   $first  = roman2dec_no_validate($first)  // return 'nescio';
   $second = roman2dec_no_validate($second) // return 'nescio';
   my $result = $op eq '+' ? ($first + $second)
      : $op eq '-' ? ($first - $second)
      : $op eq '*' ? ($first * $second)
      : $op eq '/' ? ($first % $second ? -1 : $first / $second)
      : $op eq '**' ? ($first ** $second) : 'nescio';
   return dec2roman($result);
   return 'non potest';
}

sub dec2roman ($dec) {
   return 'nulla' if $dec == 0;
   return 'non potest' if $dec < 0 || $dec >= 4000;
   my $retval = '';
   while ($dec > 0) {
      if ($dec >= 1000) {
         $retval .= 'M' x int($dec / 1000);
         $dec %= 1000;
      }
      elsif ($dec >= 900) {
         $retval .= 'CM';
         $dec -= 900;
      }
      elsif ($dec >= 500) {
         $retval .= 'D';
         $dec -= 500;
      }
      elsif ($dec >= 400) {
         $retval .= 'CD';
         $dec -= 400;
      }
      elsif ($dec >= 100) {
         $retval .= 'C' x int($dec / 100);
         $dec %= 100;
      }
      elsif ($dec >= 90) {
         $retval .= 'XC';
         $dec -= 90;
      }
      elsif ($dec >= 50) {
         $retval .= 'L';
         $dec -= 50;
      }
      elsif ($dec >= 40) {
         $retval .= 'XL';
         $dec -= 40;
      }
      elsif ($dec >= 10) {
         $retval .= 'X' x int($dec / 10);
         $dec %= 10;
      }
      else {
         state $lookup = [qw< * I II III IV V VI VII VIII IX >];
         $retval .= $lookup->[$dec];
         $dec = 0;
      }
   }
   return $retval;
}

sub roman2dec_no_validate ($string) {
   state $value_for = {
      I => 1,
      V => 5,
      X => 10,
      L => 50,
      C => 100,
      D => 500,
      M => 1000,
   };
   my $accumulator = 0;
   my $following = 0; # good enough initialization
   for my $letter (reverse split m{}mxs, $string) {
      my $this = $value_for->{$letter};
      if ($this >= $following) {
         $accumulator += $this;
      }
      else {
         $accumulator -= $this;
      }
      $following = $this;
   }
   return $accumulator;
}
```

[Raku][] time. I was lucky to copy most of the implementation from the
[Perl][] one above, with due changes where it's needed.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@expressions) { put($_, ' => ', roman-maths($_)) for @expressions }

sub roman-maths ($expression) {
   my $match = $expression ~~ /
   ^^
      \s* (<[ I V X L C D M]>+)
      \s* (<[ \- \+ \/ \*\* \* ]>+)
      \s* (<[ I V X L C O M]>+)
      \s*
   $$/ or return 'nescio';
   my $first = $match[0].Str;
   my $op = $match[1].Str;
   my $second = $match[2].Str;
   $first  = roman2dec-no-validate($first)  // return 'nescio';
   $second = roman2dec-no-validate($second) // return 'nescio';
   my $result = $op eq '+' ?? ($first + $second)
      !! $op eq '-' ?? ($first - $second)
      !! $op eq '*' ?? ($first * $second)
      !! $op eq '/' ?? ($first % $second ?? -1 !! $first / $second)
      !! $op eq '**' ?? ($first ** $second) !! 'nescio';
   return dec2roman($result);
   return 'non potest';
}

sub dec2roman ($dec is copy) {
   return 'nulla' if $dec == 0;
   return 'non potest' if $dec < 0 || $dec >= 4000;
   my $retval = '';
   while $dec > 0 {
      if $dec >= 1000 {
         $retval ~= 'M' x ($dec div 1000);
         $dec %= 1000;
      }
      elsif $dec >= 900 {
         $retval ~= 'CM';
         $dec -= 900;
      }
      elsif $dec >= 500 {
         $retval ~= 'D';
         $dec -= 500;
      }
      elsif $dec >= 400 {
         $retval ~= 'CD';
         $dec -= 400;
      }
      elsif $dec >= 100 {
         $retval ~= 'C' x ($dec div 100);
         $dec %= 100;
      }
      elsif $dec >= 90 {
         $retval ~= 'XC';
         $dec -= 90;
      }
      elsif $dec >= 50 {
         $retval ~= 'L';
         $dec -= 50;
      }
      elsif $dec >= 40 {
         $retval ~= 'XL';
         $dec -= 40;
      }
      elsif $dec >= 10 {
         $retval ~= 'X' x ($dec div 10);
         $dec %= 10;
      }
      else {
         state @lookup = < * I II III IV V VI VII VIII IX >;
         $retval ~= @lookup[$dec];
         $dec = 0;
      }
   }
   return $retval;
}

sub roman2dec-no-validate ($string) {
   state %value_for =
      I => 1,
      V => 5,
      X => 10,
      L => 50,
      C => 100,
      D => 500,
      M => 1000,
   ;
   my $accumulator = 0;
   my $following = 0; # good enough initialization
   for $string.comb.reverse -> $letter {
      my $this = %value_for{$letter};
      if $this >= $following {
         $accumulator += $this;
      }
      else {
         $accumulator -= $this;
      }
      $following = $this;
   }
   return $accumulator;
}
```

Cheers!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#227]: https://theweeklychallenge.org/blog/perl-weekly-challenge-227/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-227/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
