---
title: PWC178 - Quater-imaginary Base
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-08-17 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#178][]. Enjoy!

# The challenge

> Write a script to convert a given number (base 10) to quater-imaginary
> base number and vice-versa. For more informations, please checkout
> [wiki page][].
>
> For example,
>
>     $number_base_10 = 4
>     $number_quater_imaginary_base = 10300

# The questions

Wow, this can be *very* big. So, I'll assume that we're dealing with
*complex numbers* where *both* the real and the imaginary parts are
*integers*. There should be an extension for other inputs, but it's too
big to fit in the narrow spaces of this blog.

# The solution

Let's start with [Raku][]. The heart of the transformation fis being
able to turn an integer from base $10$ into base $-4$ (code is an
adaptation from one of the implementations in wikipedia page [Negative
base][wp]):

```raku
multi sub b10-to-bm (Int:D $x is copy, Int:D $m where * < 0 --> Str) {
   my @digits;
   while $x {
      my $rem = $x % $m;
      $x = (($x - $rem) / $m).Int;
      ($rem, $x) = $rem - $m, $x + 1 if $rem < 0;
      @digits.unshift: $rem;
   }
   return @digits.join('');
}
```

With this in our hands, we can now transform the real and the imaginary
parts separately. The latter is first multiplied by two, we will later
shift it to the right later, corresponding to a division by 2 where one
digit might possibly go after the dot. The two parts are then
interleaved, which is the same as summing them after separating all
digits with `0`s.

```raku
#!/usr/bin/env raku
use v6;

sub MAIN (Str:D() $x) { put to-m4i($x) }


sub to-m4i (Complex:D() $cx) {
   my $real = b10-to-bm($cx.re.Int, -4).comb.join('0') || 0;
   my $img  = b10-to-bm(-2 * $cx.im.Int, -4).comb.join('0');
   if $img.chars {
      my $after = $img.substr(*-1, 1);
      $img.substr-rw(*-1, 1) = '';
      $real += $img if $img.elems;
      $real ~= '.' ~ $after if $after > 0;
   }
   return $real;
}
```

[Perl][] now:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say to_m4i(shift // 4);

sub to_m4i ($x) {
   my ($real, $img) = parse_complex($x);
   $real = join('0', split m{}mxs, b10_to_bm($real, -4)) || 0;
   if ($img) {
      $img  = join('0', split m{}mxs, b10_to_bm(-2 * $img, -4));
      my $after = substr $img, -1, 1, '';
      $real += $img if $img;
      $real .= '.' . $after if $after;
   }
   return $real;
}

sub b10_to_bm ($x, $m) {
   my @digits;
   while ($x) {
      my $rem = $x % $m;
      $x = (($x - $rem) / $m);
      ($rem, $x) = ($rem - $m, $x + 1) if $rem < 0;
      unshift @digits, $rem;
   }
   return join '', @digits;
}
```

I added a parsing function for complex numbers which accepts a wider
range of inputs than the [Raku][] counterpart:

```perl
sub parse_complex ($x) {
   $x =~ m{
      \A\s*(?:
            (?<real> 0 | -?[1-9]\d*)
         |  (?<real> 0 | -?[1-9]\d*) \s* (?<img> [-+]  (?:[1-9]\d*|))i
         |                               (?<img> [-+]? (?:[1-9]\d*|))i
      )\s*\z
   }mxs;
   my $real = $+{real} // 0;
   my $img = $+{img} // 0;
   $img = 1 if $img eq '' || $img eq '+';
   $img = -1 if $img eq '-';
   return ($real, $img);
}
```

I hope it's complete, it seemed to work with a few corner cases I tried.

OK, enough for today, stay safe everybody!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#178]: https://theweeklychallenge.org/blog/perl-weekly-challenge-178/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-178/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wiki page]: https://en.wikipedia.org/wiki/Quater-imaginary_base
[wp]: https://en.wikipedia.org/wiki/Negative_base
