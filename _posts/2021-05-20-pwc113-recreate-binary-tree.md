---
title: PWC113 - Recreate Binary Tree
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-05-20 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#113][].
> Enjoy!

# The challenge

> You are given a Binary Tree.
> 
> Write a script to replace each node of the tree with the sum of all the remaining nodes.
>
> **Example**
>
> Input Binary Tree
> 
>         1
>        / \
>       2   3
>      /   / \
>     4   5   6
>      \
>       7
> 
> Output Binary Tree
> 
>         27
>        /  \
>       26  25
>      /   /  \
>     24  23  22
>      \
>      21

# The questions

When in the past the challenge proposed a binary tree, I took it very
literally to get the inputs from the ASCII art representation above.
I'll consider this as a solved problem and assume that the input is
provided in a parsed form.

# The solution

Our algorithm will do two passes over the tree:

- in the first pass, we accumulate the values to end up with the overall
  sum $S$ of all nodes in the tree;
- in the second pass, we will substitute every value $v$ in every node
  with $S - v$, i.e. *the sum of all the remaining nodes*.

At this point... we only need the code:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

sub recreate_binary_tree ($tree) {
   my $sum = 0;
   for my $cb (
      sub ($n) { $sum += $n->{value} },
      sub ($n) { $n->{value} = $sum - $n->{value} },
     )
   {
      my @queue = ($tree);
      while (@queue) {
         my $node = shift(@queue) // next;
         $cb->($node);
         next unless exists $node->{children};
         push @queue, $node->{children}->@*;
      } ## end while (@queue)
   } ## end for my $cb (sub ($n) { ...})
   return $tree;
} ## end sub recreate_binary_tree ($tree)

sub node ($value, $left = undef, $right = undef) {
   my %retval = (value => $value);
   $retval{children} = [$left, $right]
     if defined($left) || defined($right);
   return \%retval;
} ## end sub node

sub printout ($root, $indent = 0) {
   my $value = defined($root) ? $root->{value} : '';
   say '  ' x $indent, "<$value>";
   printout($_, $indent + 1) for $root->{children}->@*;
}

#     1
#    / \
#   2   3
#  /   / \
# 4   5   6
#  \
#   7
my $T =
  node(1, node(2, node(4, undef, node(7))), node(3, node(5), node(6)));

printout(recreate_binary_tree($T));
```

Considering that we have to do the same visit in the tree by only
changing a little action (sum in the first pass, substitute in the
second pass), we loop over two little *callback functions* that
encapsulate the specifics of the actions at each pass, and reuse the
rest of the code in pure *merciless refactoring* spirit.

Stay safe everyone!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#113]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-113/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-113/#TASK2
[Perl]: https://www.perl.org/
