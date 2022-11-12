---
title: Tricked by each
type: post
tags: [ perl ]
comment: true
date: 2021-01-01 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> HAPPY NEW YEAR! Oh, by the way... beware of `each` in [Perl][].

I was trying to solve [day 10][] of [Advent of Code 2016][] and I
stumbled upon a weird bug in my code.

When I say *weird* I mean *weird* as quantum physics can be *weird*. I
know, that's *a lot* of *weirdness*. But... the funny bug that was
plagueing my code *disappeared* as I put additional *read-only*
statements to look into it. Just to come back, of course, as I removed
that investigation code.

It was amazing. And *weird*.

As a side note, I have to admit that leaving the printing statements
actually removed the bug *and* provided me a solution to that day's
puzzle. At this point, anyway, I had another puzzle... another big, fat,
juicy puzzle.

# Let's re-create something similar

Let's consider the following code:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

my %store = (
   a => { 1 => 1, 3 => 1 },
   b => { 2 => 1 },
   c => { 4 => 1 },
);
say $_, ' -> ', (get_key_for(\%store, $_) // '*none*') for 1 .. 4;

sub get_key_for ($store, $target_value) {
   while (my ($key, $values) = each $store->%*) {
      return $key if $values->{$target_value};
   }
   return;
}
```

The function `get_key_for` gets a hash of hashes as input, and returns
the *key* in the first hash corresponding to the sub-hash that contains
the target value.

The iteration with the `say` should print this:

```
1 -> a
2 -> b
3 -> a
4 -> c
```

right? Well... let's see a couple of runs:

```
$ perl each.pl 
1 -> a
2 -> *none*
3 -> a
4 -> *none*

$ perl each.pl 
1 -> a
2 -> b
3 -> *none*
4 -> c
```

It seems that we're doomed to miss something!

# OK, let's investigate...

Maybe there's something changing our hash of hashes behind the scenes,
let's print it then:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

my %store = (
   a => { 1 => 1, 3 => 1 },
   b => { 2 => 1 },
   c => { 4 => 1 },
);
for (1 .. 4) {
   print_hash(\%store);
   say $_, ' -> ', (get_key_for(\%store, $_) // '*none*');
}

sub get_key_for ($store, $target_value) {
   while (my ($key, $values) = each $store->%*) {
      return $key if $values->{$target_value};
   }
   return;
}

sub print_hash ($store) {
   for my $key (sort {$a cmp $b} keys $store->%*) {
      say '   ', $key, ' -> (', join(', ', keys $store->{$key}->%*), ')';
   }
}
```

Let's see...

```
$ perl each.pl 
   a -> (3, 1)
   b -> (2)
   c -> (4)
1 -> a
   a -> (3, 1)
   b -> (2)
   c -> (4)
2 -> b
   a -> (3, 1)
   b -> (2)
   c -> (4)
3 -> a
   a -> (3, 1)
   b -> (2)
   c -> (4)
4 -> c
```

This is what I found interesting: the output is now as we were
expecting, i.e. each value from 1 to 4 has a correponding key!

Let's comment the `print_hash` call...

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

my %store = (
   a => { 1 => 1, 3 => 1 },
   b => { 2 => 1 },
   c => { 4 => 1 },
);
for (1 .. 4) {
   #print_hash(\%store);
   say $_, ' -> ', (get_key_for(\%store, $_) // '*none*');
}

sub get_key_for ($store, $target_value) {
   while (my ($key, $values) = each $store->%*) {
      return $key if $values->{$target_value};
   }
   return;
}

sub print_hash ($store) {
   for my $key (sort {$a cmp $b} keys $store->%*) {
      say '   ', $key, ' -> (', join(', ', keys $store->{$key}->%*), ')';
   }
}
```

and back we are:

```$
perl each.pl 
1 -> a
2 -> *none*
3 -> a
4 -> *none*
```

# Then something struck me...

Looking at the code, my eye fell on the `each` statement. I read
something about it some time ago... something that always makes me a bit
uneasy in using it. Fact is that it's useful... so I'm not that happy to
give it up completely.

I don't remember where I ready about its dangers, or when, or what the
dangers are actually, but it rang a bell and it was the right one.

The simplest explanation that I have is that `each` keeps note of where
it was in the iteration, and restarts from there at the next one. Unless
it can't, e.g. because the *note* was destroyed or reset in some way.

Hence, when I just run `get_key_for`, depending on the random order of
the elements in the hash I can obtain two results:

- if `a` comes last, in the first run `each` skips `b` and `¢` for it
  and, at the next call (which is the one aiming at `b`), it will just
  reach the end of the hash, ignoring `b` and resetting the hash. Which
  means that, at the following iteration, we get `a` again, and again we
  skip `c`.

- if `a` comes first, then `a` and *at least* `b` are printed. The next
  `a` is not found, so the state is reset and `c` is found because the
  search has been reset.

There may be other cases, but these two above explain what we saw.

So... it's a *global, hidden variable* that gives us headaches!

# Why the different behaviour with `print_hash`?

When we call `print_hash`, we iterate through all the `keys` of the hash
of hashes. This resets the scanning with `each`, so we eventually get
every element because the `each` tracker is reset before each call to
`get_key_for`.

# Lessons learned?

The bottom line is... try to avoid `each` if possible.

The next, less drastic suggestion might be... if you want to use `each`,
make sure that you *really* go through `each` key/value pair,
otherwise... *use something else*!

# So long...

... AND A HAPPY NEW YEAR!!!

To read more about this "bug"... [Is perl's each function worth
using?][] contains some interesting considerations!

[Perl]: https://www.perl.org/
[day 10]: https://adventofcode.com/2016/day/10
[Advent of Code 2016]: https://adventofcode.com/2016/
[Is perl's each function worth using?]: https://stackoverflow.com/questions/2396511/is-perls-each-function-worth-using
