---
title: PWC224 - Special Notes
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-07-06 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#224][]. Enjoy!

# The challenge

> You are given two strings, `$source` and `$target`.
>
> Write a script to find out if using the characters (only once) from
> source, a target string can be created.
>
> **Example 1**

>     Input: $source = "abc"
>            $target = "xyz"
>     Output: false
>
> **Example 2**
>
>     Input: $source = "scriptinglanguage"
>            $target = "perl"
>     Output: true
>
> **Example 3**
>
>     Input: $source = "aabbcc"
>            $target = "abc"
>     Output: true

# The questions

This is a deceptively fun and clever challenge, so my question is: how did
you think of it?

More seriously, often times we've been shown that case might be disregarded,
spaces might be disregarded, etc. so my question would be: can we assume
that a basic `eq` comparison is OK to figure out whether two characters are
the same?

Additionally, and more importantly: do we already know that `$source` and
`$target` contain *strings of characters* and we don't have to do any
decoding?

# The solution

For this challenge, [Raku][] can be the mythic Alexander the Great's sword
while dealing with the [Gordian Knot][] (or Indiana Jones's gun, for a more
modern version of the same idea). Brutally effective:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($s, $t) { put(([(-)] ($t, $s)».comb».Bag).elems == 0) }
```

We build two [Bag][]s out of each string, then subtract (in [Bag][] terms)
the *available* characters from the source from the target. If we're left
with anything, then the source did not contain what we needed; otherwise, it
did.

Going on to [Perl][], we don't have all that many batteries included, so we
are forced to *use the head*. There can be many approaches, like the simple
one:

```perl
sub special_notes_simple ($source, $target) {
   my %available;
   $available{$_}++ for split m{}mxs, $source;
   for my $char (split m{}mxs, $target) {
      return unless $available{$char};
      $available{$char}--;
   }
   return 1;
}
```

We first collect all available characters from the source, then use them to
cover the target's needs.

At this point... why sweep through the whole source, when we might not need
it? So we might think something different instead:

```perl
sub special_notes ($source, $target) {
   my $sl = length($source);
   my $tl = length($target);
   return unless $tl <= $sl;

   my %available;
   my $si = 0; # index in $source
   TARGET:
   for my $ti (0 .. $tl - 1) {
      my $tch = substr($target, $ti, 1);
      if ($available{$tch}) {
         my $residual = --$available{$tch};
         delete $available{$tch} unless $residual;
      }
      else {
         while ($si < $sl) {
            my $sch = substr($source, $si++, 1);
            next TARGET if $sch eq $tch;
            ++$available{$sch};
         }
         return; # no luck...
      }
   }
   return 1;
}
```

Is this any better? Surely there's more code that might fail and that might
need attention, so *not in general*. On the plus side it does not have to
*necessarily* sweep through the whole of the source, so it might give a
little edge time-wise (*and* space-wise, I daresay).

Anyway, for small inputs, I think that nothing beats the brutal perfection
of the [Raku][] solution.

Cheers!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#224]: https://theweeklychallenge.org/blog/perl-weekly-challenge-224/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-224/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[Gordian Knot]: https://en.wikipedia.org/wiki/Gordian_Knot
