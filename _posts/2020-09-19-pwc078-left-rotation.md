---
title: PWC - Left Rotation
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2020-09-19 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> The solution to [task #2][] of the [Perl Weekly Challenge][] for this
> week, and additional reflections.

In last post [Leader element][] I shared a trivial thought about how the
[Perl Weekly Challenge][] tasks can be a good excercise for thinking
about the problems beyond providing a quick answer for them.

This is also the case for the [task #2][] in this week's challenge:

> You are given array @A containing positive numbers and @B containing
> one or more indices from the array @A.
>
> Write a script to left rotate @A so that the number at the first index
> of @B becomes the first element in the array. Similary, left rotate @A
> again so that the number at the second index of @B becomes the first
> element in the array.

My solution is pretty straightforward (most is scaffolding for testing):

```perl
 1 #!/usr/bin/env perl
 2 use 5.024;
 3 use warnings;
 4 use experimental qw< postderef signatures >;
 5 no warnings qw< experimental::postderef experimental::signatures >;
 6 
 7 sub shift_left_by ($n, @A) { (@A[$n..$#A], @A[0..($n-1)]) }
 8 sub shift_left ($A, $B) { map { [shift_left_by($_, $A->@*)] } $B->@* }
 9 
10 for my $test (
11    [
12       'first test',
13       [qw< 10 20 30 40 50 >],
14       [qw< 3 4 >],
15    ],
16    [
17       'second test',
18       [qw< 7 4 2 6 3 >],
19       [qw< 1 3 4 >]
20    ],
21 ) {
22    my ($title, $A, $B) = $test->@*;
23    say {*STDERR} $title;
24    say {*STDOUT} '[', join(', ', $_->@*), ']' for shift_left($A, $B);
25 }
```

Function `shift_left` iterates over the indexes in `$B` (which is a
reference to `@B`) and calls the actual left-shifting function
`shift_left_by`. This, in turn, takes the relevant parts out of the
array and arranges them as requested.

There's a lot that might be discussed, e.g.:

- this solution assumes that it's OK to create copies of the `@A` array
  around, which should be double checked;
- it might be interesting to understand whether a solution that "starts
  from the previous iteration" might go better (e.g. speed-wise) with
  respect to this, especially if we're not allowed to make copies of
  `@A` but have to do the shifting in-place (in this case, we would have
  to do some modulo `scalar(@A)` arithmetic over the indices in `@B`);
- what should the functions/script do in case of wrong inputs (e.g. an
  index in `@B` that is not present in `@A`).

Cheers!



[task #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-078/#TASK2
[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[Leader element]: {{ '/2020/09/18/pwc078-leader-element' | prepend: site.baseurl }}
