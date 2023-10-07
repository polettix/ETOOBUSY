---
title: PWC237 - Maximise Greatness
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-10-08 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#237][].
> Enjoy!

# The challenge


> You are given an array of integers.
>
> Write a script to permute the give array such that you get the maximum
> possible greatness.
> 
>> To determine greatness, nums[i] < perm[i] where 0 <= i < nums.length
>
> **Example 1**
>
>     Input: @nums = (1, 3, 5, 2, 1, 3, 1)
>     Output: 4
>
>     One possible permutation: (2, 5, 1, 3, 3, 1, 1) which returns 4 greatness as below:
>     nums[0] < perm[0]
>     nums[1] < perm[1]
>     nums[3] < perm[3]
>     nums[4] < perm[4]
>
> **Example 2**
>
>     Input: @ints = (1, 2, 3, 4)
>     Output: 3
>
>     One possible permutation: (2, 3, 4, 1) which returns 3 greatness as below:
>     nums[0] < perm[0]
>     nums[1] < perm[1]
>     nums[2] < perm[2]

# The questions

My first question is... *what is the question*? I mean, not *my*
question, but the challenge's question. It seems we're asked for a
permutation, but examples seem to indicate that we need to calculate the
*greatness*.

Additionally, any clue about the size of inputs would probably be a
question worth asking.


# The solution

OK, let's start with some talk.

A permutation will generally have "great" positions (i.e. positions that
contribute to greatness) and other "not-great" positions. In each great
position, the corresponding number from the original input is strictly
lower.

If we rearrange all such correspondent pairs in the respective
permutations, nothing changes regarding the greatness, so it's an
invariant with respect to pre-arranging the input permutation in some
way. For this reason, it will be useful to think the initial input
permutation as sorted in descending order, e.g. the first example would
become:

    5 3 3 2 1 1 1

We are also optimistic folks, so we start big and assume that *every*
position can be a great one!

    greatness = 7
    5 3 3 2 1 1 1

At this point we can observe that the first position can *never* be
great: it holds the maximum value, so by definition there's nothing
inside the permutation that can be greater than it. One point lost to
greatness. Anyway, we put this value in a *pool* of values that we can
later use to fill in *great* positions.

    greatness = 6
    5 3 3 2 1 1 1
    -
    P

Where should we put this value, though? It can actually fill any
position past its own, because it's the maximum and there's only one of
it. We can observe, though, that it makes sense to allocate it to the
value immediately below it, because if we e.g. "waste" it on a 2 or a 1
we might miss an opportunity. As a sub-example, consider all different
values, like:

    4 3 2 1

It only makes sense to allocate the 4 to a 3, because otherwise we will
just "lose" the 3 and get a greatness score of 2 instead of 3.

Back to the original example and algorithm explanation, then, we use the
pool as soon as it makes sense, i.e. the first 3 that we find. We fit
the 5 in second position and remove it from the pool, because we can
(and must) use it exactly once:

    greatness = 6
    5 3 3 2 1 1 1
    - 5
    x

As we pass, we collect this first 3 in the pool for possible great
positions further down the road:

    greatness = 6
    5 3 3 2 1 1 1
    - 5
    x P

Now we move on to the following 3, and we find that there's nothing in
the pool to make this a great position. Hence we keep our pool as it is
and declare this a miss, lowering the greatness value by 1 again. We
also collect this 3 in the pool, by the way.

    greatness = 5
    5 3 3 2 1 1 1
    - 5 -
    x P P

Moving on, we find the 2, which can be made a great position thanks to
the 3 that we have in the pool. Taking also into account that we collect
the 2 in the pool, the step becomes:

    greatness = 5
    5 3 3 2 1 1 1
    - 5 - 3
    x x P P

We can move on with the same algorithm:

    greatness = 5
    5 3 3 2 1 1 1
    - 5 - 3 3
    x x x P P

    greatness = 5
    5 3 3 2 1 1 1
    - 5 - 3 3 2
    x x x x P P

The last position cannot be great, because we only have 1 in the pool,
so we end up with:

    greatness = 4
    5 3 3 2 1 1 1
    - 5 - 3 3 2 -
    x x x x P P P

