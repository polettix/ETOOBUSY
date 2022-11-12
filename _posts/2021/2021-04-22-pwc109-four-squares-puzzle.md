---
title: PWC109 - Four Squares Puzzle
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-04-22 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#109][].
> Enjoy!

# The challenge

> You are given four squares as below with numbers named a,b,c,d,e,f,g.
> 
>              (1)                    (3)
>        ╔══════════════╗      ╔══════════════╗
>        ║              ║      ║              ║
>        ║      a       ║      ║      e       ║
>        ║              ║ (2)  ║              ║  (4)
>        ║          ┌───╫──────╫───┐      ┌───╫─────────┐
>        ║          │   ║      ║   │      │   ║         │
>        ║          │ b ║      ║ d │      │ f ║         │
>        ║          │   ║      ║   │      │   ║         │
>        ║          │   ║      ║   │      │   ║         │
>        ╚══════════╪═══╝      ╚═══╪══════╪═══╝         │
>                   │       c      │      │      g      │
>                   │              │      │             │
>                   │              │      │             │
>                   └──────────────┘      └─────────────┘
> 
> Write a script to place the given unique numbers in the square box so
> that sum of numbers in each box is the same.

# The questions

Well... a few:

- What to do if there is no solution?
    - let's assume that a nice message is enough
- What to do if there are multiple solutions?
    - any will do, additional points if it's not always the same
- Can numbers be negative?
    - sure, why not?
- Can numbers be floating point? Can we assume that we will not be
  hit by weird approximation errors that make `0.3 == 0.2 + 0.1` *false*
  in most languages ([Perl][] included)?
    - interesting, but for this puzzle let's stick to integers
- Can I assume that sums are within the limits of my platform?
    - yes, if your platform is capable of holding integers between
      `-128` and `127`.

# The solution

This time we go *brute force*, leveraging previous post [Iterator-based
implementation of Permutations][].

In particular, we will take any possible permutations of the input list,
and check whether it leads to a solution or not. Hence, the core of the
solution is this:

```perl
sub four_squares_puzzle (@values) {
   my $it = permutations_iterator(items => [@values]);
   while (my @S = $it->()) {
      my $sum = $S[0] + $S[1];
      next if $sum != $S[1] + $S[2] + $S[3];
      next if $sum != $S[3] + $S[4] + $S[5];
      next if $sum != $S[5] + $S[6];
      my @keys = 'a' .. 'g';
      my %retval;
      @retval{@keys} = @S;
      return %retval;
   }
   return;
}
```

I know... it's extremely lazy, but also extremely easy to code!

Using an iterator here is handy because it allows us to avoid computing
*all* permutations, and get out as soon as we find a suitable one.

I initially thought that there might be some magic way to figure out
what the sum within each square would be by simply inspecting the
numbers linearly, e.g. by summing them.

It turns out I was wrong.

It's possible to find solutions to the example input where the sum in
each square can be 9:

```
a = 4
b = 5
c = 3
d = 1
e = 6
f = 2
g = 7
```

or 10:

```
a = 7
b = 3
c = 2
d = 5
e = 1
f = 4
g = 6
```

as well as 11:

```
a = 5
b = 6
c = 2
d = 3
e = 1
f = 7
g = 4
```

I doubt there are others.

This prompted me to *randomize* the input array, so that different
possible solutions should pop up; to this extent, [List::Util][]'s
`shuffle` is invaluable.

The full solution, should you be curious:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use List::Util 'shuffle';

sub four_squares_puzzle (@values) {
   my $it = permutations_iterator(items => [@values]);
   while (my @S = $it->()) {
      my $sum = $S[0] + $S[1];
      next if $sum != $S[1] + $S[2] + $S[3];
      next if $sum != $S[3] + $S[4] + $S[5];
      next if $sum != $S[5] + $S[6];
      my @keys = 'a' .. 'g';
      my %retval;
      @retval{@keys} = @S;
      return %retval;
   }
   return;
}

my @input = @ARGV == 7 ? @ARGV : 1 .. 7;
my %solution = four_squares_puzzle(shuffle @input);
if (! scalar keys %solution) {
   say 'no solution, sooooorry!';
}
else {
   for my $key (sort keys %solution) {
      say "$key = $solution{$key}";
   }
}

sub permutations_iterator {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my $items = $args{items} || die "invalid or missing parameter 'items'";
   my $filter = $args{filter} || sub { wantarray ? @_ : [@_] };
   my @indexes = 0 .. $#$items;
   my @stack = (0) x @indexes;
   my $sp = undef;
   return sub {
      if (! defined $sp) { $sp = 0 }
      else {
         while ($sp < @indexes) {
            if ($stack[$sp] < $sp) {
               my $other = $sp % 2 ? $stack[$sp] : 0;
               @indexes[$sp, $other] = @indexes[$other, $sp];
               $stack[$sp]++;
               $sp = 0;
               last;
            }
            else {
               $stack[$sp++] = 0;
            }
         }
      }
      return $filter->(@{$items}[@indexes]) if $sp < @indexes;
      return;
   }
}
```

Stay safe!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#109]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-109/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-109/#TASK2
[Perl]: https://www.perl.org/
[Iterator-based implementation of Permutations]: {{ '/2021/01/30/permutations-iterator/' | prepend: site.baseurl }}
[List::Util]: https://metacpan.org/pod/List::Util
