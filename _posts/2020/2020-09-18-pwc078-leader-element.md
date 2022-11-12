---
title: Leader element
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-09-18 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> My second week into the [Perl Weekly Challenge][] - and a reflection.

It seems that the [Perl Weekly Challenge][] challenges this week are a bit
*easier* than the last week. Or are they?

The [task #1][] is this:

> You are given an array `@A` containing distinct integers. Write a
> script to find all leader elements in the array @A. Print (0) if none
> found. An element is leader if it is greater than all the elements to
> its right side.

Its solution is somehow straightforward, it suffices to go backwards to
figure out who's a leader:

```perl
 1 #!/usr/bin/env perl
 2 use 5.024;
 3 use warnings;
 4 
 5 # This problem is easier to tackle if moving from the *end* of the array
 6 # back to the beginning. So, we reverse the input array to analyze it
 7 # and then reverse it again to get back to the original order.
 8 sub keep_leaders { # @A <=> @_
 9    return (0) unless @_;
10    my $last_leader = $_[-1] - 1;
11    return reverse grep {
12       my $condition = $_ > $last_leader;
13       $last_leader = $_ if $condition;
14       $condition;
15    } reverse @_;
16 }
17 
18 
19 # testing stuff
20 for my $Aref (
21    [9, 10, 7, 5, 6, 1],
22    [3, 4, 5],
23    [],
24 ) {
25 
26    printout('Input: @A = ', @$Aref);
27    printout('Output: ', keep_leaders(@$Aref));
28 }
29 
30 sub printout {
31    my $prefix = shift;
32    say $prefix, '(', join(', ', @_), ')'
33 }
```

It also got me thinking that there were such *somehow simpler* solutions
last time, at least with respect to mine.

The bottom line is that these challenges resemble a lot those that you
might get in interviews: the basic info to get *some* solution, but not
enough to get *the* solution. In this way, people can see how you react,
e.g. to check whether you ask questions, whether you think about corner
cases, limits... in brief, to see your though process.

In this case, for example, it might make sense to understand whether
using `reverse` is the right way to go, as opposed to e.g. scan the
array backwards. Or even ask whether there's a limit on the possible
input values, how many will be of them, if we have memory constraints,
time constraints... the list goes on.

Last time for Fibonacci, for example, I definitely avoided finding
solution with a brute force search over all possible arrangements of the
Fibonacci candidates, and went the much harder way of figuring out the
most compact solution and then working from that, chipping off the
remaning overlaps.

For low input numbers, in hindsight this probably makes no sense. This
approach probably starts paying off with way bigger numbers. So in a
sense that complicated solution was a reflection of my inner self that
usually aims at solving a problem and forgetting about it - with enough
lazyness and hubris that will will even work if someone decides to put a
very big number in. Call me *defensive*.

On the other hand, this is a wonderful occasion to realize that it's not
always like this.

By making questions in an interview, you might be told that the numbers
will always be below a threshold, etc. so it might make sense to express
the different alternatives loud and say that there is a brute force
solution that will save programmer time at the expense of some
performance, and that there is a more *linear* solution that requires
more time to code and test.

At the end of the day, this is probably what they're after.

[task #1]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-078/#TASK1
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
