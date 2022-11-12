---
title: PWC130 - Binary Search Tree
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-09-16 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#130][].
> Enjoy!

# The challenge

> You are given a tree.
>
> Write a script to find out if the given tree is `Binary Search Tree
> (BST)`.
>
> According to [wikipedia][wp-bst], the definition of BST:
>
>> A binary search tree is a rooted binary tree, whose internal nodes
>> each store a key (and optionally, an associated value), and each has
>> two distinguished sub-trees, commonly denoted left and right. The
>> tree additionally satisfies the binary search property: the key in
>> each node is greater than or equal to any key stored in the left
>> sub-tree, and less than or equal to any key stored in the right
>> sub-tree. The leaves (final nodes) of the tree contain no key and
>> have no structure to distinguish them from one another.
>
> **Example 1**
>
>     Input:
>             8
>            / \
>           5   9
>          / \
>         4   6
>     
>     Output: 1 as the given tree is a BST.
>
> **Example 2**
>
>     Input:
>             5
>            / \
>           4   7
>          / \
>         3   6
>     
>     Output: 0 as the given tree is a not BST.

# The questions

My question about the definition is whether the leaves are considered
only the *empty* left/right nodes of a node that has a key. Another
question would be whether a node with a key always has two non-empty
left and right children.

All in all, anyway, it doesn't really matter for the implementation I
have in mind... so it's more curiosity than anything else.

# The solution

The most straightforward approach is, for me, to go recursive. In this
case, in each node we will have to consider the following quantities:

- the *key* of the node itself;
- the *minimum key* and the *maximum key* of the left child, which we
  will call `$lmin` and `$lmax`;
- the same quantities for the right child, respectively `$rmin` and
  `$rmax`.

At that node, we have the following:

- if either the left or the right child don't comply with the BST rules,
  then the whole tree does not either. Hence, we have to make sure that
  they do.
- At the specific node, we must check that the key is greater than
  `$lmax` (i.e. the maximum value on the left side) and that it is also
  less than `$rmin` (i.e. the minimum value on the right side).

If both apply, then this particular node is good, and we can go back to
the parent node, reporting a success and also `$lmin` and `$rmax` as the
overall minimum and maximum values.

In case the tree is not perfectly assembled (e.g. a node only has a left
or a right side) we will have to cope with the fact and act accordingly.

[Perl][] goes first this time:

{% raw %}

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub check_bst ($root) {
   state $checker = sub ($node) {
      return 1 unless $node;
      my $key = $node->{key};
      my ($lsub, $lmin, $lmax) = __SUB__->($node->{left});
      return 0 unless $lsub;
      ($lmin, $lmax) = ($key, $key - 1) unless defined $lmin;
      my ($rsub, $rmin, $rmax) = __SUB__->($node->{right});
      return 0 unless $rsub;
      ($rmin, $rmax) = ($key + 1, $key) unless defined $rmin;
      return 0 if $key < $lmax || $key > $rmin;
      return (1, $lmin, $rmax);
   };
   return ($checker->($root))[0];
}

sub n ($k, $l = undef, $r = undef) {{key => $k, left => $l, right => $r}}

say check_bst(n(8, n(5, n(4), n(6)), n(9)));
say check_bst(n(5, n(4, n(3), n(6)), n(7)));
```

{% endraw %}

I guess that these two lines deserve some additional explanation:

```
($lmin, $lmax) = ($key, $key - 1) unless defined $lmin;
...
($rmin, $rmax) = ($key + 1, $key) unless defined $rmin;
```

In case a leg is empty, we get nothing from it (i.e. `undef`). This
inherently means that the sub-tree on that side is compliant, hence:

- to make the test succeed, we set `$lmax` to be smaller than the key
  (`$key - 1`), and `$rmin` to be greater than it (`$key + 1`).
- on the other hand, the missing extreme is set to be equal to `$key`,
  because this is the value we want to send back to the parent's call.

Time for [Raku][] now, which is a simple translation:

```raku
#!/usr/bin/env raku
use v6;

sub check-bst ($root) {
   my sub checker ($node --> Array()) {
      return 1 unless $node;
      my ($key, $left, $right) = $node<key left right>;
      my ($lsub, $lmin, $lmax) = checker($left);
      return 0 unless $lsub;
      ($lmin, $lmax) = ($key, $key - 1) unless defined $lmin;
      my ($rsub, $rmin, $rmax) = checker($right);
      return 0 unless $rsub;
      ($rmin, $rmax) = ($key + 1, $key) unless defined $rmin;
      return 0 if $key < $lmax || $key > $rmin;
      return (1, $lmin, $rmax);
   }
   return checker($root)[0];
}

sub n ($k, $l = Nil, $r = Nil) {(key => $k, left => $l, right => $r).hash}

put check-bst(n(8, n(5, n(4), n(6)), n(9)));
put check-bst(n(5, n(4, n(3), n(6)), n(7)));
```

And with this... it's all for this post, I hope you enjoyed it and stay
safe anyway!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#130]: https://theweeklychallenge.org/blog/perl-weekly-challenge-130/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-130/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[wp-bst]: https://en.wikipedia.org/wiki/Binary_search_tree
