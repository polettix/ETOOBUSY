---
title: PWC150 - Fibonacci Words
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-02-02 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#150][]. Enjoy!

# The challenge

> You are given two strings having same number of digits, `$a` and `$b`.
>
> Write a script to generate `Fibonacci Words` by concatenation of the
> previous two strings. Finally print 51st digit of the first term
> having at least 51 digits.
>
> **Example:**
>
>     Input: $a = '1234' $b = '5678'
>     Output: 7
>
>     Fibonacci Words:
>
>     '1234'
>     '5678'
>     '12345678'
>     '567812345678'
>     '12345678567812345678'
>     '56781234567812345678567812345678'
>     '1234567856781234567856781234567812345678567812345678'
>
>     The 51st digit in the first term having at least 51 digits '1234567856781234567856781234567812345678567812345678' is 7. 

# The questions

This challenge made me scratch my head because it's easy to infer what
the generation algorithm should be (join consecutive elements as strings
instead of summing them), and yet I can't find any reference to this
elsewhere. Well, I mean in the [first few results from
DuckDuckGo][search].

Whatever, I'll go for the string joining approach.


# The solution

So, let's go [Raku][] first. There is a particular itch to scratch here,
in that the first two items to produce aren't actually *manufactured*,
so I spent a bit of time to think about how to deal with this special
case.

I can't say my solution is particularly clever: member variable
`$!backlog` keeps track of how many items from this "backlog" we still
have to give out, and when this hits 0 we start producing new items.

```raku
#!/usr/bin/env raku
use v6;

class FibonacciWords { ... };

sub MAIN (Int:D $a, Int:D $b where $b.Str.chars == $a.Str.chars) {
   my $it = FibonacciWords.new($a, $b);
   put "Fibonacci Words\n";
   loop {
      my $item = $it.next();
      put "'$item'";
      if $item.chars >= 51 {
         my $digit = $item.substr(50, 1);
         put "\nThe 51st digit in the first term having at least 51 digits '$item' is $digit.";
         last;
      }
   }
}

class FibonacciWords {
   has $!f0 is built;
   has $!f1 is built;
   has $!backlog = 2;
   method new (Str() $f0, Str() $f1) { self.bless(:$f0, :$f1) }
   method next () {
      if ! $!backlog {
         ($!f0, $!f1) = ($!f1, $!f0 ~ $!f1);
         return $!f1;
      }
      --$!backlog;
      return $!backlog ?? $!f0 !! $!f1;
   }
}
```

Using a class is... *how to say*... totally overkill, but that's how it
is!

The [Perl][] version transforms the object into an iterator sub
reference. I so love iterators. And yes, it's still overkill.

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use English qw< -no_match_vars >;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

say "Fibonacci Words:\n";
my $it = fibonacci_words_iterator(@ARGV);
while ('necessary') {
   my $item = $it->();
   say "'$item'";
   if (length $item >= 51) {
      my $digit = substr $item, 50, 1;
      say "\nThe 51st digit in the first term having at least 51 digits '$item' is $digit.";
      last;
   }
}

sub fibonacci_words_iterator ($f0, $f1) {
   my @cache = ('', '', $f0, $f1);
   my $backlog = 2;
   return sub {
      if (! $backlog) {
         ($f0, $f1) = ($f1, $f0 . $f1);
         return $f1;
      }
      --$backlog;
      return $backlog ? $f0 : $f1;
   };
}
```

Stay safe folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#150]: https://theweeklychallenge.org/blog/perl-weekly-challenge-150/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-150/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[search]: https://duckduckgo.com/?t=ffab&q=fibonacci+words&ia=web
