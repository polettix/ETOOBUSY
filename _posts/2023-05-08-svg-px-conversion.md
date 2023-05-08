---
title: SVG px conversion in Perl
type: post
tags: [ svg, perl ]
comment: true
date: 2023-05-08 06:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Converting from `px` via [SVG::DOM][].

In [SVG viewBox and px][] we took a look at a way to convert from the
`px` inside a SVG file to the `pt` units, i.e. in $\frac{1}{72}$-ths of
an inch.

Assuming that we have a [SVG::DOM][] element of type (tag) `svg`, we can
use it to extract all relevant values:

```perl
sub parse_conversion ($el) {
   state $inch_to = {    # conversion table
      mm => 25.4,
      cm => 2.54,
      dm => 0.254,
      m  => 0.0254,
      in => 1,
      pt => 72
   };

   my ($x, $y, $S_W, $S_H) = split m{\s+}mxs,
     ($el->getAttribute('viewBox') =~ s{\A\s+|\s+\z}{}rgmxs);
   my ($W_U, $U) = $el->getAttribute('width') =~ m{
      \A\s*
         (.*?)
         ([a-zA-Z]+)
      \s*\z
   }mxs;
   my $C_U    = $inch_to->{$U} // die "cannot converto inches to $U\n";
   my $factor = (72 * $W_U) / ($C_U * $S_W);
   return {
      X_offset => $x,
      X_span   => $S_W,
      Y_offset => $y,
      Y_span   => $S_H,
      factor   => $factor,
   };
} ## end sub parse_conversion
```

We are assuming that there the `px` is the same along both axes; I
*think* this is a good assumption in practical cases, and that
[InkScape][] enforces this too.

The calculated `$factor` allows turning `px` into `pt`, so it's put as
the *inverse* of what we calculated in [SVG viewBox and px][]. Makes
sense, right?

Stay safe!


[Perl]: https://www.perl.org/
[SVG::DOM]: https://metacpan.org/pod/SVG::DOM
[SVG viewBox and px]: {{ '/2023/05/07/svg-viewbox-px/' | prepend: site.baseurl }}
[InkScape]: https://www.inkscape.org/
