---
title: Block syntax for Perl package definitions
type: post
tags: [ perl, rakulang ]
comment: true
date: 2023-02-26 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Figuring out a feature that's there since almost 12 years.

Often times I use iterators in [Perl][] to encapsulate an iterative
behaviour that might go on indefinitely, or that I'd like to consume one
item at a time (as opposed to exausting the whole iteration at once).
This is usually done with a *closure*, like this:

```perl
sub iterate_by2 ($n) {
    $n -= 2;
    return sub { return $n += 2 }
}
```

OK, OK, there's a lot to be desired regarding corner cases but you get
the idea.

I consistently found myself in a different state of mind while
translating these *things* in [Raku][]. I mean, they *might* be
translated almost by the letter, *but* I always felt that a class was
the way to go:

```raku
class IterateBy2 {
    has $!n;
    submethod TWEAK (:$n) { $!n = $n - 2 }
    method get()          { return $!n += 2 }
}
```

(I hope the code above works, I didn't test it).

This is also what happened in previous post [Portable(ish) Random(ish)
Number Generator][], which anyway left me with a bit of itch in the
[Perl][] implementation because I had *three* different behaviours
scattered over three different functions:

- the `seed_to_num` function to turn a string into an integer
- the actual iterator `randomish_uint32_it`
- the iterator transformer to get random bits `get_bit`.

The underlying reason why I have this different approach, *I think*,
lies in the lack of a native, *dedicated* syntax for declaring classed
and from the fact that I started dabbling seriously when 5.8 was out,
i.e. at a time where *a lot* of the new features were not around.

In time, I tended to *avoid* the features in the hope of preserving
compatibility with older versions, especially because often times I did
not know which `perl` I would have found at some location. So I only
adopted the defined-or `//` syntax (although not always) and, more
recently, the *signatures* by requiring that my stuff runs at least in
v5.24.

In this specific case, I was disregarding two facts:

- `package` definitions can be scoped to an enclosing BLOCK (something I
  figured out *consciently* only recently, with [A block... blocks][])

- since `perl` v5.14, released May 2011, we also have the `package NAME
  { ... }` syntax in our toolbox.

And yet, it's still somehow written in my mind that I have to change
`package` all along, which is the exact barrier that often times
prevents me from using the object-oriented approach.

So, without further ado, it's time to translate `Randomish` from
[Raku][] back to [Perl][], in true object-oriented glory:

```perl
package Randomish {
   sub new ($package, $seed = undef) {
      my $self = bless {}, $package;
      say "pre<$seed>";
      if (! defined($seed)) { $self->{s} = time() }
      elsif ($seed =~ m{\A(?: 0 | [1-9]\d* )\z}mxs) { $self->{s} = $seed }
      else {
         my $val = 0;
         $val = ($val << 8) | ord(substr($seed, $_))
            for 0 .. length($seed) - 1;
         $self->{s} = $val & 0xFFFFFFFF;
      }
      say "pos<$self->{s}>";
      return $self;
   }

   sub uint32 ($self) {
      $self->{s} = ($self->{s} * 1664525 + 1013904223) & 0xFFFFFFFF;
   }

   sub bit ($self) { $self->uint32 & 0x80000000 ? 1 : 0 }
}
```

Bad habits are hard to remove because they're hard to spot.

Stay safe!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[A block... blocks]: {{ '/2021/06/28/a-block-blocks/' | prepend: site.baseurl }}
[Portable(ish) Random(ish) Number Generator]: {{ '/2023/02/26/portable-random-ish/' | prepend: site.baseurl }}
