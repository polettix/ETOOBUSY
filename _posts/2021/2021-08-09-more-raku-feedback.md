---
title: More (welcome although embarrassing) feedback
type: post
tags: [ rakulang ]
comment: true
date: 2021-08-09 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some more feedback on my [Raku][] dabbling, yay!

There seems to be an emergent phenomenon where I try to write some
meaningful [Raku][] code and [gfldex][] helps me find out more. And this
happened again!

After [Think Bayes in Raku - Pmf class][], there came [They returned an
empty package][].

I blushed about two times -- my [Raku][]-fu isn't strong enough to spot
*additional* shortcomings that are surely there!.

First, `normalize`'s return value is totally inconsistent:

```raku
method normalize (Numeric:D $sum = 1) {
  my $total = self.total or return;
  my $factor = $sum / $total;
  %!pmf.values »*=» $factor;
  self;
}
```

Actually, returning `self` at the end of the method was an attempt to
enable *chaining* method calls, so that I could e.g. do something like
this:

```raku
put $pmf.multiply(this => 1).multiply(that => 2).normalize.P('this');
```

So that `self` was added afterwards, and *of course* I forgot about the
`or return`, which should be `or return self`.

> On another note, I don't even know why I omitted the `return` in the
> last statement, I usually include it. Whatever, that was *really* an
> afterthought.

The other way I blushed is in *keeping* the `normalize` method in the
first place. Again, as a second thought I decided that I would do
normalization *on the fly* within method `P` itself:

```raku
method P ($key) {
   die "no key '$key' in PMF" unless %!pmf{$key}:exists;
   return %!pmf{$key} / self.total;
}
```

This *of course* made both `normalize` not needed any more **and** some
check on `self.total` needed to avoid the division-by-zero. Meh.

The `multi method` solution is neat, although I'm not sure whether this
makes the whole thing more readable or not. My strong [Perl][] accent
would probably phrase it as this:

```raku
method P ($key) {
   die "no key '$key' in PMF" unless %!pmf{$key}:exists;
   my $T = self.total or die 'invalid PMF (no data)';
   return %!pmf{$key} / $T;
}
```

Now I'm scared of reading through the rest of the code... better stop
here for now!

[Think Bayes in Raku - Pmf class]: {{ '/2021/08/06/tbr-class-pmf/' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[gfldex]: https://gfldex.wordpress.com/
[They returned an empty package]: https://gfldex.wordpress.com/2021/08/07/they-returned-an-empty-package/
