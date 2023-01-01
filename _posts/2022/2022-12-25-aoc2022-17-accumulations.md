---
title: 'AoC 2022/17 - Tetris-ish accumulation'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-12-25 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 17][puzzle] from [2022][aoc2022]:
> Merry Christmas everybody, and a nice puzzle.

Day 17th was a good day puzzle-wise, because I solved it and I enjoyed
doing so.

This time we have falling stuff *resembling* a tetris game. Only it's
not tetris at all: different pieces, no rotations, potentially infinite
height... I mean, there's only the falling part, and the accumulation on
the bottom.

I represented the falling pieces through ASCII-art *sprites*, stored as
arrays of arrays:

```raku
sub sprites { # each is reversed
   return (['****'], < .*. *** .*. >, < ..* ..* *** >, < * * * * >, < ** ** >)
      .map( { $_».comb».Array.Array } ).Array;
}
```

These sprites fall from the ceiling and shifted around according to some
inputs, each represented by a character. It makes sense to read and
store them independently:

```raku
sub get-inputs ($filename) { [ $filename.IO.comb(/\S/) ] }
```

Both the pieces and the inputs are supposed to appear periodically,
according to their respective amounts. It makes sense to create a little
iterator-helper class, working on the array of elements:

```raku
class ArrayIterator {
   has @!items is built;
   has $!i = 0;
   method get {
      my $j = $!i++;
      $!i %= @!items;
      return @!items[$j];
   }
   method at-start { $!i == 0 }
   method idx { return $!i }
   method dump { say @!items.elems }
}
```

Fun fact is that I'm *probably* supposed to do *iterators* differently
(and idiomatically) in [Raku][]. Whatever. This class gets the items
during object creation, and allows `get`ting items, figure out which
item we got last, if we're at the start, and so on.

Both parts of the puzzle can be addressed with a single function,
properly driven. It's OK to discuss it at this point, even though we
still don't know what class `Field` does:

```raku
sub part12 ($inputs, $max) {
   my $field = Field.new;
   my $dit = ArrayIterator.new(items => @$inputs);
   my $sit = ArrayIterator.new(items => sprites());

   my %last-seen-indexes;
   for 0 ..^ $max -> $i {
      my $ip = $sit.idx ~ '/' ~ $dit.idx;
      if %last-seen-indexes{$ip}:exists { # look for period
         my $last = %last-seen-indexes{$ip};
         my $period = (($i, $field.top) «-» $last).Array;
         if $field.check-period($period) {
            my $delta = $max - $i;
            $field.drop($sit, $dit, '#') for ^ ($delta % $period[0]);
            return 1 + $field.top + ($delta / $period[0]).Int * $period[1];
         }
      }
      %last-seen-indexes{$ip} = ($i, $field.top);
      $field.drop($sit, $dit, '#');
   }

   return 1 + $field.top;
}
```

The two iterators `$sit` and `$dit` allow us to generate elements as
needed, and `$field` helps us with the actual business logic.

As observed by many, dropping pieces in these conditions leads to a
periodic arrangement of pieces, i.e. it's possible to detect (from a
certain point on) an arrangement that is then repeated indefintely.

> **From a certain point** underlines the fact that the very first
> pieces fall onto the ground and not on top of the previous iteration
> of the periodic shape. This might make the first pieces arrangements
> different from the periodic section.

For this reason, there are two "modes" of operation: one looking for a
reliable shape that repeats periodically, and another one using it to
calculate all the remaining parts to fill in with big chunks.

The *discovery* phase is just dropping one piece at a time with line:

```raku
$field.drop($sit, $dit, '#');
```

We will see how `Field` does this shortly.

Looking for the period is more interesting. To really be on the safe
side, we must ensure that *looking back* at the dropped pieces, we find
exact replicas that are going to repeat themselves.

The period is driven by the joint positioning of the two iterators on
the same spot, over and over on the same pair. This is why we're using
`$ip` as a marker, formed by both indexes as provided by the iterator
class.

The actual check is performed inside the `$field`; if it is successful,
though, we take the *lazy* approach and move on dropping a few more
pieces, until we are only left with stacking an integer amount of
periodical aggregates.

It's time for class `Field`, at last:

```raku
class Field {
   has @!data;
   has $!top = -1;
   has $!offset = 0;

   method fits ($sprite, $x, $y is copy) {
      @!data.push: [< . . . . . . . >] while @!data <= $y;
      for @$sprite -> $row {
         for 0 .. $row.end -> $dx {
            return False if $row[$dx] eq '*' && @!data[$y][$x + $dx] ne '.';
         }
         --$y;
      }
      return True;
   }

   method overlay ($sprite, $x, $y is copy, $char = '*') {
      $!top = max($!top, $y);
      for @$sprite -> $row {
         @!data[$y][$x + $_] = $row[$_] eq '.' ?? @!data[$y][$x + $_] !! $char
            for 0 .. $row.end;
         --$y;
      }
   }

   method landing-position ($sprite, $dit) {
      my $x = 2;
      my $y = $!top + $sprite.elems + 3;
      loop {
         my $movement = $dit.get;
         my $nx = $movement eq '<' ?? $x - 1 !! $x + 1;
         $x = $nx
            if 0 <= $nx <= 7 - $sprite[0].elems
            && self.fits($sprite, $nx, $y);
         #say "$movement $x $y";

         my $ny = $y - 1;
         $y = $ny if $ny >= 0 && self.fits($sprite, $x, $ny);
         return $x, $y if $y != $ny;
         #say "v $x $y";
      }
   }

   method drop ($sit, $dit, $c = '*') {
      my $sprite = $sit.get;
      my ($x, $y) = self.landing-position($sprite, $dit);
      self.overlay($sprite, $x, $y, $c);
      return self;
   }

   method check-period ($period) {
      my ($n, $height) = $period.Slip;
      return False unless 4 * $height + 10 <= $!top;
      for 0 ..^ $height -> $offset {
         my $closer  = @!data[$!top - 1 * $height - $offset].join('');
         my $farther = @!data[$!top - 2 * $height - $offset].join('');
         return False if $closer ne $farther;
      }
      return True;
   }

   method print {
      for @!data.reverse -> $row {
         put '|', $row.join(''), '|';
      }
      put '+-------+';
   }

   method top { $!top }
}
```

It's a lot of code, and shows something that I'm actually happy about:
attempting to do my future self a favor and make it readable, without
(too much) cleverness.

Dropping a piece with the `drop` method involves a first phase where we
figure out where the piece is going to land (i.e. finding the
`landing-position`), then fixing the piece in place with `overlay`.

As mentioned, checking for the period is the interesting part (as well
as the key to solving part 2). One tricky part to keep in mind is that
there are two periods to deal with in this puzzle: one is the amount of
drawing from both iterators before we arrive to the same exact
arrangement that we already saw in the past, which we already saw in the
driving loop; another period is the length of the stack of pieces that
accumulate through the first period.

To some extent, the first one is a *time-based* period, while this
second one is a *space-based* period, driven by a candidate height.

The magic constants in the method `check-period` are there to ensure
that the effects of the bottom floor (which is identically full) have
been brushed off. In my specific puzzle input this does not really make
a difference, because of how the first pieces settle down; we're aiming
for general solutions though.

The check is straightforward: just compare two consecutive stacks of the
candidate *height* period and check that they're the same. When this
happens... it's a `True`.

[Full solution][].

Well, this has been an interesting ride, so cheers and Merry Christmas!

[puzzle]: https://adventofcode.com/2022/day/X
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[Full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/17.raku
