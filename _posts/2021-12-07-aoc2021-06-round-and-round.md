---
title: 'AoC 2021/6 - Lanternfishes going round and round'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2021-12-07 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 6][puzzle] from [2021][aoc2021]:
> lanterfishes going round and round.

This one, i think, was designed to lure people into an ever-growing list
of fishes that would eventually exhaust memory in the second part.

Being lazy, anyway, I thought that what is good for a fish at its `0`
day is just as well good for all of them. Which led me to keep track of
how many fishes were in each "possible" day. This led me to something
like this:

```raku
sub solve ($filename) {
   my %n;
   %n{$_}++ for $filename.IO.lines.comb(/\d+/);
   ...
```

Using a hash was my go-to solution, but in hindsight an array would have
been better. Whatever.

This would force me to do an update over all elements as days go, which
I didn't like *at all*. So I remembered of a trick I was told about
some time ago and eventually landed on this:

```raku
sub solve ($filename) {
   my %n;
   %n{$_}++ for $filename.IO.lines.comb(/\d+/);
   my $part1;
   for 1 .. 256 -> $day {
      my $spawning = %n{$day - 1}:delete or next;
      %n{$day + 6} += %n{$day + 8} = $spawning;
      $part1 = %n.values.sum if $day == 80;
   }
   return ($part1, %n.values.sum);
}
```

Basically we add fishes to a growing list of days. The `:delete` keeps
the simulation tidy because it makes sure that no more tha 9 elements
are in the hash at any time, although this is overkill in this case
because we would have about 256 elements or so at the end of phase 2.

> Looking at this solution now, I realize that there was a potential bug
> in collecting the output for part 1. What if there was no fish at day
> 79 and `next` would have kicked in?!? Oh my...

The "trick" is in *not* decreasing the "remaining days" for each class,
but to increase the day number and compare it against the spawn day,
working on the difference.

Then I looked into the [solutions megathread][] and realized that I
could do *much* better with an array.

A popular solution seemed to be of shifting the lower position from the
array (which corresponds to "day 0") and adding a new element at the
end, as well as increasing the count in the right place. This is
brilliant, because it eliminates the need for the trick of the
ever-increasing day.

But then I figured that the same can be obtained just as well with some
modular arithmetics. Why `shift` and `push` when we can just fiddle with
the indices? So this was born:

```raku
sub solve ($filename) {
   my @n = 0 xx 9;
   @n[$_]++ for $filename.IO.lines.comb(/\d+/);
   my $part1;
   for 1 .. 256 -> $day {
      @n[($day + 6) % 9] += @n[($day + 8) % 9];
      $part1 = @n.sum if $day == 80;
   }
   return ($part1, @n.sum);
}
```

The interesting side-effect is that *only the sum is needed*, and the
specific day's share of fishes remains unchanged 🤓

As an afterthought, I wonder how much this would have been the *natural
solution* if only the puzzle was described differently...

Stay safe, folks!


[puzzle]: https://adventofcode.com/2021/day/6
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[solutions megathread]: https://www.reddit.com/r/adventofcode/comments/r9z49j/2021_day_6_solutions/
