---
title: PWC140 - Add Binary
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-11-24 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#140][]. Enjoy!

# The challenge

> You are given two decimal-coded binary numbers, `$a` and `$b`.
> 
> Write a script to simulate the addition of the given binary numbers.
> 
>> The script should simulate something like $a + $b. (operator
>> overloading)
> 
> **Example 1**
>
>     Input: $a = 11; $b = 1;
>     Output: 100
>
> **Example 2**
>
>     Input: $a = 101; $b = 1;
>     Output: 110
>
> **Example 3**
>
>     Input: $a = 100; $b = 11;
>     Output: 111

# The questions

I'm not entirely sure what we mean by *decimal-coded binary numbers*, as
they are used in the sum they're... binary-coded numbers. Whatever.

I'm also not sure what we mean by simulating the operator overloading.
Should I do actual operator overloading, or is it sufficient to
implement the underlying operations, and leave the overloading as a
simple exercise for the reader?


# The solution

We will take two different approaches this time.

In [Raku][] we'll just make it do the math, by converting from and two
base 2:

```raku
#!/usr/bin/env raku
use v6;
subset Bin of Str where * ~~ /^ <[0 1]>+ $/;
sub add-binary (Bin() $a, Bin() $b) {
   return ($a.parse-base(2) + $b.parse-base(2)).base(2);
}
sub MAIN (Bin() $A = 101, Bin() $B = 11) { put add-binary($A, $B) }
```

I decided to implement a new type `Bin`, defined as a subset of
*strings* that contain only `0` or `1` characters. Using strings is
instrumental to convert from base 2 (via `parse-base(2)`).

Note that the type of the function arguments are provided with the two
parentheses. This instructs [Raku][] to perform the conversion in case
what is provided is not readily in the right state, e.g. when we pass an
`IntStr` or an `Int`.

OK. OK.

Here's the overloading part:

```raku
#!/usr/bin/env raku
use v6;
subset Bin of Str where * ~~ /^ <[0 1]>+ $/;
sub add-binary (Bin() $a, Bin() $b) {
   return ($a.parse-base(2) + $b.parse-base(2)).base(2);
}
multi sub infix:<+> (Bin $A, Bin $B) { add-binary($A, $B) }
sub MAIN (Bin() $A = 101, Bin() $B = 11) { put $A + $B }
```

Well, [Perl][] time now. We're going to use a different algorithm here,
actually *implementing* the sum in the hard, binary way, sequentially
looking at each bit pair and managing a carry over bit. *It's not meant
for production, right?!?*

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

package Bin;
use overload
   '+' => sub ($A, $B, @whatever) {
      my @A = split m{}mxs, $$A;
      my @B = split m{}mxs, $$B;
      my @result;
      my $carry = 0;
      while (@A || @B) {
         my $sum = $carry + (pop(@A) // 0) + (pop(@B) // 0);
         unshift @result, $sum & 0x01;
         $carry = $sum >> 1;
      }
      unshift @result, $carry if $carry;
      @result = (0) unless @result;
      return Bin->new(join '', @result);
   },
   '""' => sub ($x, @whatever) { '' . $$x };
sub new ($p, $x) { return bless \$x, $p }

package main;
sub Bin ($x) { return Bin->new($x) }

say Bin($ARGV[0] // 11) + Bin($ARGV[1] // 1);
```

The operator overloading can distract a bit, but not too much.

I decided to throw a convenience `Bin()` function to simplify the `Bin`
package constructor calling. The class holds the number/string in a
reference to a scalar, which is all that we need in this case.

The algorithm itself works on each "bit" in the string representation of
the inputs. They are split to get each digit, then worked sequentally
with the carry. I hope I didn't miss any corner case!!!

I think it's enough at this point to feel slighly *overloaded*, so
please stay safe and see you soon!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#140]: https://theweeklychallenge.org/blog/perl-weekly-challenge-140/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-140/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
