---
title: PWC106 - Decimal String
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-04-01 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#106][].
> Enjoy!

# The challenge

> You are given numerator and denominator i.e. `$N` and `$D`. Write a script
> to convert the fraction into decimal string. If the fractional part is
> recurring then put it in parenthesis.

# The questions

One question is *what is the domain of the numerator and of the
denominator?* We will assume that they are integers, including negatives for
both the numerator and the denominator.

# The solution

Let's start with the requested function:

```perl
sub decimal_string ($N, $D) {
   my $sign = ($N < 0) ^ ($D < 0) ? '-' : '';
   for ($N, $D) { $_ = -$_ if $_ < 0 }

   my $r = $N % $D;
   (my $i, $N) = (($N - $r) / $D, $r);
   $i = $sign . $i if $i || $N;
   return $i unless $N;

   # keep track of all quotes and rests we find in the integer divisions
   my (@ds, %position_of);
   while ($N) {
      if (exists $position_of{$N}) {
         push @ds, '(', splice(@ds, $position_of{$N}), ')';
         last;
      }
      $position_of{$N} = @ds;
      $N *= 10;
      $r = $N % $D;
      (my $i, $N) = (($N - $r) / $D, $r);
      push @ds, $i;
   }
   return $i . '.' . join '', @ds;
}
```

There are a couple of shadowy corners that we have to take care of:

- we're going to do some integer maths and negative values can spoil the
  fun. For this reason, we take care of the sign at the very beginning and
  then normalize `$N` and `$D` to be both non-negative integers;
- if the division is exact (no remainder at all) then we avoid putting a
  `.` in the string, so we short-circuit the evaluation if the initial
  division is exact (i.e. `$N` is zero after it);
- the loop goes on until either `$N` becomes `0` (i.e. one of the successive
  divisions to find the decimal was finally exact) or we find a repetition
  in the remainder (this is the `if` block at the beginning of the `while`
  loop).

Apart from this, it's plain division algorithm like I was taught in school.

This seems to work fine:

```
$ perl perl/ch-2.pl 0 3
0

$ perl perl/ch-2.pl -1 3
-0.(3)

$ perl perl/ch-2.pl 1 3
0.(3)

$ perl perl/ch-2.pl 2 3
0.(6)

$ perl perl/ch-2.pl 6 3
2

$ perl perl/ch-2.pl 6 221
0.(027149321266968325791855203619909502262443438914)
```

**Wait a minute... should we trust this result?**

Maybe it's better to code also the function to transform the string
representation of a (possibly periodic) decimal number back into a fraction:

```perl
sub rational_pair ($x) {
   require Math::BigInt;
   my ($s, $i, $d) = $x =~ m{\A (-?) (\d*) (?:\. (.*))? \z}mxs;
   $d //= '';
   my ($ap, $p) = $d =~ m{\A (\d*) (?: \( (\d+) \) )?}mxs;
   my $pp = $i . $ap;
   $p //= '';
   my ($N, $D);
   if (my $lp = length $p) {
      $N = Math::BigInt->new($pp . $p) - Math::BigInt->new($pp);
      return (0, 1) unless $N;
      $D = Math::BigInt->new(('9' x length($p)) . ('0' x length($ap)));
   }
   else { # non-periodic
      $N = Math::BigInt->new($pp);
      $D = Math::BigInt->new('1' . ('0' x length($ap)));
   }
   my $g = $N ? gcd($N, $D) : 1;
   return ($s . ($N / $g), $D / $g);
}

sub gcd { my ($A, $B) = @_; ($A, $B) = ($B % $A, $A) while $A; return $B }
```

The initial parsing might be better because it would allow stuff like the
empty string, but whatever - it's a function for a double check, right?

After the parsing, we have the following parts:

- `$s` holds the sign (a negative sign `-` or the empty string)
- `$i` holds the integer part
- `$ap` holds the "anti-period", that is the part that goes *before*
  (*anti*) the period
- `$pp` holds whatever is not periodic, i.e. it is the stitching of `$i` and
  `$ap` without the decimal separator;
- `$p` holds the period

At this point, if the number is indeed periodic (i.e. `$p` is not the empty
string) we follow the rules for periodic numbers, otherwise we go with the
exact division algorithm.

