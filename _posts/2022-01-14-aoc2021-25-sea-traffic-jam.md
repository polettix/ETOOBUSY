---
title: 'AoC 2021/25 - Sea traffic jam'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-01-14 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 25][puzzle] from [2021][aoc2021]:
> some nice ASCII Art fiddling

Eventually we got to December 25th in 2021, and we found a present under
the tree. Some good ol' puzzle that took "the right people" less than 10
minutes to read, understand, and code.

Admittedly, though, this time there is only one half of the puzzle to be
solved: if we arrive here with the 48 stars from the previous 24 days,
solving this last one will give us the keys to heaven. Well, maybe not
heaven... but surely the keys to Santa's sleigh. So, in hindsight, also
"the right people" seems to have arrived a bit *exhausted* at the end of
this year's [Advent of Code][], which is somehow reassuring for my ego.

"A common bad is a half joy" as the say goes here in Italy. Not sure it
stood the test of time though, but I'm digressing.

In the puzzle we're requested to understand the traffic of some little
creatures on the bottom of the sea, arranged in a classical ASCII grid.
I decided to go full matrix to handle it, so here's how I read it:

```raku
sub get-inputs ($filename) {
   $filename.IO.lines.map({.comb(/\S/).Array}).Array
}
```

Using [Raku][] shifted me from using `split` (which focuses on
separators) to `comb` (which focuses on the stuff I'm interested into).
I'm still not convinced this is a real gain, though: in many real-world
situations it's often easier to tell how the separator is shaped, as
opposed to more mutable "interesting" inputs, and the change in
`split`'s semantics (compared to [Perl][]) make it less... *do what I
mean*. Anyway, in this case `comb` is perfect.

I use to toss a `.Array` at the end of the stuff I read because I've
been biten too often by a complain the I already exhausted the iterator
for a sequence. This is another place where I'd like to have different
defaults that *do what I mean*, at least for what gradual typing is
concerned.

The solution requires detecting when the situation comes to a freeze, so
we have to compare two *snapshots" to spot differences. How about a
printable version of the matrix?


```raku
sub printable ($field) { $field».join('').join("\n") }
```

As I probably already said, I love the hyperoperator to apply a single
operation onto each element of a listy thing (like `».join('')` here).

The main logic is the following: we keep a `$pre` snapshot from the
previous step (initialized with the starting state), do one full step,
take another snapshot and exit the loop if they are the same.

```raku
sub part1 ($inputs) {
   my $steps = 0;
   my $pre = printable($inputs);
   loop {
      step($inputs);
      my $post = printable($inputs);
      last if $pre eq $post;
      $pre = $post;
      ++$steps;
   }
   return $steps + 1;
}
```

I definitely remember thinking that the freezing step happens *one step
before* what we are requested in the puzzle. If I come to a halt at step
57, I'll figure this out in step 58. Somehow I felt that the required
output did not make justice to the whole situation, and this is quite
evident from the coding: `++$steps` appears *after* the exit condition
for the loop, and the return value is `$steps + 1`.

I could have simplified the whole thing like this instead:

```raku
sub part1 ($inputs) {
   my $steps = 0;
   my $pre = printable($inputs);
   loop {
      step($inputs);
      ++$steps;
      my $post = printable($inputs);
      return $steps if $pre eq $post;
      $pre = $post;
   }
}
```

but I chose not to. This is my coding protest towards what I considered
an injust formulation of the expectations. *Those poor sea cucumbers
grind to a halt one step before!* **How is it possible that I'm the only
one seeing it?!?**

Well well... maybe I was a bit taken by this. Where was I?

I decided to give an indication that there was nothing more to this
puzzle, with a little citation from The Matrix. At the end of the day,
we're dealing with a matrix of characters, right?

```raku
sub part2 ($inputs) { return 'there is no part2...' }
```

Moving on the implementation, a *step* is composed of two *ticks*, one
where the east-facing creatures move, followed by one where the
south-facing creatures move. To keep things compact, we have one single
`tick` function, taking the `$field` as input, as well as the indication
of the direction to take care of. Then our `step` is just applying this
`tick` twice, in the right order:

```raku
sub step ($field) { tick(tick($field, east => True), east => False) }
```

And finally we're at the real meat of the solution for this last puzzle:

```raku
sub tick ($field, Bool:D :$east) {
   my @limits = $field.elems, $field[0].elems;
   @limits = @limits.reverse unless $east;
   my $moving = $east ?? '>' !! 'v';
   my $empty  = '.';
   for ^@limits[0] -> $o {    # "o"uter
      my $just-moved = False;
      my $first-moved = False;
      for ^@limits[1] -> $i { # "i"nner
         my $I = ($i + 1) % @limits[1];
         last if $I < $i && $first-moved;
         if $just-moved { # skip if already moved
            $just-moved = False;
            next;
         }
         $just-moved = False;
         my ($R, $C) = $east ?? ($o, $I) !! ($I, $o);
         next unless $field[$R][$C] eq $empty;
         my ($r, $c) = $east ?? ($o, $i) !! ($i, $o);
         next unless $field[$r][$c] eq $moving;
         $field[$R][$C] = $moving;
         $field[$r][$c] = $empty;
         $just-moved = True;
         $first-moved = True if $i == 0;
      }
   }
   return $field;
}
```

Solving this puzzle is trickier than I expected because these sea
cucumbers seem to give flat-earthers an edge and the wrap on the edges,
Pac-Man style. Hence we have to be very careful to avoid moving items
too many times in a single tick. There is probably a better, simpler way
to express this... but I was so mentally tired at this point that
hammering one sort-of-working solution here and there until it worked
was good enough for me.

Now it seems that I've come to the last puzzle... but not at the end of
it! I know too well that I didn't comment the first three puzzles, which
I'll hopefully do in the coming days. We have an off-by-three situation
here, as well as some wrap-around... weird stuff.

Until then, please folks stay safe. It's customary at this point for me
to say so, but I see a lot of numbers rising, and it seems that we've
become immunized to the numbers more than we became immunized to the
virus.

[puzzle]: https://adventofcode.com/2021/day/25
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
