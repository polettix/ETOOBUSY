---
title: PWC134 - Pandigital Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-10-13 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#134][]. Enjoy!

# The challenge

> Write a script to generate first 5 `Pandigital Numbers` in base 10.
>
> As per the [wikipedia][], it says:
>
>> A pandigital number is an integer that in a given base has among its
>> significant digits each digit used in the base at least once.

# The questions

I know that it's mainly [Perl][] and [Raku][] and that it says
*numbers*, but is it allowed to manipulate strings instead? I hope so...

The task is indeed very limited, so another question is: are we expected
to generalize upon this task? Of course... I'm assuming yes!

I have to admit that I had a hard time understanding the question only
from the quote above - I eventually realized that we were talking about
all possible digits allowed in the base (e.g. for base `10` I was
thinking that the only digits *used* were `0` and `1`...). Anyway the
[wikipedia][] page cleared it all.

Last, I'm understanding "the first five..." as "the lowest five...",
right?!?


# The solution

As anticipated in the questions, I decided to both address a more
general problem and to have a strings-based approach.

The generalization part is... up to some limit:

- we can cope with a generic base, but only as an integer between `1`
  and `36` (both included).
- we will accept a generic number of items to be printed out, but only
  up to the limit that our lazyness allows us. More on this later!

One insight is that, for low number of desired items, the solution will
be some permutation upon the absolute minimum value (which can be found
in the [wikipedia][] page). In particular, in base 10 we have that this
is the minimum:

```
1023456789
```

which means that the lowest numbers will all start with `1` and then
contain some permutation of the rest of the string, i.e. `023456789`,
that is a permutation upon 9 digits. This will give us the lowest $9!$
elements, which is a fair amount of pandigital numbers and we will bail
out if more are requested. In our case, 5 elements is well within the
limit!

Then I thought about doing the least number of permutations possible. It
turns out that to take 5 elements we only need to fiddle with the last 3
digits, because this will give us 6 different permutations (i.e. one
more than needed). More generally, if we need $n$ items, we will have to
fiddle with $m$ digits at the end, such that $m! \leq n$.

At this point, though, there is the issue of getting the *lowest* ones.
Using a generic permutation algoritm would mean generating all $m!$
elements, then sorting them, then taking the first $n$. Ugh.

To cope with this problem, we can adopt an algorithm that generates all
permutations over a set *in order*. Of course, this means that the items
to be permuted adhere to some definition of ordering, which is indeed
our case (also working when the digits end and we start using letters,
like in hexadecimal numbers).

It turns out that such an algorithm is readily available and described
in section [Generation in lexicographic order][].

Now we have everything we need... on with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;

sub next-permutation (@arrangement) {
   my $i = @arrangement.end - 1;
   --$i while $i >= 0 && @arrangement[$i] >= @arrangement[$i + 1];
   return unless $i >= 0;
   my $j = @arrangement.end;
   --$j while @arrangement[$i] >= @arrangement[$j];
   @arrangement[$i, $j] = @arrangement[$j, $i];
   @arrangement[$i + 1 .. *]  = @arrangement[$i + 1 .. *].reverse;
   return @arrangement;
}

subset PosInt of Int:D where * > 0;
subset Base of PosInt where * <= 36;
sub pandigital-numbers (PosInt $n is copy, Base $b) {
   my ($n-digits, $factorial) = 1, 1;
   $factorial *= ++$n-digits while $factorial < $n;
   die "I'm too lazy for more general algorithms"
      if $n-digits >= $b - 1;

   state $p36-min = '1023456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   my $fix = $p36-min.substr(0, $b - $n-digits);
   my @moving = $p36-min.substr($b - $n-digits, $n-digits).comb(/./);
   gather while $n > 0 {
      take $fix ~ @moving.join('');
      @moving = next-permutation(@moving) if --$n;
   };
}

sub MAIN (PosInt $n = 5, Base $b = 10) {
   .put for pandigital-numbers($n, $b);
}
```

I'm particularly happy about function `next-permutation` because it's
totally *stateless* - we give it an input arrangement, it computes the
next lexicographic permutation and gives it back.

The check in `pandigital-numbers` is to make sure that this simplified
algorithm works. For anything beyond... people can extend this!

The [Perl][] counterpart is very similar:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub next_permutation (@arrangement) {
   my $i = $#arrangement - 1;
   --$i while $i >= 0 && $arrangement[$i] >= $arrangement[$i + 1];
   return unless $i >= 0;
   my $end = my $j = $#arrangement;
   --$j while $arrangement[$i] >= $arrangement[$j];
   @arrangement[$i, $j] = @arrangement[$j, $i];
   @arrangement[$i + 1 .. $end]  = reverse @arrangement[$i + 1 .. $end];
   return @arrangement;
}

sub pandigital_numbers ($n = 5, $b = 10) {
   my ($n_digits, $factorial) = (1, 1);
   $factorial *= ++$n_digits while $factorial < $n;
   die "I'm too lazy for more general algorithms"
      if $n_digits >= $b - 1;

   state $p36_min = '1023456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   my $fix = substr $p36_min, 0, $b - $n_digits;
   my @moving = split m{}mxs, substr $p36_min, $b - $n_digits, $n_digits;
   map {
      @moving = next_permutation(@moving) if $_;
      join '', $fix, @moving;
   } 0 .. $n - 1;
}

say for pandigital_numbers(@ARGV);
```

The `gather`/`take` can be easily (and elegantly) transformed into a
`map`, which is good. Apart from this, it's really a faithful
translation.

I hope you enjoyed the ride and until next time... stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#134]: https://theweeklychallenge.org/blog/perl-weekly-challenge-134/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-134/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wikipedia]: https://en.wikipedia.org/wiki/Pandigital_number
[Generation in lexicographic order]: https://en.wikipedia.org/wiki/Permutation#Generation_in_lexicographic_order
