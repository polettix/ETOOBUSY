---
title: Advent of Code 2018/04 made me feel old
type: post
tags: [ rakulang, advent of code ]
comment: true
date: 2021-09-03 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Advent of Code][] [2018][aoc-2018] [puzzle 4][aoc-2018-04] made me
> feel old.

As I see it, I started toying with [Advent of Code 2018][aoc-2018] about
in mid-May this year, and stopped at [puzzle 4][aoc-2018-04] at the
beginning of June.

It's not particularly difficult, which is probably... the problem. It
gave me the subtle feeling that there had to be a very quick and dirty
solution to it, but I didn't actually know what that looked like.

So I avoided this puzzle for a few months, thinking (hoping?) that an
elegant solution would come out. Until a few days ago, when I thought
that *enough is enough* and it was time to do the hard coding job. Which
made me feel old.

Then I thought: well, let's do this in [Raku][]! And I felt old even
more, because I coded my solution with a **strong** [Perl][] accent, and
my thoughts constantly went to all people that know how to bend [Raku][]
to their will and make wonders with a few lines. Heck, I even [struggled
with parsing the inputs][previous]!

Anyway, here's my solution:

```raku
#!/usr/bin/env raku
use v6;

sub MAIN ($filename = Nil) {
   my $inputs = get-inputs($filename // $?FILE.subst(/\.raku$/, '.tmp'));
   my ($part1, $part2) = solve($inputs);

   my $highlight = "\e[1;97;45m";
   my $reset     = "\e[0m";
   put "part1 $highlight$part1$reset";
   put "part2 $highlight$part2$reset";
}

sub get-inputs ($filename) {
   my @inputs = $filename.IO.basename.IO.lines.sort({$^a leg $^b})
      .map: {
         when /\d+ \: (\d+) \] \s+ falls/ { ('sleep', $0)  }
         when /\d+ \: (\d+) \] \s+ wakes/ { ('wake', $0) }
         when /Guard \s+ '#' (\d+) / { ('start', $0) }
         default { die $_ }
      };
   return @inputs;
} ## end sub get_inputs ($filename = undef)

sub solve ($inputs) {
   return (part1($inputs), part2($inputs));
}

sub part1 ($inputs) {
   my %minutes-for;
   my %slots-for;
   my ($guard, $start);
   my ($max-guard, $max-sleep) = (0, 0);
   for @$inputs -> $input {
      my ($action, $param) = @$input;
      with $action {
         when 'sleep' {
            $start = $param;
         }
         when 'wake' {
            (%slots-for{$guard} //= []).push($start ..^ $param);
            my $mins = %minutes-for{$guard} += $param - $start;
            ($max-guard, $max-sleep) = ($guard, $mins)
               if $mins > $max-sleep;
         }
         when 'start' {
            $guard = $param;
         }
         default { die $action }
      }
   }
   my %count-for;
   my ($max-minute, $max-count) = (0, 0);
   for %slots-for{$max-guard}.List -> $slot {
      for @$slot -> $minute {
         my $count = ++%count-for{$minute};
         ($max-minute, $max-count) = ($minute, $count)
            if $count > $max-count;
      }
   }
   return $max-guard * $max-minute;
}

sub part2 ($inputs) {
   my (%count-for);
   my ($max-guard, $max-count, $max-minute) = (0, 0, 0);
   my ($guard, $start);
   for @$inputs -> $input {
      my ($action, $param) = @$input;
      with $action {
         when 'start' { $guard = $param }
         when 'sleep' { $start = $param }
         when 'wake'  {
            for $start ..^ $param -> $minute {
               my $count = ++%count-for{$guard}{$minute};
               ($max-guard, $max-count, $max-minute) =
                  ($guard, $count, $minute) if $count > $max-count;
            }
         }
         default { die 'wtf?!?' }
      }
   }
   return $max-guard * $max-minute;
}
```

Was this a complete failure? Well... NO! A few take-aways:

- even if old, I still can manage these tasks 😎
- I definitely experienced that *optimum is the enemy of good* - I could
  have coded this a lot of time ago!
- I used `with/when` for the first time, and it felt natural.

So, all in all, a good experience 😄


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Advent of Code]: https://adventofcode.com/
[aoc-2018]: https://adventofcode.com/2018/
[aoc-2018-04]: https://adventofcode.com/2018/day/4
[previous]: {{ '/2021/08/31/pounded-by-pound/' | prepend: site.baseurl }}
