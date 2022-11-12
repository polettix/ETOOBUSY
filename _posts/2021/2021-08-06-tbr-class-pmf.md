---
title: Think Bayes in Raku - Pmf class
type: post
tags: [ maths, probability, rakulang ]
comment: true
date: 2021-08-06 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A couple of initial classes in [Raku][] to help with following [Think
> Bayes][] with some [Raku][] code.

In [previous post Think Bayes][tbpost] we saw that there's a free book
available ([Think Bayes][]) with code in Python, which I'd like to
somehow follow using [Raku][].

Chapter 2 *Computational Statistics* introduces class `Pmf`; the first
examples can be followed with this basic implementation:

{% raw %}
```raku
class Pmf {
   has %.pmf;

   method TWEAK (:%!pmf) {}

   method gist () {
      return gather {
         take '---';
         for %!pmf.keys.sort -> $key {
            take "  «$key» {%!pmf{$key}}";
         }
      }.join("\n");
   }

   method total () { return [+] %!pmf.values }

   method normalize (Numeric:D $sum = 1) {
      my $total = self.total or return;
      my $factor = $sum / $total;
      %!pmf.values »*=» $factor;
      self;
   }

   method set ($key, $value) { %!pmf{$key} = $value; self }

   method increment ($key, $amount) {
      %!pmf{$key} += $amount;
      return self;
   }
   method multiply ($key, $factor) {
      %!pmf{$key} *= $factor;
      return self;
   }

   method probability ($key) { self.P($key) }
   method P ($key) {
      die "no key '$key' in PMF" unless %!pmf{$key}:exists;
      return %!pmf{$key} / self.total;
   }
}
```
{% endraw %}

As anticipated, the implementation is basic and functional to following
the examples. As an example, the `normalize` method is virtually not
needed because the normalization is always performed *on the fly* by the
`P` method.

We can re-create the *cookies* example from section 2.2:

```raku
my $cookie = Pmf.new(pmf => ('Bowl 1', 1, 'Bowl 2', 1).hash);
$cookie.multiply('Bowl 1', 3/4);
$cookie.multiply('Bowl 2', 1/2);
say 'probability it came from Bowl 1: ', $cookie.P('Bowl 1');
```

The initialization is done assigning the same value to the two
*hypotheses*, i.e. `Bowl 1` and `Bowl 2`. As long as they are the same,
it means that they have the same probability (because probabilities are
calculated by dividing by the total).

Then we do the *update* phase, where we multiply each of the prior
probabilities by the likelihood that the cookie came from each bowl. At
the end, we print out the upated estimation that the cookie indeed comes
from `Bowl 1`.

As it often happens, if you want to play with the code above, there is a
[local version here][] - enjoy and I hope it can be of help!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[tbpost]: {{ '/2021/08/03/think-bayes/' | prepend: site.baseurl }}
[Think Bayes]: https://greenteapress.com/thinkbayes/thinkbayes.pdf
[local version here]: {{ '/assets/code/tbr-pmf.rakumod' | prepend: site.baseurl }}
