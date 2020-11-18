---
title: PWC087 - Longest Consecutive Sequence
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-11-18 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#087][]. Enjoy!

# The challenge

> You are given an unsorted array of integers `@N`. Write a script to find
> the longest consecutive sequence. Print 0 if none sequence found.

# The questions

Some questions would be ritual - what about invalid inputs? Is the empty
list allowed as input? Are those integers bounded in some way?

A meta question though is... *why print 0 if none sequence found*? Why not
print... an empty sequence, or a sequence with only one item (which is,
admittedly, hardly a *sequence*, but whatever). This *print 0* is really an
itch!

# The solution

We will be looking at three solutions. Three!

(Well, the *Three!* is an exclamation, not the factorial of three, otherwise
we would have six solutions. Six! 🙄)

Jokes apart, none of them is particularly clever, and all rely on *sorting*
the input array because... well, spotting sequences on a sorted array is *so
easier*, and I do like my comfort zone.

Additionally, all solutions focus on returning a list - the *print 0*
madness will be addressed elsewhere 😄. In particular, we will be using the
following wrapper:

```perl
sub longest_consecutive_sequence ($sub, @N) {
   my @sequence = $sub->(@N);
   local $" = ', ';
   say((@sequence > 1) ? "(@sequence)" : '0');
}
```

It receives a pointer to the specific solution function, and the input
array, taking care to call the sub and... print out what needs to be printed
out.

## Basic solution

The basic solution is pretty... basic:

```
 1 sub lcs_basic (@N) {
 2    return unless @N;
 3    @N = sort {$a <=> $b} @N;
 4    my ($ls, $ll, $cs, $cl) = (0, 0, 0, 1);
 5    for my $i (1 .. $#N, -1) {
 6       if ($i >= 0 && $N[$i] == $N[$i - 1] + 1) { # consecutive
 7          $cl++;
 8       }
 9       else { # end or not consecutive
10          ($ls, $ll) = ($cs, $cl) if $cl > $ll;
11          ($cs, $cl) = ($i, 1);
12       }
13    }
14    return @N[$ls .. ($ls + $ll - 1)];
15 }
```

The empty list case is easily dismissed at the beginning (line 2).

We keep two pairs of integer variables:

- `$ls` and `$ll` are, respectively, the *start index* of the longest
  sequence found so far, and the *length* of the sequence;
- `$cs` and `$cl` are, respectively, the *start index* of the sequence we
  are *currently analyzing*, and its *length*.

These variables start with the values in line 4 because... well, for what we
know at the beginning, the best list starts at the first integer is one item
long, and it is also what we want to investigate more in the beginning.

The loop goes through all the *rest* of the indices (remember? The item in
the first position has already been *considered* by our initializations in
line 4) plus a *fake index* (the `-1`) that is useful to keep all checks
tight inside the loop and avoid dealing with a special condition where the
last sequence in the list is also the longest.

Inside the loop, there are three cases:

- we have a valid index `$i`, and the associated value inside the array is
  indeed the consecutive of the previous one;
- we have a valid index, but the value is not the consecutive of the
  previous one;
- we have a fake index.

The first case is easily addressed: the *current* sequence is... still a
sequence, and we can just record the fact that it is one item longer (line
7) before moving on to the following item.

The last two cases mark a condition where the current sequence has been
interrupted, either by a new sequence, or by the end of the whole input
list. Whatever the case, anyway, we compare the current list with the best
we had so far, and keep the longer one (line 10); then reset the values for
the current list, starting from the current position (`$i`) and resetting
the length to `1` (i.e. the new *current* list includes the element at the
`$i`-th position).

After all elements have been analyzed... we can return the best we found
(line 14).


## A slightly less basic solution

Why not optimize something that probably does not need to be optimized?
Let's have fun!

(Yes, this Covid-19 stuff radically shifted some definitions for me,
including that of *having fun* 😅).

One objection that we might move to the basic solution is that it makes no
sense to look for other sequences if we can be sure that what we have so far
is already the best.

How can we be sure of it?!? Well... if the remaining items are *less* than
the longest sequence we have, there's no way they can contain a longer
sequence, right? For good measure, we will also include the case where they
are *equal*, because in this case we can just keep the one we have, right?

```
 1 sub lcs_less_basic (@N) {
 2    return unless @N;
 3    @N = sort {$a <=> $b} @N;
 4    my ($ls, $ll, $cs, $cl) = (0, 0, 0, 1);
 5    for my $i (1 .. $#N, -1) {
 6       if ($i >= 0 && $N[$i] == $N[$i - 1] + 1) { # consecutive
 7          $cl++;
 8       }
 9       else { # end or not consecutive
10          ($ls, $ll) = ($cs, $cl) if $cl > $ll;
11          last if $ll >= $#N - $i + 1; # compare with max residual length
12          ($cs, $cl) = ($i, 1);
13       }
14    }
15    return @N[$ls .. ($ls + $ll - 1)];
16 }
```

It's the same as before, with the addiiton of line 11 where we do the test
and stop looking for a solution if the conditions apply. This test is done
in the *check and reset* branch of the test in line 6, because it's where we
can be sure of the best length so far and have an estimate of the longest
possible sequence after this.


