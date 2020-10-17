---
title: 'PWC082 - Interleave String (but not really!)'
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-10-14 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> On we go with [TASK #2][] of [Perl Weekly Challenge][] [#082][].

Do you really care for the solution to this task? Myoungjin Jeon in the
comments made me realize that I'm solving a *different* problem here, so
I'll leave it but... I'll solve it somewhere else. Sorry 🤭

# The challenge

> You are given 3 strings; `$A`, `$B` and `$C`. Write a script to check
> if `$C` is created by interleave `$A` and `$B`. Print 1 if check is
> success otherwise 0.

# The questions

I guess this challenge has, so far, the vaguest definition that I found
so far. What's an *interleave* exactly? I guess something like *take
some from here, then some from there, then back to here, ...* qualifies,
but how exactly?

So the questions in this case would be mainly aimed at understanding
what the interleave is exactly; from the examples, it seems:

- 1 character from each character, interleave is not valid if there are
  two characters from the same string
- both `$A` and `$B` might be the first

Then, another question comes to mind: is the interleave to be meant at
the *character* level or at the *byte* level? Whatever, we will just
stick with what `substr` thinks that's best, and leave that to the
external program and how it feeds us with `$A`, `$B`, and `$C`.

# The solution

We can first do some preliminary checks to see if there's a *chance*
that the three strings are actually compliant to the test. All of them
can be carried out with just the strings' lenghts:

```perl
my ($lA, $lB, $lC) = map { length $_ } ($A, $B, $C);
($lA, $lB, $A, $B) = ($lB, $lA, $B, $A) if $lA > $lB;
```

We swap `$A` and `$B` to make the former shorter or at most as long as
the latter, which will simplify our life in the lines after.

It's now easy to rule out impossible situation, i.e.:

- lengths don't add up in the correct way;
- either `$A` or `$B` are too longer than the other one.

This brings us to this:

```perl
return 0 if ($lA + $lB != $lC) || ($lB > $lA + 1);
```

The astute reader knows at this point that we are in a `sub`... we'll
get to this shortly.

Now we're left to checking whether the two strings are actually
interleaving into the third string, we're doing this two characters at a
time. We first establish whether `$A` or `$B` can go first, by a test on
the lengths; thanks to the rearrangement we did in the beginning, we
know that `$B` can *always* go first at this point:

```perl
my ($fA, $fB) = ($lA == $lB, 1); # can go first?
```

If we ever drop to both of these flag variables being false... the two
strings are not interleaved. Here's the loop:

```perl
for my $i (0 .. $lB - 1) {
   my ($cA, $cB) = map { substr $_, $i, 1 } ($A, $B);
   my $sC = substr $C, 2 * $i, 2;
   $fA &&= ($sC eq ($cA . $cB));
   $fB &&= ($sC eq ($cB . $cA));
   return 0 unless $fA || $fB;
}
```

Simply put, we take two characters from `$C` and one character from both
`$A` and `$B`, combining them depending on whether the strings can go
first or not.

If we manage to exit from the loop... then the two strings are
interleaved:

```perl
return 1;
```

Here's the complete script if you want to play with it:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub is_interleaving ($A, $B, $C) {
   my ($lA, $lB, $lC) = map { length $_ } ($A, $B, $C);
   ($lA, $lB, $A, $B) = ($lB, $lA, $B, $A) if $lA > $lB;
   return 0 if ($lA + $lB != $lC) || ($lB > $lA + 1);
   my ($fA, $fB) = ($lA == $lB, 1); # can go first?
   for my $i (0 .. $lB - 1) {
      my ($cA, $cB) = map { substr $_, $i, 1 } ($A, $B);
      my $sC = substr $C, 2 * $i, 2;
      $fA &&= ($sC eq ($cA . $cB));
      $fB &&= ($sC eq ($cB . $cA));
      return 0 unless $fA || $fB;
   }
   return 1;
}

my $A = shift || 'XXY';
my $B = shift || 'XXZ';
my $C = shift || 'XXXXZY';
say is_interleaving($A, $B, $C);
```

Have a good one!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#082]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-082/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-082/#TASK2
