---
title: PWC164 - Happy Numbers
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-05-11 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#164][].
> Enjoy!

# The challenge

> Write a script to find the **first 8 Happy Numbers** in base 10. For
> more information, please check out **Wikipedia**.
>
> Starting with any positive integer, replace the number by the sum of
> the squares of its digits, and repeat the process until the number
> equals 1 (where it will stay), or it loops endlessly in a cycle which
> does not include 1.
>
> Those numbers for which this process end in 1 are happy numbers, while
> those numbers that do not end in 1 are unhappy numbers.
>
> **Example**
>
> 19 is Happy Number in base 10, as shown:
>
>     19 => 1^2 + 9^2
>        => 1   + 81
>        => 82 => 8^2 + 2^2
>              => 64  + 4
>              => 68 => 6^2 + 8^2
>                    => 36  + 64
>                    => 100 => 1^2 + 0^2 + 0^2
>                           => 1 + 0 + 0
>                           => 1

# The questions

You know, the usual suspects...

- "first 8 happy numbers** implies an ordering based on the numbers'
  values, right?

- can I skip reading the [Wikipedia][] page and assume the explanation
  and the example are sufficient?

# The solution

This challenge seems to scream about using some sort of cache. I a
number is happy, so are all the "intermediates" that separate that
number from becoming 1. On the other hand, if we find a cycle without a
1 inside, we know for sure that *all* elements in that cycle are not
happy.

So, to start with, we keep a couple variables with our past knowledge
about previous calls to the function, as `state` variables to keep this
knowledge. Both will be hash references because that's how we can track
flags easily in [Perl][]. The `$is_happy` is initialized to contain 1,
of course, as it's the quintessential happy number. We can, of course,
put these caches at work immediately.

```perl
sub is_happy ($n) {
   state $is_happy = { 1 => 1 };
   state $is_not_happy = {};
   return 1 if $is_happy->{$n};
   return 0 if $is_not_happy->{$n};
...
```

If we get past this point, the number is *unknown* and we have to
investigate. We will track our effort as a *round*: if we end up with a
1 the whole round will be added to the `$is_happy` hash, otherwise all
elements will be added to the `$is_not_happy` cache:

```perl
   ...
   my %round;
   while (! $round{$n}) {
      $round{$n} = 1;
      $n = sum map { $_ * $_ } split m{}mxs, $n;
      if ($n == 1) {
         $is_happy->{$_} = 1 for keys %round;
         return 1;
      }
   }
   $is_not_happy->{$_} for keys %round;
   return 0;
}
```

And this is really it. At this point, we just have to iterate until we
find enough happy numbers, ending with the following complete program:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'sum';

my $wanted = shift // 8;
my $n = 1;
my @happy;
while (@happy < $wanted) {
   push @happy, $n if is_happy($n);
   ++$n;
}
say join ', ', @happy;

sub is_happy ($n) {
   state $is_happy = { 1 => 1 };
   state $is_not_happy = {};
   return 1 if $is_happy->{$n};
   return 0 if $is_not_happy->{$n};
   my %round;
   while (! $round{$n}) {
      $round{$n} = 1;
      $n = sum map { $_ * $_ } split m{}mxs, $n;
      if ($n == 1) {
         $is_happy->{$_} = 1 for keys %round;
         return 1;
      }
   }
   $is_not_happy->{$_} for keys %round;
   return 0;
}
```

I played a bit with the idea to provide an iterator, but laziness won
eventually.

The [Raku][] counterpart allows us to show off a bit with hyperstuff and
Unicode operators. At the end of the day, though, it's the same
algorithm with a shinier look.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $wanted = 8) {
   my $n = 1;
   my @happy;
   while @happy < $wanted {
      @happy.push: $n if is-happy($n);
      ++$n;
   }
   @happy.join(', ').put;
}

sub is-happy (Int:D $n is copy) {
   state $is-happy = SetHash.new(1);
   return True  if $n ∈ $is-happy;

   state $is-not-happy = SetHash.new;
   return False if $n ∈ $is-not-happy;

   my $round = SetHash.new;
   while $n ∉ $round {
      $round.set($n);
      $n = $n.comb»².sum;
      if $n == 1 {
         $is-happy ∪= $round;
         return 1;
      }
   }
   $is-not-happy ∪= $round;
   return 0;
}
```

One objection that might be moved to the caching approach is that it
might *explode*. Well, this should not be the case, because beyond a
certain point we're sure that the next number will be *lower*.

As an example, consider:

$$
9 \rightarrow 9^2 = 81 > 9 \\
99 \rightarrow 2 \cdot 9^2 = 162 > 999 \\
999 \rightarrow 3 \cdot 9^3 = 243 < 999
$$

I'm not going to calculate what this exact threshold is (maybe the
[Wikipedia][] page has something on it), but you can be sure that
*whatever* number beyond 243 will go down for sure, so at the end of the
day we should be pretty safe with our cache.

> Well... then at least everyting between 200 and 243 goes down as well
> because it's maxed by 239, and 199 goes down as well. Then I stop!

Stay safe!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#164]: https://theweeklychallenge.org/blog/perl-weekly-challenge-164/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-164/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Wikipedia]: https://en.wikipedia.org/wiki/Happy_number
