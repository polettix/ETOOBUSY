---
title: PWC220 - Squareful
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-06-09 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#220][].
> Enjoy!

# The challenge

> You are given an array of integers, @ints.
>
>> An array is squareful if the sum of every pair of adjacent elements is a
>> perfect square.
>
> Write a script to find all the permutations of the given array that are
> squareful.
>
> **Example 1:**
>
>     Input: @ints = (1, 17, 8)
>     Output: (1, 8, 17), (17, 8, 1)
>
>     (1, 8, 17) since 1 + 8 => 9, a perfect square and also 8 + 17 => 25 is perfect square too.
>     (17, 8, 1) since 17 + 8 => 25, a perfect square and also 8 + 1 => 9 is perfect square too.
>
> **Example 2:**
>
>     Input: @ints = (2, 2, 2)
>     Output: (2, 2, 2)
>
>     There is only one permutation possible.

# The questions

I think that the challenge is concise yet clear and complete. I'd probably
ask if there's any limit on the input values, both in terms of integer
values and how many elements might end up in the array:

- knowing the domain can be important to figure out whether big number
  libraries are needed or not;
- the amount of elements directly influences the solution and how much time
  we should devote to it!

# The solution

We'll take the bait and assume that we're going to address only *very short*
input arrays. You know, so short that the factorial of this amount is still
manageable.

If this is the case, let's just go down the *brute force* path and evaluate
*every*. *single*. *permutation*.

In [Perl][], I'll borrow [a function from *past me*][past] (thanks!) to
calculate all permutations:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
use JSON::PP;

my $sit = squareful_iterator(@ARGV);
while (my $squareful = $sit->()) {
   say encode_json($squareful) =~ tr{[]}{()}r;
}

sub squareful_iterator (@ints) {
   return sub { return undef } if @ints < 2;
   my $it = permutations_iterator(items => \@ints);
   my %seen;
   return sub {
      while (my $candidate = $it->()) {
         next unless is_squareful($candidate);
         return $candidate unless $seen{join ',', $candidate->@*}++;
      }
      return;
   };
}

sub is_squareful ($list) {
   for my $i (1 .. $list->$#*) {
      my $sum = $list->[$i - 1] + $list->[$i];
      return 0 if int(sqrt($sum)) ** 2 != $sum;
   }
   return 1;
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

Yep, that's right: no attempt at optimizing anything. Hey! I'm being honest
about it... I know that with some knowledge about how the permutations are
calculated, we might *at least* cut the calculations in half (every solution
also admits its reverse as a solution, right?), but no... we'll just stop
here because we have other work to do, right?

Like... coding the [Raku][] solution:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@ints) {
   .say for squarefuls(@ints);
}

sub squarefuls (@ints) {
   my %seen;
   gather for @ints.permutations -> $candidate {
      next unless is-squareful($candidate);
      take $candidate unless %seen{$candidate.join(',')}++;
   }
}

sub is-squareful ($list) {
   for 1 .. $list.end -> $i {
      my $sum = $list[$i - 1] + $list[$i];
      return False if $sum.sqrt.Int² != $sum;
   }
   return True;
}
```

I *do* remember when I was a child and how frustrating it was to be given a
present that needed batteries and *they where not there*. So yes, I love
[Raku][] for coming with every possible voltage and amperage.

Well, *mostly*.

Stay safe folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#220]: https://theweeklychallenge.org/blog/perl-weekly-challenge-220/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-220/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[past]: https://github.com/polettix/cglib-perl/blob/master/Permutations.pm
