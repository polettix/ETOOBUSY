---
title: Raku - default member values, again
type: post
tags: [ rakulang ]
comment: true
date: 2021-07-02 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some additional thoughts on setting default values for member
> variables (well... **attributes**!) in [Raku][].

In previous post [Raku - default member values][] I wrote about a few
ways to set the defaults for member variables, or **attributes**, as
they are called in [Raku][]. This is what I came up with:

```raku
class DefaultedMember {
   has $!member;
   has $!other-member;
   has &!callback;
   has @!items;
   submethod BUILD (
      :$!member = 'whatever',
      :&!callback = { '[' ~ $^a ~ ']' },
      :$!other-member,
      :@some-items,
   ) {
      $!member = 'fixed-prefix-' ~ $!member if $!member ~~ /hello/;
      $!other-member //= 'hey!';
      @!items = $!member;
      self.add-to-items(@some-items);
   }
   method add-to-items (*@new-items) {
      @!items.push: @new-items.Slip;
   }
   method talk {
      put &!callback($!member), ' ', $!other-member, ' ', @!items.gist;
   }
}
```

It turns out that There Is More Than One Way To Do It. *Of course*.

It also turns out that a detailed explanation of this topic happens to
have been written in the documentation: [Object construction][].

I eventually found out why `BUILD` should be a `submethod`: it does
stuff that is very specific for this class and it will be called anyway
even for subclasses, so you want that each subclass gets its own or none
at all, without inheriting the wrong `BUILD` from a parent.

Somewhere else, it's also suggested to use `TWEAK` for the
initialization, although I'm still not totally convinced of the
advantages and find it `WEAK`er. Well, terrible pun.

The rationale seems to be that `BUILD` is called first, then the default
values specified in the attribute *declaration* are applied, then
`TWEAK` is called. As such, `TWEAK` gets the attributes initialized with
either an externally-provided value, or the default one in the
declaration.

I'm not sure I buy this argument, though, because there's an easy
solution to this (use default values in the `BUILD` signature, as
explained in the last post *and* in [Object construction][]) that has
the added value to enable *binding* the attributes to the signature
itself, making it possible to also set *private attributes* from the
constructor. I don't know.

All in all, anyway, I'm happy that I found the right documentation to
read for this!

[Raku]: https://raku.org/
[Raku - default member values]: {{ '/2021/06/25/raku-default-member-values' | prepend: site.baseurl }} 
[Object construction]: https://docs.raku.org/language/objects#Object_construction
