---
title: Another puzzle in Raku
type: post
tags: [ perl, rakulang ]
comment: true
date: 2021-06-29 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I'm still intrigued by [Raku][], though not completely sure about it.

I've slowly started to take a look at the [Advent of Code][], [2018
edition][aoc2018], and I hit a small problem that I thought would be
perfect to translate into [Raku][].

I mean, so far I did not read file inputs, nor use too many data
structures. So why not?

I will not spoiler the fun if you're into it, just share the code and a
couple notes. It's [day 3][] if you're curious.

```raku
#!/usr/bin/env raku
use v6;

sub MAIN ($input = '03.tmp') {
   my $fh = $input.IO.open;
   my %fabric;
   my %double is SetHash;
   my %free is SetHash;
   for $fh.lines -> $line {
      my ($id, $left, $top, $width, $height) = $line.comb(/\d+/);
      %free.set($id);
      for +$left ..^ $left + $width -> $h {
         for +$top ..^ $top + $height -> $v {
            my $key = "$h:$v";
            if (%fabric{$key}:exists) {
               %double.set($key);
               %free.unset(($id, %fabric{$key}));
            }
            else {
               %fabric{$key} = $id;
            }
         }
      }
   }
   say %double.elems;
   put %free.keys;
}
```

The implementation comes out compact, but in hindsight I *first* solved
it in [Perl][], so I had all inputs when I moved on to [Raku][], i.e.
not only the algorithms but also the knowledge on how to merge them.

I was badly hit by the fact that the string extraction in the `... =
$line.comb(...)` line returns all strings. This did not always produce
the expected looping in the two nested `for` later on, and made me force
the interpretation as integers with a `+` (as in `+$left` and `+$top`).
I have to admit that I don't like this particularly: it seems
*unPerlish* and a loss in whipuptitude.

As a [Perl][] hacker, I'm used to play with scalars, arrays and hashes,
covering 99% of my data structure needs. In this case I decided to give
`SetHash` a try; it's maybe an improvement in readability, although not
faster to write. It's still good that I can do everything the old way
with hashes anyway.

I'm still baffled by the sigil invariance, and forget to use
`%fabric{$key}` instead of the *perlish* `$fabric{$key}`. No big deal
though, the error reporting system is amazing.

One last thing I did *not* understand is the need to put *two* sets of
round parentheses in this line:

```raku
%free.unset(($id, %fabric{$key}));
```

Withouth them... it was complaining with some obscure error message:

```
Too many positionals passed; expected 2 arguments but got 3
  in block  at 03.raku line 13
  in sub MAIN at 03.raku line 9
  in block <unit> at 03.raku line 1
```

Go figure...

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Advent of Code]: https://adventofcode.com/
[aoc2018]: https://adventofcode.com/2018/
[day 3]: https://adventofcode.com/2018/day/3
