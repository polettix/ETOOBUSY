---
title: PWC106 - Maximum Gap
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-03-31 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from the [Perl Weekly Challenge][]
> [#106][]. Enjoy!

# The challenge

> You are given an array of integers `@N`. Write a script to display the
> maximum difference between two successive elements once the array is
> sorted. If the array contains only 1 element then display 0.

# The questions

As a paranoid of corner cases, my first question would be... *what if the
array is empty?*. I'll take that 0 is a valid answer here too.

The other question might also be... *is there an efficient way to do this in
better than $O(N log(N))$ ?!?* 😅

# The solution

I waited. A long time. And no answer came to my last question.

Well, at least if you consider 5 seconds a long time to say... to hell with
it, let's just use the *brute force* and spare *precious developer time*.

At this point, the path is clear. Though no eyes can see. Now I'm really
digressing.

So, boring solution here:

- first, let's sort the input data;
- then, scan every consecutive pair to look for the maximum gap.

All of this... with a readability twist!

```perl
sub maximum_gap (@N) {
   return 0 if @N <= 1;
   (my $p, @N) = sort { $a <=> $b } @N;
   return max(map { (my $d, $p) = ($_ - $p, $_); $d } @N);
}
```

When sorting the inputs, we take care to *remove* the first item and put it
in variable `$p`. This is our *previous* element in each pair.

At this point, we can transform the sorted input data in a sequence of gaps:

```perl
map { (my $d, $p) = ($_ - $p, $_); $d } @N
```

The assignment here is between two lists; this allows us to both calculate
the difference (in `$d`) *and* update the value of `$p` for the next
iteration. As we want to generate the list of gaps, the last expression in
`map`'s body is the difference we calculated in `$d`.

At this point we just have to get the `max` out of it!

The whole script, should you be curious:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub maximum_gap (@N) {
   return 0 if @N <= 1;
   (my $p, @N) = sort { $a <=> $b } @N;
   return max(map { (my $d, $p) = ($_ - $p, $_); $d } @N);
}

my @input = @ARGV ? @ARGV : (1, 3, 8, 2, 0);
say maximum_gap(@input);
```

Stay safe and have fun, hopefully!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#106]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-106/
[TASK #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-106/#TASK1
[Perl]: https://www.perl.org/
