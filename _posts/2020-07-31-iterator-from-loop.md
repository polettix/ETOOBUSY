---
title: Iterator from loop
type: post
tags: [ algorithm, perl ]
series: Algorithm::Loops
comment: true
date: 2020-07-31 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A way to turn an exaustive loop into an iterator.

In previous posts [A simplified recursive implementation of NestedLoops][] and 
[A simplified iterative implementation of NestedLoops][] we implemented
a way to get variable-depth loops. These functions accepted a *callback*
function that would be called at the heart of the nested loops,

Although effective, this means that we will always have to go through
every iteration at every level, which might be... not always what we are
after. Maybe we're looking for something... and we want to stop as soon
as we find it.

In these cases, *iterators* come handy because they provide a sort of
*inversion*: we ask the iterator for the next arrangement of inputs for
the function, it gives it to us and we use it. Whether to ask for
another one is completely up to us.

# A few considerations

To do this, our iterator will be an anonymous sub, because it's compact
and elegant 🤓. So, this is how we will be able to get and use it:

```perl
my $it = get_iterator(@arguments);
if (my @stuff = $it->()) {
    $callback->(@stuff);
}
```

So, our `get_iterator` will have this shape:

sub get_iterator {
    my @arguments = @_;
    return sub { ... };
}

i.e. it will return a reference to a sub.

What will this sub do? It will have to do what the loop does... but only
one step at a time, As soon as it has something that the original loop
would have fed to the callback, it has to return it back. Additionally,
though, it will have to keep track of where it left, so that the next
time it will be able to get the following. Let's see how.

# Closures

Consider the following code:

```perl
 1  sub get_some_sub {
 2      my $x = 0;
 3      return sub { ++$x };
 4  }
 5
 6  my $some_sub = get_some_sub();
 7  my $some_other_sub = get_some_sub();
```

The variable `$x` inside the *internal* anonymous sub (line 3) is the
same `$x` declared and initialized in line 2. This means that, as long
as `$some_sub` exists... that `$x` will have to exist too!

Another interesting thing is that the call in line 7 *creates* a
different pair of `$x` and of the anonymous sub in line 3. So,
`$some_other_sub` keeps its own copy of `$x` alive.

This goes under the name of... closures. Each specific `$x` allows the
anonymous sub to keep track of some specific and own state... which is
very interesting for our purposes!

# An example

Let's try an example, by iterating over a single array. The
callback-based version would be:

```perl
sub iterate_over_array {
    my ($input_array, $callback) = @_;
    my $i = 0;
    while ($i <= $#{$input_array}) {
        $callback($input_array->[$i++]);
    }
}
```

Let's turn this into an iterator, We will a *closed over* variable `$i`
to keep track of the state:

```perl
sub simple_iterator {
    my ($input_array) = @_;
    my $i = 0; # this will index into $input_array
    return sub {
        return unless $i <= $#{$input_array};
        return $input_array->[$i++];
    };
}
```
So... the trick is to understand what will enable us to go through all
the states of the loop, and store it as closed over variables. Easy!

[A simplified recursive implementation of NestedLoops]: {{ '/2020/07/28/nested-loops-recursive' | prepend: site.baseurl }}
[A simplified iterative implementation of NestedLoops]: {{ '/2020/07/29/nested-loops-iterative' | prepend: site.baseurl }}
