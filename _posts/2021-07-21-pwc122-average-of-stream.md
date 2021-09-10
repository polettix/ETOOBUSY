---
title: PWC122 - Average of Stream
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-07-21 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#122][]. Enjoy!

# The challenge

> You are given a stream of numbers, `@N`.
>
> Write a script to print the average of the stream at every point.
>
> **Example**
>
>     Input: @N = (10, 20, 30, 40, 50, 60, 70, 80, 90, ...)
>     Output:      10, 15, 20, 25, 30, 35, 40, 45, 50, ...
>     
>     Average of first number is 10.
>     Average of first 2 numbers (10+20)/2 = 15
>     Average of first 3 numbers (10+20+30)/3 = 20
>     Average of first 4 numbers (10+20+30+40)/4 = 25 and so on.

# The questions

My main question is about how big numbers are and how many items might
be in the *stream*. We will assume that the sum of all items fits inside
an integer, even though this might be easily overcome in [Perl][] using
[Math::BigFloat][].

And while we're at it... are we talking about generic *numbers* or
integers only? Just for curiosity...

Last, we will assume that we actually have to write the `Average of
first...` strings... although the example seems to indicate not 😂

# The solution

We will keep it simple, tracking the sum as we go on and dividing it by
the number of items summed so far at each step. This can trigger some
overflow... that's why the questions.

In the spirit of learning some [Raku][], I went for it first:

{% raw %}
```raku
#!/usr/bin/env raku
use v6;

sub average-of-stream (@items) {
   my ($sum, $tsum) = (0, '');
   for 0 .. @items.end -> $last {
      $sum += @items[$last];
      if (! $last) {
         put "Average of first number is $sum.";
         $tsum = $sum;
      }
      else {
         my $n = $last + 1;
         $tsum = $tsum ~ '+' ~ @items[$last];
         put "Average of first $n numbers ($tsum)/$n = {{ $sum / $n }}";
      }
   }
}

my @stream = @*ARGS ?? @*ARGS !! <10 20 30 40 50 60 70 80 90>;
average-of-stream(@stream);
```
{% endraw %}

Then... [Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub average_of_stream (@items) {
   my ($sum, $tsum) = (0, '');
   for my $last (0 .. $#items) {
      $sum += $items[$last];
      if (! $last) {
         say "Average of first number is $sum.";
         $tsum = $sum;
      }
      else {
         my $n = $last + 1;
         $tsum = $tsum . '+' . $items[$last];
         my $avg = $sum / $n;
         say "Average of first $n numbers ($tsum)/$n = $avg";
      }
   }
}

my @stream = @ARGV ? @ARGV : qw<10 20 30 40 50 60 70 80 90>;
average_of_stream(@stream);
```

Enough for this post, thank you all!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#122]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-122/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-122/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Math::BigFloat]: https://metacpan.org/pod/Math::BigFloat
