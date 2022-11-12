---
title: PWC129 - Root Distance
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-09-08 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#129][]. Enjoy!

# The challenge

> You are given a tree and a node of the given tree.
> 
> Write a script to find out the distance of the given node from the
> root.
> 
> **Example 1:**
>
>     Tree:
>             1
>            / \
>           2   3
>                \
>                 4
>                / \
>               5   6
>     
>     Node: 6
>     Output: 3 as the distance of given node 6 from the root (1).
>     
>     Node: 5
>     Output: 3
>     
>     Node: 2
>     Output: 1
>     
>     Node: 4
>     Output: 2
>
> **Example 2:**
>
>     Tree:
>             1
>            / \
>           2   3
>          /     \
>         4       5
>          \     /
>           6   7
>          / \
>         8   9
>     
>     Node: 7
>     Output: 3 as the distance of given node 6 from the root (1).
>     
>     Node: 8
>     Output: 4
>     
>     Node: 6
>     Output: 3

# The questions

I keep calling this section *questions*, but who am I kidding? It's a
way to take some *assumptions* and try to bend the challenge to
something that tastes good for me.

Which is the case here. Nowhere we're talking about *binary* trees,
although the examples' shape seems to hint that they are indeed. But
I'll still read only *tree* and assume that each node can have an
undefined number of children.

Another curious thing is the labeling. Or lack thereof. What does it
mean that we are *given [...] a node*? Do we get the *whole* node as it
appears in the (well, *our*) representation of the tree, or are we given
a label associated to it?

It might indeed make a difference. While in a tree nodes are arranged in
a specific shape, their label might be repeated across the tree and so
defining *one* distance from the root might not be proper. Anyway, we'll
assume that:

- we're given a *label* to look for, and
- labels are unique across the whole tree.

Enough, let's go to the solution!

# The solution

This challenge is like a mosquito that is *perfect* for the cannon I
developed some time ago.

## Raku

You know how a *tree* is actually a *graph* that has some additional
constraints? Well, now you know. Which means that whatever works for a
generic graph, works on trees to. Including a generic [Depth-First
Algorithm Implementation][], which I talked a bit in [Graph visit
algorithms in cglib-raku][] by the way.

In this case, we will leverage two *hooks* in the graph visit:

- `discovery-action`: this is called as soon as a node is *discovered*,
  which happens at most once per visit;
- `leave-action`: this is called when the algorithm has done with a node
  and is about to leave it for good.

To measure the distance from the root node is the same as measuring at
which *depth* a node is located. To do this, we keep track of `$depth`,
increasing it for `discovery-action`s and decreasing it for
`leave-action`s:

```raku
sub depth ($root, $label) {
   my $depth = 0;
   dfv(
      $root,
      discover-action => -> $n, $parent {
         return $depth if $n<label> eq $label;
         ++$depth;
      },
      leave-action => -> $n, $parent { --$depth },
   );
   return NaN;
}
```

Well... there's **so much** to unpack here!!!

First thing is the seemengly casual `return $depth if ...`, which is
basically when we hit the target node and have to look no further. This
cannot be done in [Perl][], not like this: the `discover-action` would
be a full-fledged `sub` in that case, which would mean that the `return`
would be related to the `sub`.

Things are differente here, though. The `discover-action` key points to
a [Block][] of code, which is like a `sub`'s small brother that has no
`return` capabilities on its own. Hence, **that** `return` refers to
`sub depth` actually, which is exactly what we are after. Yay!

Another little but **crucial** thing is how we call `dfv`. Note, **no
space** between the function name and the opening parentheses. Had I put
any... the whole thing would be different. To see why, let's take a
look:

```
> sub whatever ($head, *@tail) { $head.^name.put; $head.put }
&whatever
> 
> whatever(1, 2, 3)
Int
1
> 
> whatever (1, 2, 3)
List
1 2 3
```

Hence, when the open parenthesis is immediately after the function name,
it marks the start of the arguments list. If there's a space, though,
the space itself is supposed to mark the beginning of the arguments
list, hence we're passing a *single* [List][] `(1, 2, 3)`.

