---
title: PWC134 - Distinct Terms Count
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-10-14 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#134][].
> Enjoy!

# The challenge

> You are given 2 positive numbers, `$m` and `$n`.
>
> Write a script to generate multiplcation table and display count of
> distinct terms.
>
> **Example 1**
>
>     Input: $m = 3, $n = 3
>     Output:
>     
>           x | 1 2 3
>           --+------
>           1 | 1 2 3
>           2 | 2 4 6
>           3 | 3 6 9
>     
>     Distinct Terms: 1, 2, 3, 4, 6, 9
>     Count: 6
>
> **Example 2**
>
>     Input: $m = 3, $n = 5
>     Output:
>     
>           x | 1  2  3  4  5
>           --+--------------
>           1 | 1  2  3  4  5
>           2 | 2  4  6  8 10
>           3 | 3  6  9 12 15
>     
>     Distinct Terms: 1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15
>     Count: 11

# The questions

Well... this seems one of those delightful *challenge-by-example* that
somehow give ample space to creativity. This is in the spirit of the
whole Weekly Challenge - less focused on getting the exact result right
and more on letting techniques emerge.

This is also why I somehow find it a *failure* in my solutions very
often, because they're the boring, less creative way of solving things.
Anyway.

In this case, I'm a bit intrigued by the space that should be left to
the left of the column indexed by `1`. There's a single space in both
examples, which is consistent with the actual *need* for spacing in the
column. But then this is at odds with what happens for columns `2` and
`3`, because the two examples have the same data but different spacing.
Should we regard this as a special case for column 1 and then adopt the
same column width for the rest, or should it be considered a glitch in
the examples?

We'll see in the implementation, as I'm writing these notes I still have
to begin addressing the problem!

# The solution

UIs are my Achille's heel and this is why this round is particularly
*challenging* for me.

The general width of the multiplication columns can be calculated by
multiplying the two inputs together and getting the length of the
decimal representation of the result:

```
# look! Language-neutral code!
my $width = length($n * $m);
```

The indexes column's width is the length of the first input `$n`:

```
my $idx_width = length($n);
```

The first colum has the same width because it contains the same values.

These widths can be later used to do the formatting of the column's
data.

At this point, we just have to count the distinct values. We can use a
hash/set to keep track of the distinct values, then extract the keys and
be done with that.

OK, enough talking, let's move on with the [Perl][] implementation:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub distinct_terms_count ($m = 3, $n = 5) {
   my $width          = length($n * $m);
   my $idx_width      = length($m);
   my $data_formatter = sub ($first, @rest) {
      join ' ', sprintf("%${idx_width}d", $first),
        map { sprintf "%${width}d", $_ } @rest;
   };
   my @lines;
   push @lines,
     sprintf("%${idx_width}s | ", 'x') . $data_formatter->(1 .. $n);
   push @lines,
     ('-' x $idx_width) . '-+-'
     . ('-' x (length($lines[0]) - 3 - $idx_width));
   my %distinct;
   for my $r (1 .. $m) {
      push @lines, sprintf("%${idx_width}d | ", $r) . $data_formatter->(
         map {
            $distinct{my $p = $r * $_} = 1;
            $p;
         } 1 .. $n
      );
   } ## end for my $r (1 .. $m)
   return {
      table    => join("\n", @lines),
      distinct => [sort { $a <=> $b } keys %distinct],
   };
} ## end sub distinct_terms_count

say '';
my $outcome = distinct_terms_count(@ARGV);
say $outcome->{table} =~ s{^}{      }rgmxs;
say '';
say 'Distinct Terms: ', join ', ', $outcome->{distinct}->@*;
say 'Count: ', scalar($outcome->{distinct}->@*);
```

OK, there's a lot for printing and a little for counting... we're having
fun!

On with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;

subset PosInt of Int where * > 0;
sub distinct-terms-count (PosInt:D $m, PosInt:D $n) {
   my $width          = ($n * $m).chars;
   my $idx_width      = $m.chars;
   my &data_formatter = sub (*@items) {
      my $first = @items.shift;
      join ' ', sprintf("%{$idx_width}d", $first),
        @items.map: { sprintf "%{$width}d", $_ };
   };
   my @lines;
   @lines.push:
     sprintf("%{$idx_width}s | ", 'x') ~ &data_formatter(1 .. $n);
   @lines.push:
     ('-' x $idx_width) ~ '-+-'
     ~ ('-' x (@lines[0].chars- 3 - $idx_width));
   my %distinct;
   for 1 .. $m -> $r {
      @lines.push: sprintf("%{$idx_width}d | ", $r) ~ &data_formatter(
         (1 .. $n).map: {
            %distinct{my $p = $r * $_} = 1;
            $p;
         }
      );
   } ## end for my $r (1 .. $m)
   return join("\n", @lines), %distinct.keys.sort({ $^a <=> $^b });
}

sub MAIN ($m = 3, $n = 5) {
   my ($table, $distinct) = distinct-terms-count($m, $n);
   my @distinct = @$distinct;
   put '';
   put S:g/^^/      / with $table;
   put '';
   put 'Distinct Terms: ', @distinct.join(', ');
   put 'Count: ', @distinct.elems;
}
```

I'm not sure what went wrong here. Passing parameters and returning
values still has a few rought edges for me (e.g. see the `$distinct` and
`@distinct` thing, or how it's difficult for me to get the first element
from the list. I mean... whatever.

I hope you had fun!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#134]: https://theweeklychallenge.org/blog/perl-weekly-challenge-134/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-134/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
