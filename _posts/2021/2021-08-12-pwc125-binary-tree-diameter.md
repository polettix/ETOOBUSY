---
title: PWC125 - Binary Tree Diameter
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-08-12 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#125][].
> Enjoy!

# The challenge


> You are given binary tree as below:
>
>         1
>        / \
>       2   5
>      / \ / \
>     3  4 6  7
>            / \
>           8  10
>          /
>         9
>
> Write a script to find the diameter of the given binary tree.
>
>> The diameter of a binary tree is the length of the longest path
>> between any two nodes in a tree. It doesn’t have to pass through the
>> root.
>
> For the above given binary tree, possible diameters (6) are:
>
>    3, 2, 1, 5, 7, 8, 9
>    
>    or
>    
>    4, 2, 1, 5, 7, 8, 9


# The questions

Contrarily to what happened in the past, we'll assume that we do not
have to *parse* the tree but that we can somehow build it up in memory
in some convenient way.

We will also assume that the *diameter* only is needed, not an actual
sequence of nodes that make up that specific diameter.

# The solution

I've been favoring [Raku][] as first-attempt language lately, so it's
time to show [Perl][] some love and start with it. By the way, it's also
the one with the comments about what's going on.

```perl
sub visit_for_diameter ($root) {
   die "Ceci n'est pas une arbre\n" unless $root;

   # this keeps the length of the best diameter candidate passing through
   # the $root node itself
   my $subtree = 0;

   # this keeps the longest sub-leg starting from $root
   my $longest = 0;

   # this keeps the best diamater as found in some descendant but not
   # through $root
   my $best = 0;

   # iterate over the left and right sub-trees
   for my $children ($root->@[1, 2]) {

      # don't bother following dead ends
      next unless $children;

      # this gets the recursive sub-call, receiving the best diameter and
      # the longest leg length
      my ($c_best, $c_length) = visit_for_diameter($children);

      # keep the best between the left and the right sub-tree
      $best = $c_best if $c_best > $best;

      # the actual leg length from $root is one more step because we have
      # to reach the child with one step
      ++$c_length;

      # keep the best sub-tree length
      $longest = $c_length if $c_length > $longest;

      # anyway, the best diameter passing through $root has to take into
      # account the length of the leg
      $subtree += $c_length;
   }

   # the longest sub-tree length is established, but the best will have to
   # be established by comparing the best from the descendants and the
   # overall diameter passing through $root (i.e. $subtree)
   $best = $subtree if $subtree > $best;

   # return only the $best diameter in scalar context, and both in list
   # context so that we can properly recurse
   return $best unless wantarray;
   return ($best, $longest);
}
```

The input `$root` is assumed to be a reference to an array, where the
first element is a label (which we ignore here), the second element is
the left sub-tree (`undef` if there is none) and the third element is
the right sub-tree (again, `undef` if there is none).

The idea is to perform a depth-first visit of the tree, emerging the
best diameter in the descendants and comparing it with the best diameter
passing through the specific node. Comments above provide the details
step-by-step.

The [Raku][] version is exceptionally similar, at least for one with
such a strong [Perl][] accent:

```raku
sub visit-for-diameter ($root) {
   die "Ceci n'est pas une arbre\n" unless $root;

   my ($subtree, $longest, $best) = (0, 0, 0);
   for $root[1, 2] -> $children {
      next unless $children;
      my ($c_best, $c_length) = visit-for-diameter($children);
      $best = $c_best if $c_best > $best;
      ++$c_length;
      $longest = $c_length if $c_length > $longest;
      $subtree += $c_length;
   }
   $best = $subtree if $subtree > $best;
   return ($best, $longest);
}
```

There is a big difference in the returned value: where I used
`wantarray` to only return the best diameter in scalar context in the
[Perl][] code, [Raku][] has nothing like that and I just return the
pair. leaving for the printing function the taks of selecting the right
slot in the answer.

And now... this is all for this week, stay safe and have `-Ofun`!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#125]: https://theweeklychallenge.org/blog/perl-weekly-challenge-125/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-125/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