At this point we have found our greatness value. To find one
permutation, we can just use what's left in the pool inside the
positions that we skipped so far:

    greatness = 4
    5 3 3 2 1 1 1
    1 5 1 3 3 2 1

This approach guarantees us that we will always find both the maximum
greatness and a corresponding permutation that has that value of
greatness.

We can observe that we can establish the greatness at the end of the
first sweep, by subtracting the size of the pool from the size of the
input data. This is what happens in this [Perl][] implementation:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
use JSON::PP;

my ($greatness, $permutation) = great_permutation(@ARGV);
say $greatness, ' -> ', JSON::PP->new->encode($permutation);

sub great_permutation (@inputs) {
   my @sorted_indexes = sort { $inputs[$b] <=> $inputs[$a] } 0 .. $#inputs;

   my @permutation = (undef) x @inputs;

   # first pass - set greatness!
   my @pool;
   my @not_great;
   for my $index (@sorted_indexes) {
      my $value = $inputs[$index];
      if (@pool && $pool[0] > $value) {
         $permutation[$index] = shift @pool;
      }
      else {
         push @not_great, $index;
      }
      push @pool, $value;
   }

   my $greatness = scalar(@inputs) - scalar(@pool);

   # second pass - fill the rest
   @permutation[@not_great] = @pool;

   return ($greatness, \@permutation);
}
```

The code above contains some initial index-calculation to make it
possible to find a permutation for the actual input, not the one sorted
descendingly that we used in our algorithm. Basically, we operate on the
sorted one, but keep the original indexes so that our allocations end up
in the right place.

If we just need the value of greatness (as it seems from the `output` of
the examples), this can be further squeezed by working on whole blocks
of same-valued positions. We still keep the pool, but it's just a count
at this point.

In our initial example, we first turn the input:

    1 3 5 2 1 3 1

into an array of pairs of counts, sorted in descending order for the
value (not the count):

    (5 1) (3 2) (2 1) (1 3)

At this point, we can observe that we just need these values to be
ordered by the original value, but we don't need the value any more
actually because we only care about "greater-than" relations, not actual
values:

    1 2 1 3

This means that we have 1 top value, then 2 (same) values, then 1 value,
then 3 (same) values, all values being sorted descendingly.

The pool starts from 0; at each count, in order, what's in the pool goes
to "cover" that count as much as possible, with two possibilies:

- the pool value is more than, or equal to, the count. This means
  that the greatness is not impacted, because all corresponding slots
  can be made great; in this case we "consume" the exact amount of count
  from the pool, while at the same time also gaining all of them for the
  next slot, so actually nothing changes!

- the pool value is less than the count. This means that we will lose
  the difference in greatness, exhausting the current pool and resetting
  it with the count of the current slot (for the following slots).

All of this... in [Perl][]:

```perl
sub greatness (@inputs) {
   my %count_for;
   $count_for{$_}++ for @inputs;
   my @counts = @count_for{sort { $a <=> $b } keys %count_for};

   my $greatness = @inputs;
   my $pool = 0;
   for my $count (@counts) {
      next if $count <= $pool; # win & accumulate the same quantity
      $greatness -= $count - $pool; # not enough in pool, lose some
      $pool = $count;  # restart pool from this slot
   }
   return $greatness;
}
```

... and, of course, in [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put greatness(@args) }

sub greatness (@inputs) {
   my %count-for;
   %count-for{$_}++ for @inputs;
   my @counts = %count-for{ %count-for.keys.sort({$^a.Int <=> $^b.Int}) };

   my $greatness = @inputs.elems;
   my $pool = 0;
   for @counts -> $count {
      next if $count <= $pool; # win and accumulate the same quantity
      $greatness -= $count - $pool; # not enough in pool, lose some
      $pool = $count;  # restart pool from this slot
   }
   return $greatness;
}
```

Well, I guess I bored every single one of you future me:s at this point,
to the rest please stay safe and have fun!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#237]: https://theweeklychallenge.org/blog/perl-weekly-challenge-237/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-237/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
