---
title: PWC115 - String Chain
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-06-02 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#115][]. Enjoy!

# The challenge

> You are given an array of strings.
>
> Write a script to find out if the given strings can be chained to form
> a circle. Print 1 if found otherwise 0.
>
>> A string `$S` can be put before another string `$T` in circle if the
>> last character of `$S` is same as first character of `$T`.
>
> **Examples**:
>
>     Input: @S = ("abc", "dea", "cd")
>     Output: 1 as we can form circle e.g. "abc", "cd", "dea".
>
>     Input: @S = ("ade", "cbd", "fgh")
>     Output: 0 as we can't form circle.

# The questions

This is more a question to myself... *why did this take this long to
solve?!?*. I guess Covid got a bit in the way...

Anyway, I guess that the intent is clear and that:

- different case means different characters;
- strings might be repeated;
- it's better to print out a solution!

# The solution

This is the [Perl][] solution:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub string_chain (@S) {
   my $start = shift @S;
   my ($sf, $sl) = (substr($start, 0, 1), substr($start, -1, 1));

   my %starting_with;
   push $starting_with{substr $_, 0, 1}->@*, [$_, 0] for @S;

   return unless exists $starting_with{$sl};
   my @chain = ([$starting_with{$sl}, -1]);

   LINK:
   while ('necessary') {
      my $top = $chain[-1];
      if ((my $i = $top->[-1]) < $top->[0]->$#*) {
         $top->[0][$i][1] = 0 if $i >= 0; # reset last iteration
         ++$i; # advance at least once
         ++$i while $i <= $top->[0]->$#* && $top->[0][$i][1];

         $top->[-1] = $i;
         redo LINK if $i > $top->[0]->$#*;

         my $last_letter = substr $top->[0][$i][0], -1, 1;
         if (@chain == @S) {
            if ($last_letter eq $sf) {
               return [
                  $start,
                  map {$_->[0][$_->[-1]][0]} @chain,
               ];
            }
         }
         else {
            $top->[0][$i][1] = 1; # mark this item
            if (my $sw = $starting_with{$last_letter}) {
               push @chain, [$sw, -1]; # "recurse"
            }
            else {
               return if $last_letter ne $sf;
            }
         }
      }
      elsif (@chain > 1) { pop @chain } # backtrack...
      else               { return     } # no luck...
   }
}

my @words = @ARGV ? @ARGV : qw< abc dea cd >;
if (my $chain = string_chain(@words)) {
   say 1;
   say {*STDERR} join ' ', $chain->@*;
}
else { say 0 }
```

There's not too much to explain:

- we're simulating a recursion via a loop over a stack (`@chain`). A
  recursion would be the same of course, but we would need to pass a lot
  of stuff around;
- there is no backtracking from the very first step (hence `@chain > 1`)
- I have no idea if it's breaking in some obscure way!

I'll see if I'll also code a [Raku][] solution... although my level is
so basic that I usually struggle in just *translating* [Perl][] 🙄


[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#115]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-115/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-115/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
