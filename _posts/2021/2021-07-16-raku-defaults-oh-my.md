---
title: Raku - default member values... oh my!
type: post
tags: [ rakulang ]
comment: true
date: 2021-07-16 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Reddit answered][], and it's full of juice!

So here we are again! Not happy with my first stab ([Raku - default
member values][]), I discovered the documentation for initializing
objects ([Raku - default member values, again][]).

So we're done, right?

Well... not so fast folks! [Reddit answered][], at it's very, very
interesting.

User [codesections][] points out that there's yet another arrow to
shoot, i.e. [trait is built][]:

> By default, this trait allows setting up a private attribute during
> object construction via `.new`.

As I understand, it solves the problem of making it possible to
initialize private variables upon instantiation (tieing same-named
parameters). This, paired with the *default on the spot*, gives us a
clean and clear way to do the initialization in the simple cases.

Adapting the example in the docs a bit:

```raku
class Foo {
    has $!bar is built = 'default';
    method bar { $!bar; }
}
put Foo.new.bar;                  # «default␤» 
put Foo.new(bar => 'custom').bar; # «custom␤» 
```

Reddit user [b2gills][] goes beyond by gently adapting the example in
previous posts to make use of `is built` and also suggest how to do
post-initialization customizations. [The answer][] is a highly suggested
read and... spoiler: it's `TWEAK`.

The good thing is that the initialization of attributes from defaults
and constructor inputs are now decoupled from these customizations, so
we don't have to specify them explicitly any more, which is much less
error prone and future proof as [b2gills][] rightly observes.

Hence, the following works as expected and no repetition/explicit
initialization is necessary:

```raku
class Foo {
    has $!bar is built = 'default';
    submethod TWEAK () { $!bar = $!bar.uc if $!bar !~~ /^default/; }
    method bar { $!bar; }
}
put Foo.new.bar;                  # «default␤» 
put Foo.new(bar => 'custom').bar; # «CUSTOM␤» 
```

With all of this, I do agree with [b2gills][]'s summary:

> Writing `TWEAK` should be a rare occurrence.
>
> Writing `BUILD` should be doubly rare.

I guess I'll have to revise a few classes... it will be a useful
exercise to fix this in memory 😅

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Reddit answered]: https://www.reddit.com/r/rakulang/comments/oc6950/default_member_values_again_flavio_poletti/
[Raku - default member values]: {{ '/2021/06/25/raku-default-member-values' | prepend: site.baseurl }} 
[Raku - default member values, again]: {{ '/2021/07/02/raku-defaults-again/' | prepend: site.baseurl }}
[codesections]: https://www.reddit.com/user/codesections/
[b2gills]: https://www.reddit.com/user/b2gills/
[trait is built]: https://docs.raku.org/type/Attribute#index-entry-trait_is_built_(Attribute)-trait_is_built
[The answer]: https://www.reddit.com/r/rakulang/comments/oc6950/default_member_values_again_flavio_poletti/h4h7h6l?utm_source=share&utm_medium=web2x&context=3
