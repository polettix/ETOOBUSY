---
title: PWC199 - Good Pairs
type: post
tags: [ the weekly challenge ]
comment: true
date: 2023-01-12 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#199][]. Enjoy!

# The challenge

> You are given a list of integers, `@list`.
>
> Write a script to find the total count of `Good Pairs`.
>
>> A pair (i, j) is called good if list[i] == list[j] and i < j.
>
> **Example 1**
>
>     Input: @list = (1,2,3,1,1,3)
>     Output: 4
>
>     There are 4 good pairs found as below:
>     (0,3)
>     (0,4)
>     (3,4)
>     (2,5)
>
> **Example 2**
>
>     Input: @list = (1,2,3)
>     Output: 0
>
> **Example 3**
>
>     Input: @list = (1,1,1,1)
>     Output: 6
>
>     Good pairs are below:
>     (0,1)
>     (0,2)
>     (0,3)
>     (1,2)
>     (1,3)
>     (2,3)

# The questions

I wonder if all these definitions of "good" are a leftover from Santa,
just to make sure that every kid can get a present.

# The solution

This is... just plain counting.

The input can be partitioned into subsets of elements that are equal to
each other. As these items have to be considered "ordered" (because of
the `i < j` constraint in the definition), for each of these
partitions/subsets we have to calculate the [triangular number][].

This is the *theory*.

*In practice*, we can just sweep the input list one element at a time,
and add to the total counter the number of times we saw this element
before in the list (each of those members makes a "good pair" with the
current element). Then we increase the count for that element.

*In more practice*, we can track these members using a hash, and take
advantage of the post-increment `++` operator to get the *we already saw
so far* count while increasing count for the same time, all in a single
instruction.

In [Raku][] terms:

{% raw %}
```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put good-pairs(@args ?? @args !! (1, 2, 3, 1, 1, 3))}
sub good-pairs (*@list) { my %c; @list.map({%c{$_}++}).sum }
```
{% endraw %}

The `%c` hash keeps track of the count as explained above. The map
returns the list of items to sum, which we then... `.sum`. Nice and
compact.

The [Perl][] counterpart suffers *a bit* from the lack of a
batteries-included `sum` function. Right, there is one in the CORE
module [List::Util][], but who wants to `use` it anyway?!?

```perl
#!/usr/bin/env perl
use v5.24;
say good_pairs(@ARGV ? @ARGV : (1, 2, 3, 1, 1, 3));
sub good_pairs { my $s = 0; my %c; $s += $c{$_}++ for @_; $s }
```

I'm taking a *bad habit* in these examples, i.e. to avoid `warnings`.
Keep in mind, these are toy challenges and these are *less-than-5-lines*
program, so it's OK. Remove either condition, and it becomes *much less
OK*.

I guess it's everything for this challenge, stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#199]: https://theweeklychallenge.org/blog/perl-weekly-challenge-199/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-199/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[triangular number]: https://en.wikipedia.org/wiki/Triangular_number
[List::Util]: https://metacpan.org/pod/List::Util
