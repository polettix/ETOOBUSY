---
title: 'Readonly::Tiny'
type: post
tags: [ perl, coding ]
comment: true
date: 2021-04-09 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Readonly::Tiny][] is better than [constant][].

> **UPDATE 2021-10-04** it was long time due to fix the big issue with
> this post! Now it does what it was meant to do.

I rarely use constants, mainly because I like those constants to be...
variables that are possibly read from a file. But yes, those variables might
have default values and these would probably be... *constants*.

The *canonical* way to declare a constant value in [Perl][] is this:

```perl
use constant SOME_VALUE => 42;
```

This actually creates a sub like this:

```perl
sub SOME_VALUE() { 42 }
```

Being created at compile time (it's done with a `use` for a reason) and
having an empty prototype means that it can be called without parentheses,
so this:

```perl
my $value = shift // SOME_VALUE;
```

does what you think.

But this interface is... not optimal. For example, you cannot use this value
in interpolated stuff; as an example, these two lines print different
things:

```perl
print 'default value is ', SOME_VALUE, "\n";
print "default value is SOME_VALUE\n"
```

and this does not expand the value in the constant either, at least on the
left of the *fat comma*:

```perl
my %doubles = (SOME_VALUE => SOME_VALUE * 2);
```

There are a couple workarounds for this:

```perl
# SOME_VALUE is a function after all, let's call it as such
my %doubles = (SOME_VALUE()  => SOME_VALUE * 2);

# force evaluation as a string
my %triples = (SOME_VALUE.'' => SOME_VALUE * 3);
```

But they are... *workarounds*, and they don't work inside double-quoted
strings anyway.

The solution to this would be to use a full-fledged *scalar*, **but**
scalars are *variables*, not *constants*.

Well... not so fast! Scalars *can* be constants... and [Readonly::Tiny][]
can help us craft them as such:

```perl
use Readonly::Tiny 'Readonly';
Readonly my $SOME_VALUE => 42;
```

Now things will work as expected:

```perl
print "default value is $SOME_VALUE\n";
my %doubles = ($SOME_VALUE => $SOME_VALUE * 2);

# the following statement will die with error message:
#   Modification of a read-only value attempted...
$SOME_VALUE = 37;
```

Last, if you don't like using the *fat-comma* to do what amounts to an
assignment (another itch I always had with `use constant`), it's
possible to use function `readonly` instead, taking care to pass a
*reference* to the variable we want to make read-only:

```perl
use Readonly; # function `readonly` is exported by default, yay!
readonly \(my $SOME_VALUE = 42);
```

So... if you are in need for a scalar constant, keep [Readonly::Tiny][] in
mind!

[Readonly::Tiny]: https://metacpan.org/pod/Readonly::Tiny
[constant]: https://metacpan.org/pod/constant
[Perl]: https://www.perl.org/
