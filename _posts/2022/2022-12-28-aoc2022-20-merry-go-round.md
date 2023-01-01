---
title: 'AoC 2022/20 - Merry go round'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-12-28 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 20][puzzle] from [2022][aoc2022]:
> going round and round and round...

Another day, another solution that was pretty inefficient, so I will not
be discussing it here.

While coding the solution, I *knew* that there was something I was
missing. Then, when I looked at the others' solutions, it was pretty
clear what I had hiding in my mind: a *double-linked list*.

So this is my solution, re-written with the idea of a double-linked list
in mind:

```raku
#!/usr/bin/env raku
use v6;

class CircularLinkedList { ... }
sub MAIN ($filename = $?FILE.subst(/\.raku$/, '.sample')) {
   my $inputs = get-inputs($filename);

   put do-part($inputs, 1);
   put do-part(@$inputs «*» 811589153, 10);
}

sub do-part ($inputs, $reps) {
   my $cll = CircularLinkedList.create(|$inputs);
   my @list = $cll.linear;
   for ^$reps {
      .say;
      $cll.automove($_) for @list;
   }
   return $cll.result;
}

sub get-inputs ($filename) { [ $filename.IO.lines».Int ] }

class CircularLinkedList {
   my class LinkedListItem {
      has $.value is required;
      has $.main  is readonly = False;
      has $.pred is rw = Nil;
      has $.succ is rw = Nil;
   }

   has $.first is rw = Nil;
   has $.count is rw = 0;

   method create (::?CLASS:U $class: *@values) {
      my $l = $class.new;
      @values.map: {$l.push($^value)};
      return $l;
   }

   method push ($l) { # as last element
      if ! $.count {
         $.first = LinkedListItem.new(value => $l, main => True);
         $.first.pred = $.first.succ = $.first;
         $.count = 1;
         return $.first;
      }

      my $item = LinkedListItem.new(value => $l, main => False,
         succ => $.first, pred => $.first.pred);
      $.first.pred.succ = $item;
      $.first.pred = $item;
      ++$.count;
      return $item;
   }

   method linear {
      my $p = $.first;
      return [ (^$.count).map({ my $r = $p; $p = $p.succ; $r }) ]
   }

   method automove ($item) {
      my $amount = $item.value % ($.count - 1) or return self;
      my $p = $item;
      $p = $p.succ for ^$amount;

      # "detach" $item from current position
      $item.pred.succ = $item.succ;
      $item.succ.pred = $item.pred;

      $p.succ.pred = $item;
      $item.succ = $p.succ;
      $item.pred = $p;
      $p.succ = $item;

      return self;
   }

   method result {
      my $zero = $.first;
      $zero = $zero.succ while $zero.value != 0;
      my $offset = 0;
      my $sum = 0;
      for 1000, 2000, 3000 -> $shift {
         my $mods = $shift mod $.count;
         my $p = $zero;
         $p = $p.succ for ^$mods;
         $sum += $p.value;
      }
      return $sum;
   }

   method printout { self.linear».value.say }
}
```

There's not much more to say, apart that... it's perfectly OK to end up
with *any* circular shift of the examples. The final result is
calculated with respect to the position of element `0` (which is
unique), so there's no need to implement things so that the same exact
sequence is obtained (the relative circular arrangement must be
preserved, of course).

[Full solution][].

Stay safe!

[puzzle]: https://adventofcode.com/2022/day/20
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[Full solution]: https://gitlab.com/polettix/advent-of-code/-/blob/main/2022/20.raku
