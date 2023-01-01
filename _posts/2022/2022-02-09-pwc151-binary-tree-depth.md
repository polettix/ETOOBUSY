---
title: PWC151 - Binary Tree Depth
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-02-09 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#151][]. Enjoy!

# The challenge

> You are given binary tree.
>
> Write a script to find the minimum depth.
>
>>  The minimum depth is the number of nodes from the root to the
>>  nearest leaf node (node without any children).
>
> **Example 1:**
>
>     Input: '1 | 2 3 | 4 5'
>
>                     1
>                    / \
>                   2   3
>                  / \
>                 4   5
>
>     Output: 2
>
>
> **Example 2:**
>
>
>     Input: '1 | 2 3 | 4 *  * 5 | * 6'
>
>                     1
>                    / \
>                   2   3
>                  /     \
>                 4       5
>                  \
>                   6
>     Output: 3

# The questions

I'm a paranoid bastard and, as everyone, I project that *a lot*. But I'm
also *bayesian*, and experience has shown time and again that our fine
host is indeed a kind and honest person.

And yet, my mind can't possibly avoid to think for a tiny teensy split
second that *maybe* the choice of the input representation for the
binary tree is a big bait for totally disregarding that this is supposed
to indeed represent a binary tree and be treated as such, instead of
just playing with strings and find a solution that *technically* solves
the problem, but it would be otherwise garbage.

But I'll resist, and eat the bait 😂

And wait! Missing stuff and `*` mean the same, right? And a space can
never be a node's content, right?

# The solution

So well, yeah, find... a binary tree. Given in input in a weird but so
*subtly* useful way - no less than *by layers*. So I read the challenge
as: don't bother with any layer below the first one that provides a
solution to the challenge. We will not end up with the complete binary
tree (as a matter of fact, with *any tree at all*), but we will have fun
on the way.

So where's the "first" (by depth/level) leaf located? Well, just look
for missing stuff in the layer immediately below, of course. The slots
corresponding to its children will either be missing, or filled with an
asterisk `*`.

There's more: the two children will always be located in two consecutive
places, namely an even position and the odd position immediately after.
So we *only* need to find the first level with two such empty positions,
and the answer will be the level immediately before.

We'll start with [Raku][] first, in a sort of strong [Perl][] accent.
I've been doing a lot of [Perl][] lately, and like with natural language
I tend to regress when I don't exercise much with the new one.

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Str $input = '1 | 2 3 | 4 5') {
   if ($input.chars == 0) {
      put 0;
      return 0;
   }
   my @levels = $input.split(/\s*\|\s*/)».comb(/\S+/)».Array;
   for 1 ..^ @levels -> $depth {
      for 0 .. @levels[$depth - 1].end -> $i {
         next if (@levels[$depth - 1][$i] eq '*')
            || ((@levels[$depth][$i * 2] // '*') ne '*')
            || ((@levels[$depth][$i * 2 + 1] // '*') ne '*');
         put $depth;
         return 0;
      }
   }
   put @levels.elems;
   return 0;
}
```

The input is split into parts using the pipe character `|` as separator.
I'm *very* used to [Perl][]'s `split` and [Raku][]'s rendition is...
*different*:

```
$ perl -E 'my @x = split /\|/, ""; say scalar @x'
0

$ raku -e 'my @x = split /\|/, ""; put @x.elems'
1
```

So we have to keep this in mind. This is why there's an explicit check
for an empty input at the beginning, by the way.

The challenge is then solved by comparing consecutive layers of the
tree, directly from the input. In the "previous" one we consider all
items that are *not* empty; for them we check if either child is filled
with something. When this does not apply any more... *bingo*! We have a
solution.

If we run out of layers, then the last layer is the solution (hence the
`put @levels.elems` at the end).

The [Perl][] version is quite similar:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my $input = shift // '1 | 2 3 | 4 5';
my @levels = map { [ split m{\s+}mxs ] } split m{\s*\|\s*}mxs, $input;
for my $depth (1 .. $#levels) {
   for my $i (0 .. $levels[$depth - 1]->$#*) {
      next if $levels[$depth - 1][$i] eq '*'
         || ($levels[$depth][$i * 2] // '*') ne '*'
         || ($levels[$depth][$i * 2 + 1] // '*') ne '*';
      say $depth;
      exit 0;
   }
}
say scalar @levels;
exit 0;
```

I have to admit that I like [Perl][]'s `split` better, although it's
probably just a matter of taste and muscle memory. I also have to admit
that having *less* built-in container types plays in favor of [Perl][]
in these situations: we only have arrays, while the default type
provided by `comb` as output is not good in our case, and we have to
put the thing in an Array explicitly:

```raku
my @levels = $input.split(/\s*\|\s*/)».comb(/\S+/)».Array;
```

Anyway, this is really nitpicking - [Raku][] is a lot of fun to use and
learn!

Stay safe people, see you next time!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#151]: https://theweeklychallenge.org/blog/perl-weekly-challenge-151/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-151/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
