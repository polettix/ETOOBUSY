---
title: PWC107 - Self-descriptive Numbers
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-04-07 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#107][]. Enjoy!

# The challenge

> Write a script to display the first three self-descriptive numbers. As per
> wikipedia, the definition of Self-descriptive Number is
>> In mathematics, a self-descriptive number is an integer m that in a given
>> base b is b digits long in which each digit d at position n (the most
>> significant digit being at position 0 and the least significant at
>> position b−1) counts how many instances of digit n are in m.

# The questions

My first question is about *what do we mean by the first three*? Is the
ordering following from the ascending ordering of the bases, followed by
some kind of ascending order for the numbers in each base?

Another question - this quite *meta*, I admit - was... *didn't I already
solve this?*. Sure, this is a repeated challenge... but I wasn't
participating into the challenge as of PWC 43, so there had to be something
different.

And last another *meta* question - what are these challenges about? I mean,
what does it mean to *win* the challenge? Is it the fastest to code a
solution? A working solution, or any solution? I admit that I didn't find
anything to this regard (although I do the challenge for the pure fun of
doing it and learn something).

# The solution

It turns out that I did *indeed* solve a *generalization* of the problem.
About one year ago, I started my [Autobiographical Numbers][] series as a
way to apply a small library about Constraint Programming.

And no, I will not inflict you with another series on the same topic.

This time I'll leverage on the fact that only three numbers are requested,
and that I hope (/know) that this will only involve little bases. Hence, a
brute force attack will do:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use List::Util 'sum';

sub nested_loops_iterator {
   my ($dims, $opts, $cb, $accumulator) = @_;
   return unless scalar @{$dims};
   ($opts, $cb) = ($cb, $opts) if ref($opts) eq 'CODE';
   my @indexes     = (-1);
   my @accumulator = (undef) x scalar @{$dims};
   return sub {
      while ((my $level = $#indexes) >= 0) {
         my $dimension = $dims->[$level];
         my $i         = ++$indexes[$level];
         if ($i > $#{$dimension}) { pop @indexes }
         else {
            $accumulator[$level] = $dimension->[$i];
            if   ($level == $#{$dims}) { return @accumulator }
            else                       { push @indexes, -1 }
         }
      }
      return;
   }
}

sub is_self_descriptive (@sequence) {
   for my $i (0 .. $#sequence) {
      my $count = sum map { $_ == $i ? 1 : 0 } @sequence;
      return unless $count == $sequence[$i];
   }
   return 1;
}

sub three_self_descriptive_numbers {
   my ($b, @found) = (1);
   while ('necessary') {
      my $it = nested_loops_iterator([map { [0 .. ($b - 1)]} 1 .. $b]);
      while (my @args = $it->()) {
         push @found, join '', @args if is_self_descriptive(@args);
         return @found if @found == 3;
      }
      ++$b;
   }
   return @found[0..2];
}

say join(', ', three_self_descriptive_numbers());
```

I'm probably killing a mosquito with a cannon, but I had the cannon in the
backyard and so... why not?

We iterate through the bases and then through the values, looking for
numbers that comply. As soon as we find three of them we exit... so it's
brute force with a hearth!

Stay safe people!


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#107]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-107/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-107/#TASK1
[Perl]: https://www.perl.org/
[Autobiographical Numbers]: {{ '/2020/04/08/autobiographical-numbers' | prepend: site.baseurl }}
