---
title: 'AoC 2021/4 - Giant Squid overkill solution'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2021-12-05 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 5][puzzle] from [2021][aoc2021]: an
> overkill solution.

This challenge basically requires implementing a system to track
*Bingo!* boards and figure out which of them is the winner.

When no immediate, clever solution comes to my mind (which is, let's say
it, most of the times), I usually start implementing features that will
probably be useful. I know, it's bottom-up and tends to require much
more effort, but at least it gets me moving towards the end.

This year I'm also trying to do some more practice in [Raku][], which is
another reason why I tend to err on the *regular, boring stuff*. Which
has also the advantage of usually being also readable and maintenable,
so *regular boring stuff for the win!*.

In this puzzle, I opted for implementing a full-fledged [class][] that
allows managing a board, with all bells and whistles and batteries
included:

- tracking the contents of each cell, of course, indexed by row and
  column;
- do the same tracking by the value they contain inside;
- track the amount of marked cells by row;
- track the amount of marked cells by column;
- track a new value extracted and mark the related cell, if present;
- track the score of the board, which gets calculated as soon as a board
  has a complete row or column of marked cells;
- query the object to see if it's in a winning state;
- printing the board;
- dumping the contents;
- resetting the board to the original state;
- convenience method to *sweep* the whole board, both by rows and by
  columns.

Here's the monster:

```raku
class Board {
   has %!cell-for;
   has @!cell-at;
   has %!count-for;
   has $!score = Nil;

   multi method BUILD (Str:D :$desc) {
      my $ri = 0;
      for $desc.split(/\r?\n/) -> $line {
         %!count-for<rows>[$ri] = 0;
         my $ci = 0;
         for $line.split(/\s+/) -> $cell {
            %!count-for<cols>[$ci] //= 0;
            next unless $cell ~~ /\d/;
            @!cell-at[$ri][$ci] = %!cell-for{$cell} = [$ri, $ci, 0, $cell];
            ++$ci;
         }
         ++$ri;
      }
   }
   method sweep-by-cols (&cb) {
      my $n-rows = @!cell-at.end;
      my $n-cols = @!cell-at[0].end;
      for 0 .. $n-cols -> $ci {
         for 0 .. $n-rows -> $ri {
            &cb(@!cell-at[$ri][$ci]);
         }
      }
   }
   method sweep-by-rows (&cb) {
      my $n-rows = @!cell-at.end;
      my $n-cols = @!cell-at[0].end;
      for 0 .. $n-rows -> $ri {
         for 0 .. $n-cols -> $ci {
            &cb(@!cell-at[$ri][$ci]);
         }
      }
   }
   method dump () {
      @!cell-at.say;
      %!cell-for.say;
      %!count-for.say;
   }
   method print () {
      my $last;
      my @line;
      self.sweep-by-rows: -> $cell {
         if ($last && $last[0] < $cell[0]) {
            @line.join(' ').put;
            @line = ();
         }
         @line.push: '%2d%s'.sprintf($cell[3], $cell[2] ?? '*' !! ' ');
         $last = $cell;
      };
      @line.join(' ').put;
   }
   method mark ($value) {
      return unless %!cell-for{$value}:exists;
      my $cell = %!cell-for{$value};
      $cell[2] = 1;
      %!count-for<rows>[$cell[0]]++;
      %!count-for<cols>[$cell[1]]++;
      if ! defined $!score {
         if (@!cell-at.elems == %!count-for<cols>[$cell[1]])
               || (@!cell-at[0].elems == %!count-for<rows>[$cell[0]]) {
            $!score = 0;
            self.sweep-by-rows: -> $cell {
               $!score += $cell[3] unless $cell[2];
            }
            $!score *= $value;
         }
      }
      return self;
   }
   method reset () {
      for %!count-for.values -> $seq {
         for @$seq -> $item is rw {
            $item = 0;
         }
      }
      for %!cell-for.values -> $cell {
         $cell[2] = 0;
      }
      $!score = Nil;
   }
   method won () { return defined $!score }
   method score () { return $!score }
}
```

There is indeed a custom builder, because we're taking the inputs from a
file so it comes as text that must be parsed.

At the end of the day, only methods `mark`, `won` and `score` were
actually needed (the latter two being more or less the same, as you can
see from the implementation). Well, there's also `reset`, of course, as
well as using `sweep-by-rows` inside `mark` when we calculate the score.

All in all it's been a fun experience and the result seems tidy and to
the point.

And, of course, incredibly overkill.

If you're curious to run the full code, you can find it [here][]. In any
case... stay safe!


[puzzle]: https://adventofcode.com/2016/day/5
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Perl]: https://www.perl.org/
[Raku]: https://www.raku.org/
[class]: https://docs.raku.org/language/classtut
[here]: {{ '/assets/code/aoc2021-04.raku' | prepend: site.baseurl }}
