---
title: Iterator-based implementation of Permutations
type: post
tags: [ algorithm, coding, cglib, perl ]
comment: true
date: 2021-01-30 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> An *iterator-based* implementation of [Permutations with Heap's
> Algorithm][]. You saw it coming.

As *implicitly* promised, we will leverage our *iterative
implementation* to get an *iterator-based* implementation.

# Starting from the iterative implementation

This is where we left in [Permutations with Heap's Algorithm][]:

```perl
sub permutations {
   my @indexes = 0 .. $#_;
   my @stack = (0) x @indexes;
   output(@_[@indexes]);
   my $sp = 0;
   while ($sp < @indexes) {
      if ($stack[$sp] < $sp) {
         my $other = $sp % 2 ? $stack[$sp] : 0;
         @indexes[$sp, $other] = @indexes[$other, $sp];
         output(@_[@indexes]);
         $stack[$sp]++;
         $sp = 0;
      }
      else {
         $stack[$sp++] = 0;
      }
   }
}
```

We will turn this into an iterator-based implementation, which means
that we will have a function that returns *another* function, that will
provide us a new permutation each time it is called, until they have
been all emitted.

One little thorn in the side is the fact that `output` is called in two
different places, one over the very first arrangement, then during the
loop. This forces us to treat the "initial state" as something special,
i.e. skip all computations for the first call to the sub and then
consider the stuff in the `while` loop from the second call on.

Another observation that comes to our help is that the placement of the
call to `output` *inside* the loop can be moved a little ahead, like
this:

```perl
sub permutations {
   my @indexes = 0 .. $#_;
   my @stack = (0) x @indexes;
   output(@_[@indexes]);
   my $sp = 0;
   while ($sp < @indexes) {
      if ($stack[$sp] < $sp) {
         my $other = $sp % 2 ? $stack[$sp] : 0;
         @indexes[$sp, $other] = @indexes[$other, $sp];
         $stack[$sp]++;
         $sp = 0;
         output(@_[@indexes]);
      }
      else {
         $stack[$sp++] = 0;
      }
   }
}
```

In this way, it becomes the *last* statement in its branch of the `if`
condition, which will come handy later.


# Turning into an iterator

The generic structure of our *iterator factory* function is the
following:

```perl
sub iterator_creation_factory_function {

    # declaration and initialization of state-tracking variables

    return sub { # this is the actual iterator

        # move the state on to the next step

        # return the proper value for the current state

    };
}
```

In our iterative implementation, variables `@indexes`, `@stack`, `$sp`,
and `@_` too are all part of the *state*, hence they need to be declared
outside the iterator, so that they will be *closed* by the iterator
function.

Additionally, we have to take care of the `@_` variable here, because we
cannot "see" the `@_` of the factory *inside* the itertor (because the
iterator is a function with *its own* `@_`). Hence, we'll change the
interface to take a reference to an array in parameters passed as either
hash or hash reference:

```perl
sub permutations_iterator {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my $items = $args{items} || die "invalid or missing parameter 'items'";
   my $filter = $args{filter} || sub { wantarray ? @_ : [@_] };
   my @indexes = 0 .. $#$items;
   my @stack = (0) x @indexes;
   my $sp = undef;
   return sub { ... }
}
```

While we're at it, we also support a `filter` function that will be
passed the permutation as input, and whose output will be returned by
our iterator.

Note that we explicitly set `$sp` to start as `undef`. This will let us
distinguish the *very first call* from the other ones, as we saw that we
need to do this. Hence, in our first call we will just set `$sp` to the
*real* initialization value, and skip everything the `while` would
normally do:

```perl
sub permutations_iterator {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my $items = $args{items} || die "invalid or missing parameter 'items'";
   my $filter = $args{filter} || sub { wantarray ? @_ : [@_] };
   my @indexes = 0 .. $#$items;
   my @stack = (0) x @indexes;
   my $sp = undef;
   return sub {
      if (! defined $sp) { $sp = 0 }
      else { ... }
      return $filter->(@{$items}[@indexes]) if $sp < @indexes;
      return;
   }
}
```

As anticipated, the iterator will return the output of calling the
`$filter` function over the current arrangement of the data, or
*nothing* if we got past the last permutation.

We can now take a look at what's executed from the second iterator call
on, that is our adaptation of the `while` loop in the original iterative
implementation. The key here is that we have to enter the loop, but only
execute as much work as to get to the right state for generating the
needed output and then exit the loop:

```perl
sub permutations_iterator {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my $items = $args{items} || die "invalid or missing parameter 'items'";
   my $filter = $args{filter} || sub { wantarray ? @_ : [@_] };
   my @indexes = 0 .. $#$items;
   my @stack = (0) x @indexes;
   my $sp = undef;
   return sub {
      if (! defined $sp) { $sp = 0 }
      else {
         while ($sp < @indexes) {
            if ($stack[$sp] < $sp) {
               my $other = $sp % 2 ? $stack[$sp] : 0;
               @indexes[$sp, $other] = @indexes[$other, $sp];
               $stack[$sp]++;
               $sp = 0;
               last;
            }
            else {
               $stack[$sp++] = 0;
            }
         }
      }
      return $filter->(@{$items}[@indexes]) if $sp < @indexes;
      return;
   }
}
```

It's now clear *why* it was so useful to move the call to `output` to
be the *last* statement in the block... in this way we can substitute it
with a literal `last` and exit the loop exactly when we need to provide
an output.

Thanks to the *closure* mechanism, the next time the iterator is called,
it will enter the `while` loop just as if it never exited it...
allowing us to reach the following state, then the next one, etc. until
the last one.

# Let's put it to work

A little example of using our iterator-based implementation:

```perl
my $it = permutations_iterator(
    items => [ qw< howdy you all > ],
    filter => sub { join ' ', @_ },
);
while (my $message = $it->()) { say $message }
```

Now... let's run it:

```
howdy you all
you howdy all
all howdy you
howdy all you
you all howdy
all you howdy
```

It works! The good thing is that we can stop when we want, e.g. consider
the following arrangement that will cease to look for new permutations
as soon as we reach a lexicographically ordered one:

```perl
my @items = qw< howdy you all >;
my $sorted = join ',', sort { $a cmp $b } @items;
my $it = permutations_iterator(
    items => \@items,
    filter => sub {
        my $candidate = join ',', @_;
        say $candidate;
        return 1 unless $candidate eq $sorted;
        say "---> found, stopping here";
        return 0;
    }
);
1 while $it->();
```

When we run it, we can appreciate the fact that we don't have to go
through all permutations:

```
howdy,you,all
you,howdy,all
all,howdy,you
---> found, stopping here
```

# The inevitable ending...

... is that this function ended up in [cglib][], inside
[Permutations.pm][] 😄

Stay safe!

[Permutations with Heap's Algorithm]: {{ '/2021/01/29/permutations-algorithm/' | prepend: site.baseurl }}
[cglib]: https://github.com/polettix/cglib-perl/
[Permutations.pm]: https://github.com/polettix/cglib-perl/blob/master/Permutations.pm
