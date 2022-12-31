---
title: 'AoC 2022/21 - When Wolfram Alpha failed me...'
type: post
tags: [ advent of code, coding, rakulang, algorithm ]
comment: true
date: 2022-12-31 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [Advent of Code][] [puzzle 21][puzzle] from [2022][aoc2022]:
> I came up with a simple equation but...

After day 19, that took me so long, this day's puzzle was pretty
straightforward. I guess it's a matter of knowing how to do things
beforehand.

Both parts largely require us to evaluate/manipulate arithmetic
expressions comprised of sums/subtractions/multiplications/divisions
(integer ones, as it happened in my case at least); the second part
twist is that one of the operations has to be considered an equal sign,
one of the inputs is an unknown variable and the whole thing is an
equation that we have to solve for the unknown.

I guess it *might* sound difficult, but if we think about it, we lucky
folks are teached how to do these operations (and their inverse) in the
first years of our education, so it's no big deal to translate these
rules.

First we have to read the inputs, though. Each line is an expression,
which consists either in a value or an operation; it makes sense to
parse the lines as such so here we go:

```raku
for $filename.IO.lines -> $expression {
    my $match = $expression ~~ m{^
        $<target>=(\w+) \:\s+ $<op1>=(\w+)
        [ \s+ $<op>=(\S) \s+ $<op2>=(\w+) ]?
    $};

    my $nv = nv($match<target>);
    if $match<op> {
        $nv.init(nv($match<op1>), $match<op>, nv($match<op2>));
    }
    else {
        $nv.init($match<op1>.Int);
    }
}
```

As we will deal with expressions, it makes sense (to me) to represent
each operation in an expression, or a single value, as a `Node`, and
keep track of all nodes (this is the `nv()` function used above):

```raku

class Node {
   has $.name;
   has $.value = Nil;
   has $.left  = Nil;
   has $.right = Nil;
   has $.op    = Nil;

   multi method init ($value) { $!value = $value }
   multi method init ($left, Str() $op, $right) {
      $!left  = $left;
      $!right = $right;
      $!op    = $op;
   }
   ...
}

...

sub nv (Str() $name) { # keep track of all nodes
    state %node-for;
    return %node-for{$name} //= Node.new(name => $name);
}
```

As it happens, the inputs *are* simple, in the sense that what we have
out of the inputs is a *tree* instead of a more generic *graph*. In
other terms, each four-letters placeholder only appears once on the left
and at most once on the right across all expressions; this simplifies
things a lot for part 2.

Anyway, part 1 is about evaluating the whole thing, with `root` at
the... *root* or our evaluation tree. Many people went the `eval` route,
which is fair in these challenges; I opted for a more canonical and
boring solution, involving doing the maths step by step. I guess there
was a quick shortcut do express this in [Raku][] but... I don't know it.

```raku
class Node {
   ...

   method simplified {
      return $!value if defined $!value;
      my $left  = $!left.simplified;
      my $right = $!right.simplified;
      return "($left $.op $right)" unless $left ~~ Int && $right ~~ Int;
      return $!op eq '+' ?? $left  +  $right
          !! $!op eq '-' ?? $left  -  $right
          !! $!op eq '*' ?? $left  *  $right
          !! $!op eq '/' ?? $left div $right
          !! die("unknown op $.op");
   }

   ...
}
```

If the node is a simple value, just return it. Otherwise, do the
simplification of the expression on both sides, and apply the
operation. As anticipated, I went for integer arithmetics and it was
fine for my inputs.

The twist in part 2 is that the meaning of two items change:

- the operation in the `root` node is an equal sign actually, turning
  the whole thing into an equation instead of a simple expression;
- the value in the `humn` node should be disregarded and we have to find
  out the right one to make the whole equation hold.

I initially thought of *printing* the equation and throwing it to
[Wolfram Alpha][]. But... I hit (like many others) the wall of the
maximum input lenght, so I was back to square zero. Ouch!

The fact that the equation is represented by a *tree* comes to the
rescue here. My approach is to *simplify* the equation until I have the
unknown alone on one side, and a value on the other; with a tree, I have
that the unknown is *only* on one side at each step (even though "not
alone"), while the other side is always a simple number. Something like
this:

$$
f_i(x) = K
$$

Now, `f_i(x)` is by itself an arithmetic expression that involves basic
operations upon our unknown `humn`/$x$ variable, so we can *invert* it
and obtain a new equation that has the same shape. As an example, let's
consider we have this at step $i$ of our simplification:

$$
f_i(x) = A + f_{i+1}(x)
$$

This means:

$$
A + f_{i+1} = k \Rightarrow f_{i+1} = K - A
$$

A couple examples more, also keeping in mind that subtraction and
division are *not commutative*:

$$
A * f_{i+1}(x) = K \Rightarrow f_{i+1}(x) = K / A \\
f_{i+1}(x) / A = K \Rightarrow f_{i+1}(x) = K * A \\
A / f_{i+1}(x) = K \Rightarrow f_{i+1}(x) = A / K
$$

In our tree, then, we will have *almost* always three terms that we are
interested into:

- the side with a simple value, i.e. $K$
- the side with an operation, which has two operands $A$ and
  $f_{i+1}(x)$

We have to take care of the order of the operands in the operation, but
it's really no big deal as we have to take into account only a few
possibilities. Here's the final product:

```raku
class Node {
   ...

   method set-as-unknown { $!value = 'x' }

   method !expr-value {
      my $rv = $!right.simplified;
      return ($!left, $rv) if $rv ~~ Int;
      return ($!right, $!left.simplified);
   }

   method solve-as-equal {
      my ($expr, $value) = self!expr-value;

      while $expr.simplified ne 'x' {
         my $op = $expr.op;
         if $op ~~ m{ <[ + * ]> } { # commutative
            my ($se, $sv) = $expr!expr-value;
            $expr = $se;
            $value = $op eq '+' ?? $value - $sv !! $value div $sv;
         }
         elsif $op ~~ m{ <[ / - ]> } {  # non-commutative
            my ($l, $r) = $expr.left, $expr.right;
            if $l.simplified ~~ Int {  # K <op> f(x) = V --> f(x) = K <op> V
               $expr = $r;
               $value = $op eq '-' ?? $l.simplified - $value
                  !! $l.simplified div $value;
            }
            else { # f(x) <op> K = V --> f(x) = V <inv-op> K
               $expr = $l;
               $value = $op eq '-' ?? $value + $r.simplified
                  !! $value * $r.simplified;
            }
         }
         else { die "unknown op $op" }
      }

      return $value;
   }

   ...
}
```

The `set-as-unknown()` method allows us to set node `humn` a our unknown
variable; then `solve-as-equal()` does the whole job of taking different
alternatives into consideration and applying the transformation that
eventually lead us to `x = K_n`, that is our solution.

To account for the modification in the `root` node, this method is
called onto that specific node; additionally, at each step we make sure
that `$expr` contains the expression with the unknown, and `$value` is
our $K$ from the discussion above.

With this said... have fun and stay safe!


[puzzle]: https://adventofcode.com/2022/day/X
[aoc2022]: https://adventofcode.com/2022/
[Advent of Code]: https://adventofcode.com/
[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[Wolfram Alpha]: https://www.wolframalpha.com/
