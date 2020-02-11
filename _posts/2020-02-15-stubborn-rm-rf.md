---
title: Stubborn `rm -rf`
type: post
tags: [ perl ]
comment: true
date: 2020-02-15 08:00:00 +0100
preview: true
---

**TL;DR**

> A basic [Perl][] function to *really* remove a directory.

While looking at some code in [dibspack-basic][] I hit [the following
line][]:

```perl
stubborn_rm_rf($dst) if $dst->exists && ! PRESERVE;
```

I have to say... I think the line says what it does pretty well, and future
me congratulates with past me for writing it. I was intrigued though... why
name the function `stubborn_rm_rf`?!?

It turns out that sometimes permissions can get in the way when asking
[Perl][] to remove stuff. Which is a feature, not a bug! Alas, sometimes you
just want to get rid of the directory and everything it contains, so here
comes the stubborness.

The implementation is pretty basic:

```perl
sub stubborn_rm_rf {
   my $root = shift;
   $root->chmod('u+rwx');
   for my $child ($root->children) {
      if    (-l $child) { $child->remove }
      elsif (-d $child) { stubborn_rm_rf($child) }
      else {
         $child->chmod('u+rw');
         $child->remove;
      }
   }
   $root->remove_tree;
}
```

Reading it after some time, I was a bit surprised that I coded a recursive
function. I usually avoid them, but I guess that in this case I wasn't
anticipating too much of a drag.

Still, it's not entirely satisfactory and general (although, I have to
admit, it does its job perfectly in the context I coded it in the first
place). One thing is that it only accepts *directories*, and the other is
that it's recursive. Let's try to code something different then:

```perl
 1 sub stubborn_rm_rf {
 2    my @queue = @_; # multiple files accepted!
 3    while (@queue) {
 4       my $file = path(shift @queue);
 5       if    (-l $file) { $file->remove }
 6       elsif (-d $file) {
 7          $file->chmod('u+rwx'); # enable all for the user
 8          my $n = scalar @queue;
 9          push @queue, $file->children;
10          if ($n == scalar @queue) { $file->remove_tree }
11          else                     { push @queue, $file }
12       }
13       else {
14          $file->chmod('u+rw');
15          $file->remove;
16       }
17    }
18    return;
19 }
```

A classic way of transforming a recursion into an iteration is to
re-implement the stack mechanism. In this case we can do something simpler
and just keep a `@queue` of files that have to be deleted (independently of
their nature), stopping when there's nothing more to act upon.

We make sure that we work with a [Path::Tiny][] object (line 4) and then
basically replicate the old function, *except* for the directory part where
we are eliminating the recursion call.

When we hit a directory, we must first empty it, then remove it. So, in a
sense, we might have to *defer* an operation onto the directory until
everything inside has been removed. How to do this?

In line 8 we save how many items are in `@queue` - just the count of them,
in variable `$n`. After this, we add all children in `@queue`, scheduling
their removal.

Now there can be two cases:

- there were *no* children in the directory, which means that `@queue`
  remained the same after line 9, OR
- there were children and `@queue` grew a bit.

In the first case, we can safely get rid of the directory (it's empty, after
all!), in the second case we just re-add the directory to the queue, so that
it will be processed again in the future, but *after* all of its children
have been removed.

So... it should just work. 🙄


[Perl]: https://www.perl.org/
[dibspack-basic]: https://github.com/polettix/dibspack-basic
[the following line]: https://github.com/polettix/dibspack-basic/blob/master/install/with-dibsignore#L68
[Path::Tiny]: https://metacpan.org/pod/Path::Tiny
