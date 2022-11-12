---
title: 'Raku cglib: A* algorithm'
type: post
tags: [ rakulang, algorithm, pathfinding ]
comment: true
date: 2021-07-31 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A tight implementation of the [A\* algorithm][Astar] in [Raku][].

To continue my joint effort of learning a bit of [Raku][] and porting my
[cglib-perl][] library to it, I've added [Astar.rakumod][] to the lot.

> To be honest, this post and implementation are from a bit ago. I hope
> I didn't miss anything I learned in the meantime!

It's also an executable, with a very minimal example of usage:

```raku
sub MAIN {
   my $map = q:to/END/;
      ########
      #      #
      # #### #
      #    # #
      #      #
      ########
      END
   sub mapper ($map) {
      return sub ($node) {
         state @lines = $map.lines.reverse.map: *.comb;
         my ($x, $y) = $node;
         die 'invalid y' unless 0 <= $y < @lines.elems;
         die 'invalid x' unless 0 <= $x < @lines[$y].elems;
         return () if @lines[$y][$x] eq '#';
         return gather {
            for  $y - 1 .. $y + 1 -> $Y {
               next unless 0 <= $Y < @lines.elems;
               for $x - 1 .. $x + 1 -> $X {
                  next unless 0 <= $X < @lines[$Y].elems;
                  next if $X == $x && $Y == $y;
                  next if @lines[$Y][$X] eq '#';
                  take ($X, $Y);
               }
            }
         }
      }
   }
   sub map-path($map, @path is copy) {
      my @lines = $map.lines.reverse;
      sub put-item ($pos, $char = '.') {
         my ($x, $y) = $pos;
         @lines[$y].substr-rw($x, 1) = $char;
      }
      put-item(@path.shift, 'S');
      put-item(@path.pop, 'G');
      put-item($_, '.') for @path;
      return @lines.reverse.join("\n");
   }
   my $nav = Astar.new(
      distance  => {($^v «-» $^w).map(*.abs).sum},
      heuristic => {($^v «-» $^w).map(*²).sum.sqrt},
      identifier => {$^v.join(',')},
      successors => mapper($map),
   );
   my @path = $nav.best-path((1, 1), (4, 4));
   put map-path($map, @path);
   .say for @path;
}
```

Actually, most of the code above is to turn the map from a string to a
suitable representation for making A\* work.

The output of the example above is the following:

```
########
# ..G  #
#.#### #
#.   # #
#S     #
########
(1 1)
(1 2)
(1 3)
(2 4)
(3 4)
(4 4)
```

Have fun!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Astar]: https://en.wikipedia.org/wiki/A*_search_algorithm
[Astar.rakumod]: https://github.com/polettix/cglib-raku/blob/main/Astar.rakumod
[cglib-perl]: https://github.com/polettix/cglib-perl