This gives us numerator `$N` and denominator `$D`, although they might have
some factor in common. For this reason, we calculate the greatest common
divisor so that we can divide both by it.

Just before returning, we remember about the sign and put it back in the
numerator.

Indeed, that big period for fraction `6/221` is correct, as we can print it
back:

```
$ perl perl/ch-2.pl 6 221
0.(027149321266968325791855203619909502262443438914)
6/221
```


The whole script this time includes a few tests, because there's a lot of
corner cases to take into account:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub decimal_string ($N, $D) {
   my $sign = ($N < 0) ^ ($D < 0) ? '-' : '';
   for ($N, $D) { $_ = -$_ if $_ < 0 }

   my $r = $N % $D;
   (my $i, $N) = (($N - $r) / $D, $r);
   $i = $sign . $i if $i || $N;
   return $i unless $N;

   # keep track of all quotes and rests we find in the integer divisions
   my (@ds, %position_of);
   while ($N) {
      if (exists $position_of{$N}) {
         push @ds, '(', splice(@ds, $position_of{$N}), ')';
         last;
      }
      $position_of{$N} = @ds;
      $N *= 10;
      $r = $N % $D;
      (my $i, $N) = (($N - $r) / $D, $r);
      push @ds, $i;
   }
   return $i . '.' . join '', @ds;
}

sub rational_pair ($x) {
   require Math::BigInt;
   my ($s, $i, $d) = $x =~ m{\A (-?) (\d*) (?:\. (.*))? \z}mxs;
   $d //= '';
   my ($ap, $p) = $d =~ m{\A (\d*) (?: \( (\d+) \) )?}mxs;
   my $pp = $i . $ap;
   $p //= '';
   my ($N, $D);
   if (my $lp = length $p) {
      $N = Math::BigInt->new($pp . $p) - Math::BigInt->new($pp);
      return (0, 1) unless $N;
      $D = Math::BigInt->new(('9' x length($p)) . ('0' x length($ap)));
   }
   else { # non-periodic
      $N = Math::BigInt->new($pp);
      $D = Math::BigInt->new('1' . ('0' x length($ap)));
   }
   my $g = $N ? gcd($N, $D) : 1;
   return ($s . ($N / $g), $D / $g);
}

sub gcd { my ($A, $B) = @_; ($A, $B) = ($B % $A, $A) while $A; return $B }

if (@ARGV == 2) {
   my ($num, $den) = @ARGV;
   my $dec = decimal_string($num, $den);
   say $dec;
   say {*STDERR} join '/', rational_pair($dec);
}
else {
   require Test::More;
   Test::More->import;
   for my $test (
      [0, 1, '0', 0, 1],
      [0, -1, '0', 0, 1],
      [0, 100, '0', 0, 1],
      [1, 2, '0.5', 1, 2],
      [3, 6, '0.5', 1, 2],
      [-1, 2, '-0.5', -1, 2],
      [1, -2, '-0.5', -1, 2],
      [11, -22, '-0.5', -1, 2],
      [14, 7, '2', 2, 1],
      [14, -7, '-2', -2, 1],
      [1, 3, '0.(3)', 1, 3],
      [2, 6, '0.(3)', 1, 3],
      [1, 7, '0.(142857)', 1, 7],
      [-3, -21, '0.(142857)', 1, 7],
      [1, 221, '0.(004524886877828054298642533936651583710407239819)', 1, 221 ],
   ) {
      my ($N, $D, $exp_dec, $exp_n, $exp_d) = $test->@*;
      my $got_dec = decimal_string($N, $D);
      Test::More::is($got_dec, $exp_dec, "decimal_string($N, $D) is $exp_dec");
      my ($got_n, $got_d) = rational_pair($exp_dec);
      Test::More::is($got_n, $exp_n, "numerator for $exp_dec is $exp_n");
      Test::More::is($got_d, $exp_d, "denominator for $exp_dec is $exp_d");
   }
   done_testing();
}
```

When invoked with two arguments it will do what the challenge requests (the
transformation back to a fraction is printed on the standard error and can
be easily filtered out); otherwise, the test suite is invoked.

Stay safe in this... *period* 🙄

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#106]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-106/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-106/#TASK2
[Perl]: https://www.perl.org/
