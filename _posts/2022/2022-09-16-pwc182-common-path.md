---
title: PWC182 - Common Path
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-09-16 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#182][].
> Enjoy!

# The challenge

> Given a list of absolute Linux file paths, determine the deepest path
> to the directory that contains all of them.
>
> **Example**
>
>     Input:
>         /a/b/c/1/x.pl
>         /a/b/c/d/e/2/x.pl
>         /a/b/c/d/3/x.pl
>         /a/b/c/4/x.pl
>         /a/b/c/d/5/x.pl
>
>     Ouput:
>         /a/b/c

# The questions

Can we assume that the paths have been put in a canonical form, i.e.
that we don't have to figure out what to do with `.` and `..` sections?

Are we positive we only get files as inputs?

Are we positive that every input file is absolute?

We will assume that paths can be viewed as sequences of *down-pointing*
elements, separated by slashes. I hope this is a fair assumption!

# The solution

Let's start with [Perl][] first:

{% raw %}
```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use List::Util 'reduce';

say common_path(
   qw<
    /a/b/c/1/x.pl
    /a/b/c/d/e/2/x.pl
    /a/b/c/d/3/x.pl
    /a/b/c/4/x.pl
    /a/b/c/d/5/x.pl
   >
);

sub common_path (@paths) {
   my $retval = reduce {{
      my @common;
      for my $i (0 .. $a->$#*) {
         last if $i > $b->$#*;
         last if $a->[$i] ne $b->[$i];
         push @common, $a->[$i];
      }
      \@common;
   }} map { my @parts = split m{/}mxs; pop @parts; \@parts } @paths;
   return join '/', $retval->@*;
}
```
{% endraw %}

Going "backwards" in reading the implementation inside `common_path`:

- each path is split into sections, i.e. directory names and the last
  part that is a file name and is always removed (via `pop @parts`)
- then we use reduce to compare one item with the next incoming path,
  keeping the shortest common path;
- at the end of each `reduce` iteration, we return this common part.
  Eventually, we will trim down to the part to common to all input
  paths.

It's interesting that we have double open/close braces for the `reduce`
block. This is *apparently* needed to cope with the fact that variable
`my @common`, despite being a lexical one, does not behave like this and
needs some extra "scope kick* to fully work as expected.

The [Raku][] counterpart is more or less a translation, with due care
for handling sub-arrays and sub-sequences in the proper way:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   put common-path(<
    /a/b/c/1/x.pl
    /a/b/c/d/e/2/x.pl
    /a/b/c/d/3/x.pl
    /a/b/c/4/x.pl
    /a/b/c/d/5/x.pl
   >);
}

sub common-path (@paths) {
   @paths».split(/\//)».Array.map({.pop;$_}).reduce({
      my @common;
      for @$^a Z @$^b -> ($a, $b) {
         last if $a ne $b;
         @common.push: $a;
      }
      @common;
   }).join('/');
}
```

The `Z`ip operator helps us going through two (split) paths at the same
time, so why not? At this point we just have to move on one character at
a time, bailing out as soon as we discovered a mismatch.

Stay safe *and secure*!!!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#182]: https://theweeklychallenge.org/blog/perl-weekly-challenge-182/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-182/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
