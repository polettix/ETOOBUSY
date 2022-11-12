---
title: Rational numbers in Perl
type: post
tags: [ perl, maths ]
comment: true
date: 2020-08-17 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> If you want to deal with rational numbers, [Perl][] has you covered.

Remember previous post [Be Rational][]? If you're convinced that
rational numbers are the right way to go for some problem, please
remember that [Perl][] has [Math::BigRat][] at your disposal:

```perl
use Math::BigRat;
 
my $x = Math::BigRat->new('3/7'); $x += '5/9';
 
print $x->bstr(), "\n";
print $x ** 2, "\n";
 
my $y = Math::BigRat->new('inf');
print "$y ", ($y->is_inf ? 'is' : 'is not'), " infinity\n";
```

So no... it was not a module for a big *rat* 🐀

[Be Rational]: {{ '/2020/08/16/be-rational' | prepend: site.baseurl }}
[Math::BigRat]: https://metacpan.org/pod/Math::BigRat
[Perl]: https://www.perl.org/
