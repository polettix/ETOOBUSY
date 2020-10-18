---
title: 'PWC082 - Interleave String (now for real, hopefully!)'
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-10-18 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> On we go with [TASK #2][] of [Perl Weekly Challenge][] [#082][].
> Again.

In [PWC082 - Interleave String (but not really!)] I attempted a solution
to the challenge... but it turned out to be a *different* one.. Let's
try again...

# The challenge

Nothing really new here:

> You are given 3 strings; `$A`, `$B` and `$C`. Write a script to check
> if `$C` is created by interleave `$A` and `$B`. Print 1 if check is
> success otherwise 0.

BUT the examples - when read with due care and without pre-conceptions -
are explicity in showing that you can get as many characters out of
either `$A` and `$B` at any given step, not only one. Which was,
unfortunately, my assumption in the previous solution. Oooops 😅

# The questions

At this point, I interpet the *interleave* as any sequence of pieces
taken from either string, up to their complete consumption. Again, I'll
assume that it's at the character level, whatever `substr` deems OK is
fine by me.

# The solution

This time the problem is more general and we can reason like this: the
first character of `$C` can come from either `$A` or `$B`. That's it,
problem solved, see ya!

Oh... was that a tad *cryptic*?!? 🧐

Let's assume the three strings are non-empty, they will have the form of
*a first character, followed by the rest of the string*:

    $A <=> $first_A . $rest_A
    $B <=> $first_B . $rest_B
    $C <=> $first_C . $rest_C

As we said, `$first_C` must be equal to either `$first_A` or `$first_B`
for the interleave to apply. Let's say it's equal to `$first_A`: if we
cancel out both of them, we are left with:

    $A1 <=>            $rest_A
    $B1 <=> $first_B . $rest_B
    $C1 <=>            $rest_C

and `$C1` must be the interleave of `$A1` and `$B1`, or the interleave
will not apply to the initial triple as well. The same reasoning can be
done if `$first_C` is actually coming from `$B` (i.e. `$first_B`) so we
will not repeat it.

This can be easily addressed recursively, because it's sufficient to
re-apply the process to `$A1`, `$B1`, and `$C1` at this point. When
`$first_C` can come from both `$A` and `$B`, it will be sufficient to
try both paths: if one fails, we check the other one.

A recursive function, though, must have a stop condition. In our case,
when any of the strings are empty, there's no more "interleaving" to do
and we check the remainders against each other: if they match it's a
win, otherwise... not.

So we're ready to code the core of the solution:

```perl
sub iir ($A, $B, $C) {
   return 1 if (length($A) == 0 && $B eq $C)  # only B remained
      || (length($B) == 0 && $A eq $C)        # only A remained
      || (length($C) == 0);                   # never reached, paranoia
   my $cc = substr $C, 0, 1, ''; # chop off first char from $C...
   return (($cc eq substr $A, 0, 1) && iir(substr($A, 1), $B, $C))
       || (($cc eq substr $B, 0, 1) && iir(substr($B, 1), $A, $C));
}
```

The initial check is exactly the last one we discussed about the length
of any string having dropped to zero. The last check (on `$C`) is to
account for `$C` having dropped to zero length while there are still
characters in either of the other two inputs, but it's a paranoia
because we wrap the above function in this:

```perl
sub is_interleaving ($A, $B, $C) {
   return (length($A) + length($B) == length($C)) && iir($A, $B, $C);
}
```

This check is a leftover from our previous version, and basically does a
quick check on the lengths before running the more costly recursive
function. For this reason, the check on the length of `$C` inside
function `iir` becomes unnecessary (but still can remain because it will
not get in the way).

Here's the (new) complete script if you want to play with it:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

# well... let's recurse!
sub iir ($A, $B, $C) {
   return 1 if (length($A) == 0 && $B eq $C)  # only B remained
      || (length($B) == 0 && $A eq $C)        # only A remained
      || (length($C) == 0);                   # never reached, paranoia
   my $cc = substr $C, 0, 1, ''; # chop off first char from $C...
   return (($cc eq substr $A, 0, 1) && iir(substr($A, 1), $B, $C))
       || (($cc eq substr $B, 0, 1) && iir(substr($B, 1), $A, $C));
}

sub is_interleaving ($A, $B, $C) {
   return (length($A) + length($B) == length($C)) && iir($A, $B, $C);
}

my $A = shift || 'XY';
my $B = shift || 'Z';
my $C = shift || 'ZXY';
say is_interleaving($A, $B, $C);
```

Before closing, I'd like to thank Myoungjin Jeon again for spotting the
errors in my previous interpretation of this task and until next time...
have a good day!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#082]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-082/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-082/#TASK2
[PWC082 - Interleave String (but not really!)]: {{ '/2020/10/14/pwc082-interleave-string' | prepend: site.baseurl }}
