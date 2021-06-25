---
title: Raku - default member values
type: post
tags: [ raku ]
comment: true
date: 2021-06-25 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> An example of a [Raku][] class with default values for members.

This post is probably trivial for most, but I guess I'll come back
looking at it several times. Hi future Flavio!

I wanted to know how to handle default values for member variables in a
class. It turns out that it's managed the way I was expecting it - i.e.
using signatures to specify default values.

There's still some "cargo cult" I have regarding to when I have to use
`$!member` and when `$.member`, but I trust I'll get the hang of it.

Here's the example:

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

All member variables are private (declared with the `!` twigil). Our
goal is to make sure all of them have *the right value* when the object
is initialized.

For my purposes, the `BUILD` `method`/`submethod` proved sufficient. I
still don't know when I should use one or the other, but I hope I'll get
the hang of it shortly. Other alternatives, as I understand, are the
`TWEAK` `method`/`submethod` and a brand new `new` method, which is the
last resort for complex things (I guess).

The most straightforward way of providing a default value is to put it
directly in the signature for `BUILD`. My understanding is that naming
the variable in the signature the same as the member variable (and
prefixing it with `:`) makes `BUILD` initialize the member itself as we
expect. This happens *before* we enter the code block associated to
`BUILD`. Another way is to use the code block itself.

Let's see what happens for the different members:

- `$!member` is initialized from the signature, so entering the block it
  either has the value passed in from the invocant, or the default value
  `whatever`. It is further conditionally modified inside the block, so
  for example if the input value is the string `hello, world!`, its
  value becomes `prefix-hello, world!`.
- `&!callback` is initialized from the signature only, getting either
  the value passed by the invocant, or the default code block provided
  directly in the signature;
- `$!other-member` is initialized by the signature, getting either the
  value passed from the invocant, or an `Any` value (I guess). For this
  reason, we then initialize it inside the block in the case that the
  value is not defined. This shows that we can do complex initialization
  of a variable when its value is not passed in;
- `@!items` cannot be initialized through the signature, but its value
  is computed based on other member variables (`$!member` and
  `$!other-member`) as well as an additional, optional input parameter
  `@some-items`, which are set by invoking method `add-to-items`. This
  shows that:
  - it's possible to have a constructor signature that does not
    necessarily need to reflect the internal structure of the class,
    which is much appreciated;
  - it's possible to call other methods from `BUILD`, which is much
    appreciated as well!

Here's an example sequence of invocations, as well as their result:

```
DefaultedMember.new.talk;
# OUTPUT: ｢[whatever] hey! [whatever]␤｣


DefaultedMember.new(member => 'hello, world!').talk;
# OUTPUT: ｢[prefix-hello, world!] hey! [prefix-hello, world!]␤｣


DefaultedMember.new(
   member => 'hi there!',
   callback => { '«' ~ $^input ~ '»' },
).talk;
# OUTPUT: ｢«hi there!» hey! [hi there!]␤｣


DefaultedMember.new(
   member => 'hi there!',
   callback => { '«' ~ $^input ~ '»' },
   other-member => "I'm here too!",
).talk;
# OUTPUT: ｢«hi there!» I'm here too! [hi there!]␤｣


DefaultedMember.new(
   member => 'hi there!',
   callback => { '«' ~ $^input ~ '»' },
   other-member => "I'm here too!",
   some-items => < and here we go >,
).talk;
# OUTPUT: ｢«hi there!» I'm here too! [hi there! and here we go]␤｣
```


Now I'm left with a few doubts:

- should I declare `BUILD` as a `method` or as a `submethod`? I've seen
  both in several examples, and I'm not sure when I need either one;
- should I even use `BUILD` to do this, or should I use `TWEAK`?
- When do I need to completely override `new`? (I have an idea regarding
  this...)

If you made it so far, and know the answer, and have 5 minutes to
spare... ring a bell in the comments or by email to `flavio @t
polettix.it`!

[Raku]: https://raku.org/
