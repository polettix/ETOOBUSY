---
title: PWC176 - Reversible Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-08-04 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#176][].
> Enjoy!

# The challenge

> Write a script to find out all `Reversible Numbers` below `100`.
>
>> A number is said to be a reversible if sum of the number and its
>> reverse had only odd digits.
>
> For example,
>
>     36 is reversible number as 36 + 63 = 99 i.e. all digits are odd.
>     17 is not reversible as 17 + 71 = 88, none of the digits are odd.
>
> Output
>
>     10, 12, 14, 16, 18, 21, 23, 25, 27,
>     30, 32, 34, 36, 41, 43, 45, 50, 52,
>     54, 61, 63, 70, 72, 81, 90

# The questions

I'm assuming that we're talking about positive integer numbers here,
right?

Also, the concept of *reverse* is defined not in matematical terms (at
least that I can recognize, but YMMV) but in textual terms (take the
digits and read them in reverse order).

# The solution

There are a few considerations that can be done about this challenge:

- Interestingly, the *reversing* operation is not invertible. All
  integers with a trailing `0` map onto an integer that has fewer
  digits, but the *reverse* does not happen.
- single-digit number don't cut it, because they happen to be their own
  reverse, which means doubling when doing the sum, which means an even
  number (multiple of 2).
- two-digits number cannot have their sum go beyond `99`, which means that
  the two digits must have a sum that is at most `9`.
  
The last bullet bears an explanation. If we have a number $h \cdot 10 +
l$, we end up with the following sum:

$$
S = (h + l) \cdot 10 + (h + l)
$$

Now if $h + l > 9$, it can only be a number below `19` (the maximum
possible value with summing two digits is $9 + 9 = 18 < 19$), i.e. it's
a number of type $10 + o$ where $o < 9$ . This leads us to:

$$
S = (10 + o) \cdot 10 + 10 + o \\
S = 1 \cdot 100 + (o + 1) \cdot 10 + o
$$

The second digit is actually $o + 1$ because $o < 9 \Rightarrow o + 1 <
10$. This can't possibly have all odd digits, because it contains both
$o + 1$ and $o$. Only one of them can be odd, right?

So we're left with two-digit integers $h \cdot 10 + l$ where $h + l <
10$, and these are the integers we will look for, starting from
[Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say join ', ', reversible_numbers();

sub reversible_numbers {
   my @retval;
   for my $lo (0 .. 4) {
      for (my $hi = $lo + 1; $hi <= 9 - $lo; $hi += 2) {
         push @retval, $lo * 10 + $hi if $lo;
         push @retval, $hi * 10 + $lo;
      }
   }
   return sort { $a <=> $b } @retval;
}
```

*Almost* every time we find a good number, the reverse is good as well.
The only exception is when the good number ends with a `0`, in which
case we ignore the reverse. This accounts for the `if $lo` in the first
`push` line.

We're actually going bottom to top here; the first digit is constrained
to be at most 4, because it's the lowest first digit that allows us
finding out all target numbers considering the double finding (i.e. `45`
is a solution as well as `54` and from that point on we will only find
integers that we already found thanks to this *reversing* rule).

For the same reason, the *other* digit starts from the first plus `1`,
so that they have opposite oddness (yielding an odd sum) and we don't
count candidates twice. This is another time where I found that the
C-style `for` hit the nail right in the head.

The resulting array of collected items is not sorted, so we might just
return it as we're not requested to do the sorting. Anyway it does not
cost too much and it's nice to see the result in ascending order, so why
not?

The [Raku][] counterpart is mostly the same, only taking advantage of
`gather`/`take`, which I love:

```raku
#!/usr/bin/env raku
use v6;

reversible-numbers().join(', ').put;

sub reversible-numbers {
   return gather {
      for 0 .. 4 -> $lo {
         my $hi = $lo + 1;
         while $hi <= 9 - $lo {
            take $lo * 10 + $hi if $lo;
            take $hi * 10 + $lo;
            $hi += 2;
         }
      }
   }.sort
}
```

And this is all for today, stay safe and hydrated!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#176]: https://theweeklychallenge.org/blog/perl-weekly-challenge-176/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-176/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
