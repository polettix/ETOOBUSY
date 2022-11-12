---
title: PWC126 - Minesweeper Game
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-08-19 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#126][].
> Enjoy!

# The challenge


> You are given a rectangle with points marked with either `x` or `*`.
> Please consider the `x` as a land mine.
> 
> Write a script to print a rectangle with numbers and `x` as in the
> Minesweeper game.
> 
>> A number in a square of the minesweeper game indicates the number of
>> mines within the neighbouring squares (usually 8), also implies that
>> there are no bombs on that square.
> 
> **Example**
>
>     Input:
>         x * * * x * x x x x
>         * * * * * * * * * x
>         * * * * x * x * x *
>         * * * x x * * * * *
>         x * * * x * * * * x
>     
>     Output:
>         x 1 0 1 x 2 x x x x
>         1 1 0 2 2 4 3 5 5 x
>         0 0 1 3 x 3 x 2 x 2
>         1 1 1 x x 4 1 2 2 2
>         x 1 1 3 x 2 0 0 1 x

# The questions

I think the puzzle is pretty clear, I would probably investigate a bit
about the input and output formats and what to do with weird inputs, but
nothing really insightful I guess.

# The solution

The basic idea of the approach in this solution is that we scan the
input field, looking for mines. As soon as we find one, we add 1 unit to
all surrounding positions in the output rendering, making sure to
preserve previously set mines.

I started with a full solution in [Perl][] also for this challenge,
again for *technical* reasons.

```perl
sub reveal_solution ($field) {
   # this will keep the "revealed" field
	my @retval;

   # we need address cells in the @retval grid, so we have to iterate
   # over indices of the input array instead of on the rows directly
	for my $ri (0 .. $field->$#*) {
      my $row = $field->[$ri];

      # same for columns, we need the index and we get it in $ci
      for my $ci (0 .. $row->$#*) {

         # make sure that the element is initialized.
         $retval[$ri][$ci] //= 0;

         # after this, the only cell that is meaningful for us is the mine,
         # as we will "propagate" its effects on the surrounding cells.
         # This is efficient as long as there are *few* mines.
         next if $row->[$ci] ne 'x';

         # if the input field has a mine, the output has one too
         $retval[$ri][$ci] = 'x';

         # now we iterate over the 3x3 grid centered as ($ri, $ci),
         # making sure to ignore the central position (which cannot
         # influence itself) and that we don't go beyond the limits
         # of the input field. $rd is a "delta" for rows.
         for my $rd (-1, 0, 1) {
            # This is a position in the output field that is influenced
            # by the mine we just found. Well, actually it's a row for
            # multiple positions.
            my $Ri = $ri + $rd;
            next if $Ri < 0 || $Ri > $field->$#*;

            # similarly we do for column indexes
            for my $cd (-1, 0, 1) {
               next unless $rd || $cd; # get rid of (0, 0)
               my $Ci = $ci + $cd;
               next if $Ci < 0 || $Ci > $row->$#*;
               $retval[$Ri][$Ci] //= 0; # initialize if necessary
               next if $retval[$Ri][$Ci] eq 'x'; # don't overwrite mines
               $retval[$Ri][$Ci]++; # increment close-by position
            }
         }
      }
	}
   return \@retval;
}
```

Translating to [Raku][] was... feasible:

```raku

sub reveal-solution (@field) {
   # this will keep the "revealed" field
	my @retval;

   # we need address cells in the @retval grid, so we have to iterate
   # over indices of the input array instead of on the rows directly
	for 0 .. @field.end -> $ri {
      my @row := @field[$ri];

      # same for columns, we need the index and we get it in $ci
      for 0 .. @row.end -> $ci {

         # make sure that the element is initialized.
         @retval[$ri][$ci] //= 0;

         # after this, the only cell that is meaningful for us is the mine,
         # as we will "propagate" its effects on the surrounding cells.
         # This is efficient as long as there are *few* mines.
         next if @row[$ci] ne 'x';

         # if the input field has a mine, the output has one too
         @retval[$ri][$ci] = 'x';

         # now we iterate over the 3x3 grid centered as ($ri, $ci),
         # making sure to ignore the central position (which cannot
         # influence itself) and that we don't go beyond the limits
         # of the input field. $rd is a "delta" for rows.
         for -1, 0, 1 -> $rd {
            # This is a position in the output field that is influenced
            # by the mine we just found. Well, actually it's a row for
            # multiple positions.
            my $Ri = $ri + $rd;
            next if $Ri < 0 || $Ri > @field.end;

            # similarly we do for column indexes
            for -1, 0, 1 -> $cd {
               next unless $rd || $cd; # get rid of (0, 0)
               my $Ci = $ci + $cd;
               next if $Ci < 0 || $Ci > @row.end;
               @retval[$Ri][$Ci] //= 0; # initialize if necessary
               next if @retval[$Ri][$Ci] eq 'x'; # don't overwrite mines
               @retval[$Ri][$Ci]++; # increment close-by position
            }
         }
      }
	}
   return @retval;
}
```

It's so much a translation that I also kept the comments.

The main differences is that we're never using references (which don't
exist in [Raku][]) or with their counterparts as scalars holding
sequential stuff. What was `$field` here is `@field`.

There is an interesting twist in the intermediate variable that goes
through the rows. While in [Perl][] we take the reference:

```perl
...
my $row = $field->[$ri];
...
```

here in [Raku][] we can use an array, provided that we *bind* it to the
actual row. In other terms, *not* this:

```raku
my @row = @field[$ri];  # THIS DOES NOT WORK PROPERLY
```

but **this**:

```raku
my @row := @field[$ri]; # NOTE THE := INSTEAD OF =
```

I guess that something similar can be done with [Perl][] too... but I'm
happy like this!

Time's up again, so thank you for reading and *stay safe, folks!*

[The Weekly Challenge]: https://theweeklychallenge.org/
[#126]: https://theweeklychallenge.org/blog/perl-weekly-challenge-126/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-126/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
