---
title: PWC201 - Penny Piles
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-01-27 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#201][].
> Enjoy!

# The challenge

> You are given an integer, `$n > 0`.
>
> Write a script to determine the number of ways of putting `$n pennies`
> in a row of piles of ascending heights from left to right.
>
> **Example**
>
>     Input: $n = 5
>     Output: 7
>
>     Since $n=5, there are 7 ways of stacking 5 pennies in ascending piles:
>     
>         1 1 1 1 1
>         1 1 1 2
>         1 2 2
>         1 1 3
>         2 3
>         1 4
>         5

# The questions

I know this became the nitpicker's corner in time, but I'd argue that
*ascending* piles should mean that slots on the right are greater than
those on the left.

# The solution

OK, buckle up.

First of all, I'm quite sure that we already did this challenge. I mean,
*quite* sure.

> By the way, today I discovered that I re-implemented a program I did
> some time ago, and I only remembered about it after looking at the
> results that it produced 🙄

Anyway, let's do it *again*. The obvious (for me!) way of addressing
this is through a recursive function:

```perl
sub penny_piles_recursive ($n) {
   my @valid;
   my @trail;
   sub ($n) {
      push @valid, [@trail] if $n == 0;
      my $min = @trail ? $trail[-1] : 1;
      push @trail, $min;
      while ($trail[-1] <= $n) {
         __SUB__->($n - $trail[-1]);
         ++$trail[-1];
      }
      pop @trail;
   }->($n);
   return \@valid;
}
```

Wow, I even remembered to use `__SUB__` for the recursive call!

Now, a little interlude. What would it take to transform this function
into a solution to the *strictly* ascending version of the puzzle?

Initially, I thought that it would have been the test:

```perl
while ($trail[-1] < $n) { ...
```

*but*... no, It's not. It does not work.

I turns out that it's in the definition of `$min`, adding `+1`:

```perl
my $min = @trail ? $trail[-1] + 1 : 1;
```

OK, enough for this. Turning this function into an iterative version is
a little perversion of mine, so here we go. It's a little tricky,
because we have to cater for both *starting* a new frame as well as
*returning* to a frame:

```perl
sub penny_piles_iterative ($n) {
   my @valid;
   my @trail;
   my @stack = ($n);
   while (@stack) {
      push @valid, [@trail] if $stack[-1] == 0;
      if (@trail < @stack) { # initialize
         my $min = @trail ? $trail[-1] : 1;
         push @trail, $min;
      }
      else { # continue this frame's iteration
         $trail[-1]++;
      }
      if ($trail[-1] <= $stack[-1]) { # "recurse"
         push @stack, $stack[-1] - $trail[-1];
      }
      else { # "return"
         pop @trail;
         pop @stack;
      }
   }
   return \@valid;
}
```

At this point, it's pretty straighforward to turn it into an *iterator*:

```perl
sub penny_piles_iterator ($n) {
   my @trail;
   my @stack = ($n);
   return sub {
      my $retval = undef;
      while (@stack && ! $retval) {
         $retval = [@trail] if $stack[-1] == 0;
         if (@trail < @stack) { # initialize
            my $min = @trail ? $trail[-1] : 1;
            push @trail, $min;
         }
         else { # continue this frame's iteration
            $trail[-1]++;
         }
         if ($trail[-1] <= $stack[-1]) { # "recurse"
            push @stack, $stack[-1] - $trail[-1];
         }
         else { # "return"
            pop @trail;
            pop @stack;
         }
      }
      return $retval;
   };
}
```

Last, we move on to [Raku][], we we take a little twist by implementing
the iterator-based solution, but with objects insteaad:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int $n where * > 0 = 5) {
   class PennyPilesIterator { ... }
   my $it = PennyPilesIterator.new($n);
   while defined(my $seq = $it.next) {
      $seq.say
   }
   put $it.count;
}

class PennyPilesIterator {
   has @!trail is built;
   has @!stack is built;
   has $.count = 0;

   method new ($n) { self.bless(trail => [], stack => [$n]) }

   method next () {
      my $retval = Nil;
      while (@!stack && ! $retval) {
         if @!stack[*-1] == 0 {
            $retval = [ |@!trail ];
            ++$!count;
         }
         if (@!trail < @!stack) { # initialize
            my $min = @!trail ?? @!trail[*-1] !! 1;
            @!trail.push: $min;
         }
         else { # continue this frame's iteration
            @!trail[*-1]++;
         }
         if (@!trail[*-1] <= @!stack[*-1]) { # "recurse"
            @!stack.push: @!stack[*-1] - @!trail[*-1];
         }
         else { # "return"
            @!trail.pop;
            @!stack.pop;
         }
      }
      return $retval;
   }
}
```

Enough, stay safe folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#201]: https://theweeklychallenge.org/blog/perl-weekly-challenge-201/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-201/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
