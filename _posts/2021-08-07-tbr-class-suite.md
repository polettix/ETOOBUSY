---
title: Think Bayes in Raku - Suite class
type: post
tags: [ maths, probabilities, rakulang ]
comment: true
date: 2021-08-07 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Adding a [Raku][] class for `Suite`.

After post [Think Bayes in Raku - Pmf class][] we can move on to
implement something to help us with the examples using the `Suite`
class:

```raku
class Suite is Pmf {
   has &!likelihood is required;
   submethod BUILD (:lh(:&!likelihood)) { }

   method update ($data) {
      for self.pmf.keys -> $hypothesis {
         my $lh = &!likelihood($data, $hypothesis);
         self.multiply($hypothesis, $lh);
      }
      return self.normalize;
   }
}
```

As in the original in Python, it extends class `Pmf` adding capabilities
to handle likelihood and update.

I decided to *explore* a bit the idea of providing the likelihood as a
callback function saved as an attribute instead of forcing users to
sub-class `Suite`, like in the Python case. It just seems more...
*perlish*, you know. (For my idea of *perlish*, of course).

Let's re-create the *cookies* example:

```raku
my %mix-for = (
   'Bowl 1' => { vanilla => 3/4, chocolate => 1/4 },
   'Bowl 2' => { vanilla => 2/4, chocolate => 2/4 },
);
my $cookie = Suite.new(
   pmf => hash('Bowl 1', 1, 'Bowl 2', 1),
   lh  => -> $D, $H { %mix-for{$H}{$D} },
);
$cookie.update('vanilla');
$cookie.P('Bowl 1').put;
```

> **Hard-learned lesson**: the `lh` parameter I'm passing is **NOT** a
> sub reference **but** a code block. This means that **I cannot use
> `return` inside it**.

Another example... the *dice* one:

```raku
my $dice = Suite.new(
   pmf => hash(4 => 1, 6 => 1, 8 => 1, 12 => 1, 20 => 1),
   lh => sub ($D, $H) { $D <= $H ?? (1 / +$H) !! 0 },
);
$dice.update(6).say;
```

If you want to play with the code, there is a [local version here][].

Have fun and stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Think Bayes in Raku - Pmf class]: {{ '/2021/08/06/tbr-class-pmf/' | prepend: site.baseurl }}