Last, function `dfv` is a littly currying of the original depth-first
implementation:

```raku
sub dfv ($root, *%named) {
   return depth-first-visit(
      successors => -> $n {
         $n<children>:exists ?? $n<children>.Slip !! [].Slip },
      start      => [$root],
      identifier => -> $n { $n<label> },
      |%named,
   );
}
```

Why did I factor this into its own function?

Well... for reusing it, of course! What would be this program without
proper visualization of a tree? And how do we generate the
visualization, if not by doing *another* depth-first visit?!?

Here's the complete program in [Raku][], should you want to play with
it (buckle up!):

```raku
#!/usr/bin/env raku
use v6;
sub MAIN ($target = 3) {
   {
      my $n3 = node(3, node(4, (5, 6).map({node($_)}) ));
      my $root = node(1, node(2), $n3);
      print-tree($root);
      put depth($root, $target);
   }
   put '';
   {
      my $n2 = node(2, node(4, node(6, (8, 9).map({node($_)}) )));
      my $n3 = node(3, node(5, node(7)));
      my $root = node(1, $n2, $n3);
      print-tree($root);
      put depth($root, $target);
   }
}

sub node ($l, *@c) { my $h = (label => $l, children => @c).hash }

sub print-tree ($root) {
   my %is-last;
   my @prefix;
   dfv(
      $root,
      discover-action => -> $n, $parent {
         my $label = 'o-- ' ~ $n<label>;
         if (@prefix) {
            put ' ', @prefix.join('');
            put ' ', @prefix[0..*-2].join(''), ' ', $label;
         }
         else {
            put $label;
         }
         @prefix[*-1] = '  ' if %is-last{$n<label>};
         @prefix.push: ' |';
         %is-last{$n<children>[*-1]<label>} = 1 if $n<children>.elems;
      },
      leave-action => -> $n, $parent { @prefix.pop },
   );
}

sub depth ($root, $label) {
   my $depth = 0;
   dfv(
      $root,
      discover-action => -> $n, $parent {
         return $depth if $n<label> eq $label;
         ++$depth;
      },
      leave-action => -> $n, $parent { --$depth },
   );
   return NaN;
}

sub dfv ($root, *%named) {
   return depth-first-visit(
      successors => -> $n {
         $n<children>:exists ?? $n<children>.Slip !! [].Slip },
      start      => [$root],
      identifier => -> $n { $n<label> },
      |%named,
   );
}

sub depth-first-visit (
      :&discover-action,       # first time a node is found
      :action(:&visit-action), # when node is visited
      :&skip-action,           # node skipped due previous visit
      :&leave-action,          # node visiting ends
      :identifier(:&id) = -> $item {~$item},
      :&successors!,
      :@start!,
) {
   my %a; # adjacent nodes
   my @s = @start.map: { &discover-action($_, Nil) if &discover-action;
                         %a{&id($_)} = [&successors($_)]; [$_, Nil] };
   while @s {
      my ($v, $pred) = @s[*-1]; # "top" of the stack
      &visit-action($v, $pred) if &visit-action;
      my $vid = &id($v);
      if %a{$vid}.elems {
         my $w = %a{$vid}.shift;
         my $wid = &id($w);
         if (%a{$wid}:exists) {
            &skip-action($w, $v) if &skip-action;
         }
         else {
            &discover-action($w, $v) if &discover-action;
            %a{$wid} = [&successors($w)];
            @s.push: [$w, $v];
         }
      }
      else {
         &leave-action($v, $pred) if &leave-action;
         @s.pop;
      }
   }
   return %a.keys;
}
```

This is an example representation of a tree, thanks to `print-tree`:

```
o-- 1
  |
  o-- 2
  | |
  | o-- 4
  |   |
  |   o-- 6
  |     |
  |     o-- 8
  |     |
  |     o-- 9
  |
  o-- 3
    |
    o-- 5
      |
      o-- 7
```

I will never admit that `print-tree` took me the most of the time to get
this program work 🙄

## Perl

