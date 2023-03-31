---
title: PWC210 - Number Collision
type: post
tags: [ the weekly challenge, Perl, RakuLang ]
comment: true
date: 2023-03-31 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#210][].
> Enjoy!

# The challenge

> You are given an array of integers which can move in right direction if it
> is positive and left direction when negative. If two numbers collide then
> the smaller one will explode. And if both are same then they both explode.
> We take the absolute value in consideration when comparing.
>
> All numbers move at the same speed, therefore any 2 numbers moving in the
> same direction will never collide.
>
> Write a script to find out who survives the collision.
>
> **Example 1:**
>
>     Input: @list = (2, 3, -1)
>     Output: (2, 3)
>
>     The numbers 3 and -1 collide and -1 explodes in the end. So we are left with (2, 3).
>
> **Example 2:**
>
>     Input: @list = (3, 2, -4)
>     Output: (-4)
>
>     The numbers 2 and -4 collide and 2 explodes in the end. That gives us (3, -4).
>     Now the numbers 3 and -4 collide and 3 explodes. Finally we are left with -4.
>
> **Example 3:**
>
>     Input: @list = (1, -1)
>     Output: ()
>
>     The numbers 1 and -1 both collide and explode. Nothing left in the end.

# The questions

With the disclaimer that I never did an interview as a programmer or to a
programmer, I think this challenge would make a fantastic interview
question.

There are the usual suspect: anything more about the domain, e.g. upper and
lower limits? Any hint about the typical sizes for the input lists? Should
the output list be provided with just the surviving integers, or should it
also preserve the order of these survivors to be the same as they initially
appear?

The real gold nugget, though, is what happens to 0. One might opine that the
input integers are explicitly said to be able to move, which seems to
exclude 0; I still think that it's good to iron this out.

In lack of this, we might assume that it was just a willing miss by the
interviewer, to see our reaction and how we decide to address it. As an
example, if 0 is indeed allowed (which we can assume, just as a
diversion/extension of the challenge):

- does it move or does it stand still? Let's assume that it stands still
- what happens if it gets a collision from *both* left and right?

Admittedly, the answer to the last question is not really necessary for the
purposes of the challenge. I would say that the step should resolve with a
three-numbers collision where one or zero integers survive, but the
challenge is about what happens in the long run so it does not really care
if the two integers on the two sides of a 0 fight immediately or in the
later step.

# The solution

I'm eager to see how enlightened minds like [E. Choroba][] or Prof.
[W. Luis Mochán][] (out of the pack of many) solve this in $O(1)$. Well,
most probably $O(n)$ or $O(n \cdot log(n))$.
Honestly, I couldn't think anything better than a $O(n^2)$ solution which
simulates round after round until everything settles down.

Each simulation step does this:

- take apart the "surely safe" items from the list. These are negative items
  appearing on the left side, or positive items appearing on the right side;
  they are safe because they are not going to have any collision.
- if there are still "potentially unsafe" items, run a step of movement upon
  them. If nothing changes we're done, otherwise we resolve collisions and
  do another iteration.

The collision resolution approach that I took is... sub-optimal. It analyzes
what happens to each integer individually, hence each collision is always
evaluated twice (one for each participating integer). It's simple and it
works... I'd like to keep it like this for a change.

[Perl][]:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

my @nc = number_collision(@ARGV);
{ local $" = ', '; say "(@nc)" }

sub number_collision (@list) {
   my (@pre, @post); # safe items on the left and on the right

   while ('necessary') {
      push @pre,     shift @list while @list && $list[0] < 0;
      unshift @post, pop @list   while @list && $list[-1] > 0;
      last if scalar(@list) == 0;

      my @mid;
      INDEX:
      for my $i (0 .. $#list) {
         my $item = $list[$i];
         if ($item > 0) { # try to move right
            push @mid, $item if $item + $list[$i + 1] > 0;
         }
         elsif ($item < 0) { # try to move left
            push @mid, $item if $item + $list[$i - 1] < 0;
         }
         else { # try to stay put
            my $safe_left  = ($i == 0) || ($list[$i - 1] <= 0);
            my $safe_right = ($i == $#list) || ($list[$i + 1] >= 0);
            push @mid, 0 if $safe_left && $safe_right;
         }
      }

      # stop simulation if nothing changed in this pass
      last if scalar(@list) == scalar(@mid);

      # go to next iteration with surviving items in the middle
      @list = @mid;
   }

   return (@pre, @list, @post)
}
```

[Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (*@args) { put '(', number-collision(@args).join(', '), ')' }

sub number-collision (@list is copy) {
   my (@pre, @post); # safe items on the left and on the right

   loop {
      @pre.push:     @list.shift while @list && @list[0] < 0;
      @post.unshift: @list.pop   while @list && @list[*-1] > 0;
      last if @list == 0;

      my @mid;
      INDEX:
      for ^@list -> $i {
         my $item = @list[$i];
         if $item > 0 { # try to move right
            @mid.push: $item if $item + @list[$i + 1] > 0;
         }
         elsif $item < 0 { # try to move left
            @mid.push: $item if $item + @list[$i - 1] < 0;
         }
         else { # try to stay put
            my $safe-left  = ($i == 0) || (@list[$i - 1] <= 0);
            my $safe-right = ($i == @list.end) || (@list[$i + 1] >= 0);
            @mid.push: 0 if $safe-left && $safe-right;
         }
      }

      # stop simulation if nothing changed in this pass
      last if @list.elems == @mid.elems;

      # go to next iteration with surviving items in the middle
      @list = @mid;
   }

   return (@pre, @list, @post).flat.Array;
}
```

Stay safe and avoid collisions!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#210]: https://theweeklychallenge.org/blog/perl-weekly-challenge-210/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-210/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
[W. Luis Mochán]: https://github.com/wlmb
[E. Choroba]: https://github.com/choroba
