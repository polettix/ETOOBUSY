---
title: PWC117 - Missing Row
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-06-16 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#117][]. Enjoy!

# The challenge

> You are given text file with rows numbered 1-15 in random order but there is
> a catch one row in missing in the file.
>
>     11, Line Eleven
>     1, Line one
>     9, Line Nine
>     13, Line Thirteen
>     2, Line two
>     6, Line Six
>     8, Line Eight
>     10, Line Ten
>     7, Line Seven
>     4, Line Four
>     14, Line Fourteen
>     3, Line three
>     15, Line Fifteen
>     5, Line Five
>
> Write a script to find the missing row number.

# The questions

More than questions... assumptions:

- each line starts with one or two digits
- the rest of the line might contain whatever, not necessarily the kind of
  lines in the example


# The solution

I started with [Raku][]:

```raku
#!/usr/bin/env raku
use v6;

sub missing-row ($file) {
   constant All = set(1 .. 15);
   (All (-) set($file.IO.lines.map({+ S/^ (\d+) .*/$0/}))).keys;
}

put missing-row(@*ARGS[0]);
```

The idea is to leverage the [Set][] data type, subtracting the set created from
the line numbers found in the file from the overall set of possible line
numbers, thanks to the `(-)` operator.

The solution in [Perl][] is conceptually similar, although at a lower level:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub missing_row ($file) {
   open my $fh, '<', $file or die "open('$file'): $!\n";
   my %all = map {$_ => 1} 1 .. 15;
   delete $all{s{\A (\d+) .*}{$1}rmxs} while <$fh>;
   return keys %all;
}

say missing_row($ARGV[0]);
```

Here, we leverage the mighty hash data type by initializing `%all` to all line
numbers, then progressively removing the lines found in the file.

I have to admit that I like [Perl][]'s ability to *confuse* integers and
strings, although I understand the advantages in telling them apart. To be
honest, adding a `+` is not that overhead to turn a [Raku][] string into an
integer... so well, I will not complain (too much) about it.

I hope you enjoyed!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#117]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-117/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-117/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https::/raku.org/
[Set]: https://docs.raku.org/type/Set
