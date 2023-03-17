---
title: PWC208 - Minimum Index Sum
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-03-17 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#208][]. Enjoy!

# The challenge

> You are given two arrays of strings.
>
> Write a script to find out all common strings in the given two arrays with
> minimum index sum. If no common strings found returns an empty list.
>
> **Example 1**
>
>     Input: @list1 = ("Perl", "Raku", "Love")
>            @list2 = ("Raku", "Perl", "Hate")
>
>     Output: ("Perl", "Raku")
>
>     There are two common strings "Perl" and "Raku".
>     Index sum of "Perl": 0 + 1 = 1
>     Index sum of "Raku": 1 + 0 = 1
>
> **Example 2**
> 
>     Input: @list1 = ("A", "B", "C")
>            @list2 = ("D", "E", "F")
>
>     Output: ()
>
>     No common string found, so no result.
>
> **Example 3**
>
>     Input: @list1 = ("A", "B", "C")
>            @list2 = ("C", "A", "B")
>
>     Output: ("A")
>
>     There are three common strings "A", "B" and "C".
>     Index sum of "A": 0 + 1 = 1
>     Index sum of "B": 1 + 2 = 3
>     Index sum of "C": 2 + 0 = 2

# The questions

All examples seem to hint that the two lists have the same length, but I'll
assume that they might have different ones. I'll also consider that one list
might have repeated items, and that taking the one with the lowest index is
fine.

Another gray corner is whether the comparison should be case sensitive or
not - I'll assume yes, i.e. `Foo` and `foo` are different strings.


# The solution

As we have to match items from one list with items from the other, it makes
sense to construct an *inverted index mapping* for the second list, taking a
string as key and providing the (lowest available) index as value. This
comes very easy mixing the `.kv` method to get an alternation of indexes and
values from the list, as well as using `.reverse` which both gives us the
inverted indexing (switching places between keys and values) **and**
selecting the lowest index as the winner in case of duplicates:

```raku
my %list2-index-for = $list2.kv.reverse; # keeps minimum!
```

The same in [Perl][] could be done with some help from one of the list
modules, but we can do also in some different way leveraging the
*defined-or* to select the minimum index for each item (thus coping with
duplicates):

```perl
my %list2_index_for;
$list2_index_for{$list2->[$_]} //= $_ for 0 .. $list2->$#*;
```

With this in hand, we can just iterate through the first list and skip items
that are *not* available in the second list. For those items that we
actually find, we can calculate the sum of the indexes from both lists and
compare with the *minimum so far*:

- if the new sum is better, we reset the list of results
- if it's the same, we append the new item to the list
- otherwise, we just ignore the item.

[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@items) {
   my @lists = [], [];
   my $i = 0;
   for @items -> $item {
      if ($item eq '/') { $i = 1 }
      else { @lists[$i].push: $item }
   }
   say minimum-index-sum(@lists[0], @lists[1]);
}

sub minimum-index-sum ($list1, $list2) {
   my %list2-index-for = $list2.kv.reverse; # keeps minimum!
   my @result;
   my $min-sum = $list1.elems + $list2.elems; # beyond "possible"
   for @$list1.kv -> $i1, $item {
      defined(my $i2 = %list2-index-for{$item}) or next;
      my $this-sum = $i1 + $i2;
      if ($this-sum < $min-sum) { # new winner, reset
         @result = $item,;
         $min-sum = $this-sum;
      }
      elsif ($this-sum == $min-sum) { # append
         @result.push: $item;
      }
      else {} # just skip this
   }
   return @result;
}
```

[Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

my @list1;
while (@ARGV) {
   my $item = shift(@ARGV);
   last if $item eq '/';
   push @list1, $item;
}
my @m = minimum_index_sum(\@list1, \@ARGV);
say "(@m)";

sub minimum_index_sum ($list1, $list2) {
   my %list2_index_for;
   $list2_index_for{$list2->[$_]} //= $_ for 0 .. $list2->$#*;
   my @result;
   my $min_sum = scalar($list1->@*) + scalar($list2->@*);
   for my $i1 (0 .. $list1->$#*) {
      my $item = $list1->[$i1];
      defined(my $i2 = $list2_index_for{$item}) or next;
      my $this_sum = $i1 + $i2;
      if ($this_sum < $min_sum) { # new winner, reset
         @result = ($item);
         $min_sum = $this_sum;
      }
      elsif ($this_sum == $min_sum) { # append
         push @result, $item;
      }
      else {} # just skip this
   }
   return @result;
}
```

That's all folks... stay safe!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#208]: https://theweeklychallenge.org/blog/perl-weekly-challenge-208/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-208/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
