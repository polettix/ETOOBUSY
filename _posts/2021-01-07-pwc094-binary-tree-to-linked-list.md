---
title: PWC094 - Binary Tree to Linked List
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-01-07 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#094][].
> Enjoy!

# The challenge

> You are given a binary tree. Write a script to represent the given
> binary tree as an object and flatten it to a linked list object.
> Finally print the linked list object.

# The questions

My most pressing question is... *this is the same binary tree
representation as the last week's puzzle, right?!?*.

No answer? I'll take it as a *yes* and reuse what I already did last
time 🙄

Although... I suspect there's something going on here. Maybe, and I say
*maybe*... the best approach might be to *parse the input* into an
actual tree in memory, *then* apply whatever visit is needed.

Is it like this? Should I code an explicit build-up of the binary tree?
Will there be another puzzle requiring it?

I'll not sleep tonight!

# The solution

We're reusing the same logic as before:

```perl
sub build_linked_list ($input) {
   my @rows = map { [ split m{}mxs ] } split m{\n}mxs, $input;
   my $root = 0;
   $root++ while $rows[0][$root] eq ' ';
   my $pre_start = {};
   _build_linked_list_r(\@rows, 0, $root, $pre_start);
   return $pre_start->{next};
}

sub _build_linked_list_r($rows, $rid, $cid, $previous) {
   my $so_far = $previous->{next} = {value => $rows->[$rid][$cid]};
   if ($rid < $#$rows) { # there can be something more
      $rid++;
      if ($cid < $#{$rows->[$rid]}) {
         $so_far = _build_linked_list_r($rows, $rid + 1, $cid - 2, $so_far)
            if 0 < $cid && $rows->[$rid][$cid - 1] ne ' ';
         $so_far = _build_linked_list_r($rows, $rid + 1, $cid + 2, $so_far)
            if $rows->[$rid][$cid + 1] ne ' ';
      }
   }
   return $so_far;
}
```

This time we leverage a *fake initial node* in our linked list, just to
have something to hand over to `_build_linked_list_r` as the "latest
item in the list". We will get rid of it eventually when we return from
`build_linked_list`.

The logic, as anticipated, is the same as before, with the exception
that I found a bug that yielded a warning. Basically we have to *always*
check that a line has a sufficient number of characters to allow for a
children from the previous layer.

The printing part is in the following function:

```perl
sub print_linked_list ($head) {
   my $separator = '';
   while ($head) {
      print $separator, $head->{value};
      $separator = ' -> ';
      $head = $head->{next};
   }
   print "\n";
}
```

Here the trick is that we use a `$separator` string that starts empty
and becomes the arrow just after printing the first item. In this way,
the first item will have nothing before it, while all following items
will be preceded by an arrow like requested.

If you want to play with it... here's the full solution:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
$|++;

sub build_linked_list ($input) {
   my @rows = map { [ split m{}mxs ] } split m{\n}mxs, $input;
   my $root = 0;
   $root++ while $rows[0][$root] eq ' ';
   my $pre_start = {};
   _build_linked_list_r(\@rows, 0, $root, $pre_start);
   return $pre_start->{next};
}

sub _build_linked_list_r($rows, $rid, $cid, $previous) {
   my $so_far = $previous->{next} = {value => $rows->[$rid][$cid]};
   if ($rid < $#$rows) { # there can be something more
      $rid++;
      if ($cid < $#{$rows->[$rid]}) {
         $so_far = _build_linked_list_r($rows, $rid + 1, $cid - 2, $so_far)
            if 0 < $cid && $rows->[$rid][$cid - 1] ne ' ';
         $so_far = _build_linked_list_r($rows, $rid + 1, $cid + 2, $so_far)
            if $rows->[$rid][$cid + 1] ne ' ';
      }
   }
   return $so_far;
}

sub print_linked_list ($head) {
   my $separator = '';
   while ($head) {
      print $separator, $head->{value};
      $separator = ' -> ';
      $head = $head->{next};
   }
   print "\n";
}

my $tree = <<'END';
        1
       / \
      2   3
     / \
    4   5
       / \
      6   7
END

print_linked_list(build_linked_list($tree));
```

Have a good one!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#094]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-094/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-094/#TASK2
[Perl]: https://www.perl.org/
