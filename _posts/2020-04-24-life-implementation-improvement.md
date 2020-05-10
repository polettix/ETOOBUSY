---
title: Conway's Game of Life - Sweeping counting
type: post
tags: [ maths, algorithm, perl, curses ]
comment: true
date: 2020-04-24 06:09:33 +0200
published: true
---

**TL;DR**

> Let's add a little improvement to the [implementation][repo] of
> [Conway's Game of Life][].

In the [Game of Life][], the rules are pretty simple. The next state of
a cell depends in the previous state like this:

- if the cell is alive, then it will survive if and only if it is
  *surrounded* by 2 or 3 alive cells;
- if the cell is empty, it will spawn new life if it has exactly 3 alive
  cells around, otherwise it will stay empty.

So... counting the number of cells around the target one is pretty
important.

In the first implementation, it's only about counting all values around
the target cells:

```perl
 1 sub alive_around ($field, $y, $x) {
 2    my $n = 0;
 3    for my $dy (-1 .. 1) {
 4       for my $dx (-1 .. 1) {
 5          ++$n if $field->[$y + $dy][$x + $dx] eq '#';
 6       }
 7    }
 8    --$n if $field->[$y][$x] eq '#';
 9    return $n;
10 } ## end sub alive_around
```

Each cell's contents will be counted over... and over... and over. About
least 9 times, as a matter of fact. Can we do better?

The new implementation keeps track of the surrounding cells
horizontally, on three lines. This allows calculating the value at a
target cell by simply adding up these values, possibly removing one for
the specific target cell (line 19, where it only makes sense).

```perl
 1 sub life_tick ($field) {
 2    my @retval;
 3    my $nx     = $field->[0]->@*;
 4    my @previous = my @current = (0) x $nx;
 5    for my $y (0 .. $#$field - 1) {
 6       my ($irow, $nrow) = $field->@[$y, $y + 1];
 7       my @next = (0) x $nx;
 8       $next[-1] = $nrow->[-2] eq '#' ? 1 : 0;
 9       my @row  = (' ') x $nx;
10       push @retval, \@row;
11       for my $x (0 .. $nx - 1) {
12          $next[$x] = $next[$x - 1] - ($nrow->[$x - 2] eq '#' ? 1 : 0)
13             + ($nrow->[($x + 1) % $nx] eq '#' ? 1 : 0);
14          my $around = $previous[$x] + $current[$x] + $next[$x];
15          if ($irow->[$x] eq ' ') {
16             $row[$x] = '#' if $around == 3;
17          }
18          elsif ($irow->[$x] eq '#') {
19             $around--; # the item itself must not be counted
20             $row[$x] = '#' if $around == 2 || $around == 3;
21          }
22          else {
23             $row[$x] = $irow->[$x];
24          }
25       } ## end for my $x (0 .. $nx - 1)
26       @previous = @current;
27       @current = @next;
28    } ## end for my $y (1 .. $#$field...)
29    push @retval, $field->[-1];
30    return \@retval;
31 } ## end sub life_tick ($field)
```

The three arrays `@previous`, `@current` and `@next` keep track of these
horizontal values. When a row is complete (i.e. after line 25), these
array are *shifted* to prepare for the next loop.

After doing this, I realize that I don't want to benchmark the
improvements, if any... I'm too scared!!!

[repo]: https://gitlab.com/polettix/conway-life
[Conway's Game of Life]: {{ '/2020/04/23/conway-life' | prepend: site.baseurl | prepend: site.url }}
[Game of Life]: https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
