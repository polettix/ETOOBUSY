---
title: Think Bayes in Raku - Suite class, take 2
type: post
tags: [ maths, probabilities, rakulang ]
comment: true
date: 2021-08-14 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Of course there had to be a follow-up on the `Suite` class.

In previous post [Think Bayes in Raku - Pmf class, take 2][previous] we
saw an evolution of the `Pmf` class to support multiplication of a `Pmf`
object by a hash of key/values, representing the *likelihood` of each
key.

So I decided that `Suite' had to evolve too:

```raku
class Suite is Pmf {
   has &!likelihood is required;
   submethod BUILD (:lh(:&!likelihood)) { }
   method update ($data) { return self.multiply(&!likelihood($data)) }
}
```

This is it. Now `&!likelihood` is supposed to be called with `$data`
only, and it takes care to calculate the likelihood across all possible
keys.

Thanks to the simplification, this implementation is simpler too, and
also closer to how the data are used.

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[previous]: {{ '/2021/08/13/tbr-class-pmf-2/' | prepend: site.baseurl }}
