---
title: 'AoC 2021/11 - Calm Dumbo Octopuses'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2021-12-17 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 11][puzzle] from [2021][aoc2021]:
> taking it with calm.

Dec. 11th, 2021 was a Saturday and I took it easy. Like sleeping a bit
more, I mean.

Hence, when I got to solve the daily puzzle, I knew I was well behind my
past selves from the days before, and that I could take it with calm.

The challenge is interesting and still puts you in that freezing spot
where you have to decide whether to go all-in with brute force or design
things a bit. The former is *often* the right way to go in a hurry as
it's simpler, but with calm comes time to do things and overengineer
them.

I was not like producing successive frames of the thing because doing
the whole iteration over the whole grid all over the time, just to
increase a counter, seems overkill. Yes, I have a different mental
category about overkill than anybody else.

So I decided to make time tick and calculate the right value of an
octopus at a given time with some modular arithmetic. I mean, if an
isolated cell starts at 5, it will be at 8 in the third step, right? It
will flash at the fifth step and go back to 0, right? So, the value $v$
of that octopus at any future step $s$ will be:

$$
v_s = (v_0 + s) \mod 10
$$

Now, of course this does not save us from iterating over all octopuses
at each step, because we need to know *which* cells fire at that step.
So we're back at octopus 1, right? Ehr, I mean square 1.

One thing that we can do, though, is to divide all octopuses into
buckets depending on their value. All of them with a value of 0 will end
up in bucket 0, and so on. With this initial categorization, we know
exactly which octopuses will flash at step $s$, because we can calculate
the corresponding flashing bucket $f_s$ like this:

$$
f_s = -s \mod 10
$$

Yes, it seems like going *backwards in time*, but this is just to
counterbalance the fact that  we are not actually increasing octopuses'
values as time ticks on.

Now, of course, we have to take into account that octopuses are
connected in a grid, which means that they might change bucket as time
passes, depending on their neighbors flashing. This means that we need:

- to know the neighbors of each octopus, so that we can increase them
  when it flashes, and
- to easily move an octopus from a bucket to another.

The first need can be addressed implicitly, by iterating the $3 \cdot 3$
grid around an octopus each time. Or we can do this at once at the
beginning, and then use a [Set][] to memorize the connections, because
they don't change over time.

The second pushed me to choose a [Hash][] for tracking the contents of
each bucket. This allows efficient insertion and deletion of any
elements inside, depending on our needs, as well as keeping track of
each octopus by its position (represented as a string of the type
`X,Y`).

At each step, the right flashing bucket is selected and the keys of the
associated hash are used as an initial list of flashing octopuses. This
list is not iterated the usual way, though, because *more* octopuses
might flash at that step, depending on the chain reaction effect; for
this reason, the pattern of iteration is like this:

```raku
while @flashing.elems > 0 {
    my $octopus = @flashing.shift;
    ...
```

In this way it's possible to `push` *more* flashing octopuses into
`@flashing` and be sure that all of them will be considered.

The rules say that a flashing octopus does not flash twice in the same
step, so this means that flashing octopuses never leave their bucket.
All the other, though, can move across buckets, up until they flash of
course.

So... enough talking, let's get to the code. While coding I adopted a
slightly different terminology, so you will not read "octopus" or
"flashing" but "cell" (i.e. the octopus's position) and "firing"
instead. I was probably thinking about neural nets.

```raku
#!/usr/bin/env raku
use v6;

sub MAIN ($filename = $?FILE.subst(/\.raku$/, '.tmp')) {
   my $inputs = get-inputs($filename);
   my ($part1, $part2) = solve($inputs);

   my $highlight = "\e[1;97;45m";
   my $reset     = "\e[0m";
   put "part1 $highlight$part1$reset";
   put "part2 $highlight$part2$reset";
}

sub get-inputs ($filename) {
   my @grid = $filename.IO.words».comb(/\d/)».Array;
   my (%info-about, @dumbos-in);
   my ($mx, $my) = @grid[0].end, @grid.end;
   for 0 .. $my -> $y {
      for 0 .. $mx -> $x {
         my $key = "$x,$y";
         my %h = value => @grid[$y][$x];
         %info-about{$key} = @dumbos-in[%h<value>]{$key} = %h;
         %h<neighbors> = set gather {
            for [-1 .. 1] X [-1 .. 1] -> ($dx, $dy) {
               next unless $dx || $dy;
               my ($X, $Y) = ($x + $dx, $y + $dy);
               next unless 0 <= $X <= $mx && 0 <= $Y <= $my;
               take "$X,$Y";
            }
         };
      }
   }
   return [%info-about, @dumbos-in, @grid];
}

sub printable (%ia, $mx, $my) {
   return sub ($step, $msg is copy = Nil) {
      $msg //= "#$step";
      put "- $msg";
      (0 .. $mx).map(-> $x { (%ia{"$x,$_"}<value> + $step) % 10 }).join('').put
         for 0 .. $my;
      put '';
   };
}

sub solve ($inputs) {
   my ($info-about, $dumbos-in, $grid) = @$inputs;
   my $mx = $grid[0].end;
   my $my = $grid.end;
   my $number-of-cells = ($mx + 1) * ($my + 1);
   my &printout = printable($info-about, $mx, $my);
   &printout(0, 'start');
   my $overall-count = 0;
   my $sync-step;
   for 1 .. * -> $step {
      my $fire-value = (0 - $step) % 10;
      my @firing = $dumbos-in[$fire-value].keys;
      my $this-count = 0;
      while (@firing.elems) {
         my $cell = @firing.shift;
         ++$this-count;
         for $info-about{$cell}<neighbors>.keys -> $n-key {
            my $neighbor = $info-about{$n-key};
            my $n-value = $neighbor<value>;
            next if $n-value == $fire-value; # also firing in this step
            $neighbor<value> = my $next-n-value = ($n-value + 1) % 10;
            $dumbos-in[$next-n-value]{$n-key} = $neighbor;
            $dumbos-in[$n-value]{$n-key}:delete;
            @firing.push: $n-key if $next-n-value == $fire-value;
         }
      }
      $sync-step = $step if $this-count == $number-of-cells;
      $overall-count += $this-count if $step <= 100;
      &printout($step) if $step == 100;
      last if $step >= 100 && $sync-step;
   }
   &printout($sync-step);
   return ($overall-count, $sync-step);
}
```

The `get-inputs` function takes care to produce all the data structures
to properly track the whole process. Then `solve`... solves the puzzle,
collecting both outputs along the way.

For step 1 the condition is easy: stop incrementing the `$overall-count`
at the 100th step.

For step 2 the condition is easy as well: get the step number when the
count of all octopuses firing at that step is equal to... all of them,
i.e. `$number-of-cells`.

We can't be sure which of the two occurs first, so the `last` condition
checks for both `$step >= 100` (first part is happy) and `$sync-step`
having a non-false value (second part is happy).

The `printable` function is a factory that returns a sub with which we
can print the grid for a specific state/step number. It closes upon the
data structure (because we evolve it) and takes the step number as
input. Nothing particularly clean, I know.

Well I guess it's enough with this toy! Stay safe folks!

[puzzle]: https://adventofcode.com/2021/day/11
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Set]: https://docs.raku.org/type/Set
[Hash]: https://docs.raku.org/type/Hash