As anticipated, we took advantage of a feature we have in [Raku][], so
we will have to do it *the right way* on our own:

```perl
sub depth ($root, $label) {
   my $depth = 0;
   eval {
      depth_first_visit(
         start => $root,
         successors => sub ($n) { ($n->{children} // [])->@* },
         identifier => sub ($n) { $n->{label} },
         pre_action => sub ($n, $parent) {
            die 'done!' if $n->{label} eq $label;
            ++$depth;
         },
         post_action => sub { --$depth },
      );
      1;
   } or return $depth;
   return 'NaN';
}
```

Yes, yes... we're *abusing* `eval`/`die` to get out of the tree visit as
soon as we get to the result. *Exceptional*, right?

Also, the [Perl][] version of the depth-first visit is a bit older and
less sophisticated, relying on `pre_action` and `post_action`. Luckily
for us these two suffice to do what we are after.

Here's the complete [Perl][] program, for the masoch**AHEM**curiuos:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Data::Dumper;

my $target = shift || 2;

{
   my $n2 = node(2, node(4, node(6, map {node($_)} (8, 9))));
   my $n3 = node(3, node(5, node(7)));
   my $root = node(1, $n2, $n3);
   local $Data::Dumper::Indent = 1;
   say Dumper($root);
   say depth($root, $target);
}


sub node ($l, @c) { return {label => $l, children => \@c} }

sub depth ($root, $label) {
   my $depth = 0;
   eval {
      depth_first_visit(
         start => $root,
         successors => sub ($n) { ($n->{children} // [])->@* },
         identifier => sub ($n) { $n->{label} },
         pre_action => sub ($n, $parent) {
            die 'done!' if $n->{label} eq $label;
            ++$depth;
         },
         post_action => sub { --$depth },
      );
      1;
   } or return $depth;
   return 'NaN';
}

sub depth_first_visit {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my @reqs = qw< start successors >;
   exists($args{$_}) || die "missing parameter '$_'" for @reqs;
   my ($start, $succs) = @args{@reqs};
   my $id_of = $args{identifier} || sub { return "$_[0]" };
   my $pre_action  = $args{pre_action} || undef;
   my $post_action = $args{post_action} || undef;
   my $skip_action = $args{skip_action} || undef;
   my %adjacents = ($id_of->($start) => [$succs->($start)]);
   my @stack = ([$start, undef]);
   $pre_action->($start, undef) if $pre_action;
   while (@stack) {
      my ($v, $pred) = @{$stack[-1]}; # "peek"
      my $vid = $id_of->($v);
      if (@{$adjacents{$vid}}) {
         my $w = shift @{$adjacents{$vid}};
         my $wid = $id_of->($w);
         if (exists $adjacents{$wid}) { # already visited
            $skip_action->($w, $v) if $skip_action;
         }
         else {                         # new node to be visited
            $adjacents{$wid} = [$succs->($w)];
            push @stack, [$w, $v];
            $pre_action->($w, $v) if $pre_action;
         }
      }
      else {
         $post_action->($v, $pred) if $post_action;
         pop @stack;
      } # finished with this frame
   }
   return unless defined wantarray; # don't bother with void context
   return keys %adjacents if wantarray;
   return [keys %adjacents] if defined wantarray;
}
```

# Conclusion

What to say? It's been a fun and instructive ride, with a couple of
pitfalls in the [Raku][] side and some dirty work in [Perl][]. They're
so much fun.

And now, after this long, boring tirade... have `-Ofun` and stay safe,
folks!


[The Weekly Challenge]: https://theweeklychallenge.org/
[#129]: https://theweeklychallenge.org/blog/perl-weekly-challenge-129/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-129/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Depth-First Algorithm Implementation]: https://github.com/polettix/cglib-raku/blob/main/DepthFirstVisit.rakumod
[Graph visit algorithms in cglib-raku]: https://github.polettix.it/ETOOBUSY/2021/07/06/raku-cglib-graph-visit/
[List]: https://docs.raku.org/type/List
[Block]: https://docs.raku.org/type/Block
