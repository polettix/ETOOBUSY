---
title: Deep clone of a data structure in Perl
type: post
tags: [ perl ]
comment: true
date: 2020-08-04 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Function `dclone` in module [Storable][] can be very helpful.

Sometimes you just need to produce a copy of a data structure, cutting
ties with the original. What do I mean?

Let's define some boilerplate:

```perl

#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use Scalar::Util qw< refaddr >;

my $original = {
    some_array => [ 1, 1, 2, 3, 5, 8 ],
    nested_array => [ ['a'..'l'], ['m'..'z']],
    hash_too => {
        foo => 'bar',
        baz => { hello => 'World!' }
    },
};

sub compare_references ($msg, $orig, $copy) {
   say $msg;
   my ($oa, $ca) = (refaddr($orig), refaddr($copy));
   say "  orig: <$oa>";
   say "  copy: <$ca>", ($oa == $ca ? ' (same)' : ' different');
}
```

In short, we have a complex, nested data structure in `$original` and we
want to *copy* it so that any change we do to the copy will not reflect
in the original.

Function `compare_references` helps us figure out whether two different
variables are pointing to the same references, which would also mean
that changes done through one of them would also be seen using the
second.

# Plain copy

Let's start simple:

```perl
{
   my $copy = $original;
   compare_references('plain copy', $original, $copy);
}
```

Running it:

```text
plain copy
  orig: <93871507775160>
  copy: <93871507775160> (same)
```

As expected, both `$original` and `$copy` point to the same underlying
array, so the copy is not independent.

# Shallow copy

Let's move on to copy all the stuff *inside* `$original`:

```perl
{
   my $copy = {$original->%*};
   compare_references('shallow copy', $original, $copy);
}
```

This is what we get:

```text
shallow copy
  orig: <93871507775160>
  copy: <93871506848512> different
```

It seems we got what we were aiming for, right? Not so fast, not so
fast.

Let's scratch the surface and see how `$original->{some_array}` relates
to `$copy->{some_array}`:

```perl
{
   my $copy = {$original->%*};
   compare_references('shallow copy, first level inside',
      $original->{some_array}, $copy->{some_array});
}
```

Running gives us:

```text
shallow copy, first level inside
  orig: <93871506603848>
  copy: <93871506603848> (same)
```

So, again, there are pieces of the two data structures that are common
and this would create some *interference* between the two. This is why
we are calling this a *shallow* copy: after you remove the external
layer... there's no difference inside.

Let's move on!

# Deep copy

At this point, we understand that we have to create a copy at all
possible levels of nesting in arrays and hashes. We could code something
for this... but the core module [Storable][] helps us with function
`dclone`:

```perl
{
   use Storable 'dclone';
   my $copy = dclone($original);
   compare_references('deep copy', $original, $copy);
   compare_references('deep copy, first level inside',
      $original->{some_array}, $copy->{some_array});
   compare_references('deep copy, second level inside',
      $original->{nested_array}[0], $copy->{nested_array}[0]);
}
```

The result is:

```text
deep copy
  orig: <93871507775160>
  copy: <93871506766800> different
deep copy, first level inside
  orig: <93871506603848>
  copy: <93871507775040> different
deep copy, second level inside
  orig: <93871506727416>
  copy: <93871507657192> different
```

Now we are doing the copy in the right way!


# Conclusions

If you need to do a total *deep* copy of a data structure in [Perl][],
look no further than `dclone` in [Storable][]. Well... unless you run
into some performance issue, of course!

If you want to take a look at the code for this example, you can find it
in the [local copy][].

Stay safe!

[Perl]: https://www.perl.org/
[Storable]: https://metacpan.org/pod/Storable
[local copy]: {{ '/assets/code/storable.pl' | prepend: site.baseurl }}
