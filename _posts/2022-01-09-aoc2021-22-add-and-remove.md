---
title: 'AoC 2021/22 - Add and remove'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-01-09 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 22][puzzle] from [2021][aoc2021]:
> playing with sets and re-discovering the [Inclusion-Exclusion
> principle][].

This day's puzzle was hard for me, but I had a lot of fun thinking of
additional, alternative ways to solve it, until a last intuition that
eventually brought me the solution.

And then, of course, I discovered how this should have been done in the
[other player's solutions][]. I particularly liked the [python
solution][python-solution] by [4HbQ][] as announced in [this
post][python-thread]:

```python
from re import findall

def count(cubes):
    if not cubes: return 0

    (state, *head), *tail = cubes
    if state == 'off': return count(tail)

    return volume(*head) + count(tail) - count(
       {intersect(*head, *t) for t in tail}-{None})

def intersect(x,X,y,Y,z,Z, _, u,U,v,V,w,W):
    x = x if x>u else u; X = X if X<U else U
    y = y if y>v else v; Y = Y if Y<V else V
    z = z if z>w else w; Z = Z if Z<W else W
    if x<=X and y<=Y and z<=Z: return '',x,X,y,Y,z,Z

def volume(x,X,y,Y,z,Z):
    return (X-x+1) * (Y-y+1) * (Z-z+1)

def parse(line):
    state, new = line.split()
    return state, *map(int, findall(r'-?\d+', new))

print(count(map(parse, open(0))))
```

I've looked at it in awe because I had about 200 lines of messy code and
yet the solution was so simple!

It relies on the [Inclusion-Exclusion principle][], which is a way of
calculating the items in a set. In particular, there's the [Recursive
Inclusion-Exclusion principle][] formulation which is particularly apt
for implementation.

I particularly like one of the comments to [Recursive
Inclusion-Exclusion principle][]:

> I can see that the formula is correct. It is effectively saying "for
> each new part added, subtract the part that is already counted."
> \[...\] [DanielV][] Jan 24 '21 at 12:15

So... why not? I'll spare my original code which gave me the solution,
to give instead this cleaner, better version in [Raku][]:

```raku
# ... some boilerplate...

sub get-inputs ($filename) {
   $filename.IO.lines.map(
      {
         my $on-off = .substr(1,1) eq 'n';
         my @ranges = .comb(/ \-? \d+ /).map: -> $f, $t { (+$f, +$t) }
         ($on-off, @ranges);
      }
   ).List;
}

sub part1 ($inputs) {
   state $bounding-box = (-50, 50) xx 3;
   my @chunks = $inputs.map: { [$_[0], intersection($_[1], $bounding-box)] };
   measure(@chunks.grep({defined $_[1]}));
}

sub part2 ($inputs) { measure($inputs) }

# returns Nil if no intersection, $para of intersection otherwise
sub intersection ($para1, $para2) {
   my @para;
   for (@$para1 Z @$para2) -> ($ur, $vr) {
      my (\begin, \end) = max($ur[0], $vr[0]), min($ur[1], $vr[1]);
      return Nil unless begin <= end;
      @para.push: (begin, end);
   }
   return @para;
}

sub measure (@inputs) {
   return 0 unless @inputs.elems; # M(empty) = 0
   my ($head, @tail) = @inputs;
   my $tail-measure = measure(@tail);
   return $tail-measure unless $head[0];
   my @isects = @tail.map: { [True, intersection($_[1], $head[1])] };
   my $isects-measure = measure(@isects.grep({defined $_[1]}));
   my $volume = [*] $head[1].map({$_[1] - $_[0] + 1});
   return $volume + $tail-measure - $isects-measure;
}
```

The representation of a "cuboid" is provided by triples of pairs, each
pair representing a range in one dimension. The `intersection()`
function is actually from my first implementation (yay! reuse!), but the
`measure()` function is a rip-off of the other player's solution.

I like how [Raku][] allows us to define the bounding box for the first
part like this:

```raku
state $bounding-box = (-50, 50) xx 3;
```

as well as we're able to use the same `intersection()` function to do
this restriction in part 1.

Enough for today I guess... stay safe people!

[puzzle]: https://adventofcode.com/2021/day/22
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[other player's solutions]: https://www.reddit.com/r/adventofcode/comments/rlxhmg/2021_day_22_solutions/
[4HbQ]: https://www.reddit.com/user/4HbQ/
[python-thread]: https://www.reddit.com/r/adventofcode/comments/rlxhmg/2021_day_22_solutions/hplp672/?context=3
[python-solution]: https://topaz.github.io/paste/#XQAAAQCnAgAAAAAAAAAzHIoib6qqOe07MhJ0XsXE6K08G4Ps1pgTxGMtEZ+kpb0WiMmgclVAwbWGLuEqShaMvaIHbGSZQDr1DzD4YJdTRL4c/0gztLN1zvPRMMuPZI6AjcJ1jQMQwV/eQ4Xx+ZfU1PZoy8ITNoTLg8ND9SSxm0z9oF/VvJvPMcpFJJpTBmm89nO7Kj8zuP1/7GMgKDcDhV3H86rhgHybzKsU1vco+QkpaXh8sDhEfXUe0wM2szbwkYTiIp8UAJyT566Us7JiKvV0S7lxR7dkUDFnAliMQG+BOd+p0kZ8MhuDrFS2Ujxcq1NuqpMlRJVcYAu+2MoMVtqE0OGZQLXqGLMIiVVJuEkZw5OtZ7Pkpo0UcSOcjgq/7o97QucphHs0ZR8Kxnhh/W+3mIz4wqmyXgXqYQy3OqjiI56yy8n688wWq/KFyuzOTLDw+TSopvoOHvFZfB/z4+7ofeGsw0LqJU/tB1d1JQIc9G/WCgt/L18jsahMlvlYcMYrzUD8WeTzOps3J3761hCM
[Inclusion-Exclusion principle]: https://en.wikipedia.org/wiki/Inclusion%E2%80%93exclusion_principle
[Recursive Inclusion-Exclusion principle]: https://math.stackexchange.com/a/3997588/264102
[DanielV]: https://math.stackexchange.com/users/97045/danielv