## A conceptually simpler solution

I have to admit that the two solutions above were *not* the ones I coded
first. I actually started with a *conceptually* simpler solution, i.e. one
where I addressed the problem like this:

- sort the input list (as before)
- build sub-lists of consecutive items
- find the longest sub-list

This allows me to think at a higher level of abstraction - instead of
fiddling with indexes and lengths and stuff. It also proved very useful to
spot bugs in the other solutions 😎

I said *conceptually*... but the actual implementation might be somehow not
totally basic, because it's based on *iterators*:

```
 1 sub lcs_with_iterators (@N) {
 2    my $iterator = lcs_iterator(@N);
 3    my $longest = [];
 4    while (my $sequence = $iterator->()) {
 5       $longest = $sequence if $sequence->@* > $longest->@*;
 6    }
 7    return $longest->@*;
 8 }
 9 
10 sub lcs_iterator (@N) {
11    @N = sort {$a <=> $b} @N;
12    return sub {
13       return unless @N;
14       my @sequence = shift @N;
15       push @sequence, shift @N while @N && $N[0] == $sequence[-1] + 1;
16       return \@sequence;
17    };
18 }
```

The first function `lcs_with_iterators` is the *outer* one; it grabs an
*iterator* (from the other function, line 2), i.e. a reference to a sub that
can be repeatedly called (line 4) to get the *next* sequence to compare.

We start with an empty *longest* sequence (line 3) - at the beginning it's
the best we have, isn't it?

At each iteration, we compare the length and keep the longest (line 5). At
the end, we return it. Isn't it very, very readable?!?

The iterator factory function `lcs_iterator` is where the rest happens. The
array is sorted as before (line 11), then a reference to an anonymous sub is
returned, where this sorted array will be sliced into consecutive sub-lists,
returned as reference to arrays (lines 14 through 16) or as... nothing, if
there is nothing left in `@N`.

Each sub-sequence is initialized with the first (remaining) item in `@N`
(line 14), then items are added if they comply with the rules (line 15).


## A comparison

The three solutions have their merits:

- the iterator-based is the most high-level and readable of the three. It's
  totally not optimized - it does a lot of copies around, etc. - but it has
  the merit of being somehow *too simple to do wrong*. As such, it's an
  excellent sanity checker for more optimized solutions - let's consider
  that a *trusted baseline*;
- the basic solution is a first attempt at avoiding unnecessary copies, by
  keeping indexes instead of making copies around;
- the *less basic* solution tries to chip off some additional time... when
  that make sense. Does it make sense?


# So long...

As always, here's the full code:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

my @N = @ARGV ? @ARGV : (100, 4, 50, 3, 2);
local $" = ', ';
my @lcs;

longest_consecutive_sequence(\&lcs_basic, @N);
longest_consecutive_sequence(\&lcs_less_basic, @N);
longest_consecutive_sequence(\&lcs_with_iterators, @N);

sub longest_consecutive_sequence ($sub, @N) {
   my @sequence = $sub->(@N);
   local $" = ', ';
   say((@sequence > 1) ? "(@sequence)" : '0');
}

sub lcs_basic (@N) {
   return unless @N;
   @N = sort {$a <=> $b} @N;
   my ($ls, $ll, $cs, $cl) = (0, 0, 0, 1);
   for my $i (1 .. $#N, -1) {
      if ($i >= 0 && $N[$i] == $N[$i - 1] + 1) { # consecutive
         $cl++;
      }
      else { # end or not consecutive
         ($ls, $ll) = ($cs, $cl) if $cl > $ll;
         ($cs, $cl) = ($i, 1);
      }
   }
   return @N[$ls .. ($ls + $ll - 1)];
}

sub lcs_less_basic (@N) {
   return unless @N;
   @N = sort {$a <=> $b} @N;
   my ($ls, $ll, $cs, $cl) = (0, 0, 0, 1);
   for my $i (1 .. $#N, -1) {
      if ($i >= 0 && $N[$i] == $N[$i - 1] + 1) { # consecutive
         $cl++;
      }
      else { # end or not consecutive
         ($ls, $ll) = ($cs, $cl) if $cl > $ll;
         last if $ll >= $#N - $i + 1; # compare with max residual length
         ($cs, $cl) = ($i, 1);
      }
   }
   return @N[$ls .. ($ls + $ll - 1)];
}

sub lcs_with_iterators (@N) {
   my $iterator = lcs_iterator(@N);
   my $longest = [];
   while (my $sequence = $iterator->()) {
      $longest = $sequence if $sequence->@* > $longest->@*;
   }
   return $longest->@*;
}

sub lcs_iterator (@N) {
   @N = sort {$a <=> $b} @N;
   return sub {
      return unless @N;
      my @sequence = shift @N;
      push @sequence, shift @N while @N && $N[0] == $sequence[-1] + 1;
      return \@sequence;
   };
}
```

Have a good one!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#087]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-087/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-087/#TASK1
[Perl]: https://www.perl.org/
