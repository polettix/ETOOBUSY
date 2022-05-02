---
title: PWC163 - Sum Bitwise Operator
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-05-03 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#163][]. Enjoy!

# The challenge

> You are given list positive numbers, `@n`.
>
> Write script to calculate the sum of bitwise & operator for all unique
> pairs.
>
> **Example 1**
>
>     Input: @n = (1, 2, 3)
>     Output: 3
>
>     Since (1 & 2) + (2 & 3) + (1 & 3) => 0 + 2 + 1 =>  3.
>
> **Example 2**
>
>     Input: @n = (2, 3, 4)
>     Output: 2
>
>     Since (2 & 3) + (2 & 4) + (3 & 4) => 2 + 0 + 0 =>  2.

# The questions

Oh well this is Christmas in May.

That *unique pair* thing lends itself to soooo many interpretations that
I'm ashamed of myself:

- sum only pairs that are truly unique, crossing out those that repeat?
- find all pairs, keep one instance of each and calculate?
- are pairs ordered, i.e. is $(1, 2)$ the same as $(2, 1)$ or not?
- sum all possible pairs formed by taking an element and another element
  on the right of the first one?

I'll stick to the last one, i.e.:

- take (removing) the first item in `@n` and form one "unique" pair with all
  elements in the rest of `@n`
- repeat with the rest of `@n`.

What if `@n` is empty? I'll assume 0 is OK.

What if it only contains one element? I'll assume that element is the
answer, although 0 would be a perfectly sensible alternative because...
there's no pair!

# The solution

OK, having chosen the most boring of the alternative interpretations,
I'll try to spice things up a bit in [Raku][] by trying to do everything
through recursion in good ol' functional style. It's a bit stretched but
it works:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@n) { put sb(|@n) }

multi sub sb  ()            { 0                         }
multi sub sb  ($n)          { $n                        }
multi sub sb  ($n, $m)      { $n +& $m                  }
multi sub sb  ($n, *@r)     { sbf($n, |@r) + sb(|@r)    }
multi sub sbf ($n, $m)      { sb($n, $m)                }
multi sub sbf ($n, $m, *@r) { sb($n, $m) + sbf($n, |@r) }
```

To keep things *regular* I adopted an abbreviation for the main
function, i.e. `sb`. Cases for 0, 1, and 2 elements are "special"
end-cases, and the last one is the recursive one.

Function `sbf` has two alternatives too, and is needed to iterate the
first element with all the rest of the array. In this case it always
gets *at least* two elements, so we have to cope with two cases only
with `multi`.

After this excercise in style, it's time for good ol' dependable
[Perl][] with a no-frills iterative implementation:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

say sum_bitwise(@ARGV);

sub sum_bitwise (@n) {
   return 0     if @n == 0;
   return $n[0] if @n == 1;
   my $retval = 0;
   for my $i (0 .. $#n - 1) {
      $retval += $n[$i] & $n[$_] for $i + 1 .. $#n;
   }
   return $retval;
}
```

Who needs `multi` when we have post-conditions?

Who needs to *worry* about tail-recursion optimization when we have
`for`?

Forget about that macacademia functional stuff, we're here to do stuff
and get the job done. ***Guh!***

Whatever your style, stay safe please!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#163]: https://theweeklychallenge.org/blog/perl-weekly-challenge-163/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-163/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
