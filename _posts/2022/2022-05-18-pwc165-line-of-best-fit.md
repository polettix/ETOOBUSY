---
title: PWC165 - Line of Best Fit
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-05-18 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#165][].
> Enjoy!

# The challenge

> When you have a scatter plot of points, a **line of best fit** is the
> line that best describes the relationship between the points, and is
> very useful in statistics. Otherwise known as linear regression, here
> is an example of what such a line might look like:

![Hull]({{ '/assets/images/pwc-165-2.svg' | prepend: site.baseurl }})

> The method most often used is known as the [least squares method][],
> as it is straightforward and efficient, but you may use any method
> that generates the correct result.
>
> Calculate the **line of best fit** for the following **48** points:
>
>     333,129  39,189 140,156 292,134 393,52  160,166 362,122  13,193
>     341,104 320,113 109,177 203,152 343,100 225,110  23,186 282,102
>     284,98  205,133 297,114 292,126 339,112 327,79  253,136  61,169
>     128,176 346,72  316,103 124,162  65,181 159,137 212,116 337,86
>     215,136 153,137 390,104 100,180  76,188  77,181  69,195  92,186
>     275,96  250,147  34,174 213,134 186,129 189,154 361,82  363,89
>
> Using your rudimentary graphing engine from **Task #1**, graph all
> points, as well as the line of best fit.

# The questions

Should we beware of ill-conditioning in the problem? I guess not because
the points are given and they seem "OK".

Is there a preferred size for the final image?

# The solution

It's not *that* hard to derive the formula for the linear regression
according to the minimization of the least square error in the dependent
variable.

Our model is a line of $y$ versus $x$:

$$y = mx + q$$

We aim at minimizing the following quantity:

$$S(m, q) = \sum_{i=1}^N (y - y_i)^2 = \sum_{i=1}^N (mx_i + q - y_i)^2$$

Partial derivatives versus $m$ and $q$:

$$ \frac{\partial S}{\partial m}= \sum_{i=1}^N 2x_i(mx_i + q - y_i) = 2(\sum_{i=1}^N x_i^2)m + 2(\sum_{i=1}^N x_i) q - 2\sum_{i=1}^N x_i y_i$$

$$ \frac{\partial S}{\partial q} = \sum_{i=1}^N 2(mx_i + q - y_i) = 2(\sum_{i=1}^N x_i)m + 2nq - 2\sum_{i=1}^N y_i$$

Let's define a few quantities:

$$X_2 = \sum_{i=1}^N x_i^2$$

$$X = \sum_{i=1}^N x_i$$

$$Y = \sum_{i=1}^N y_i$$

$$P = \sum_{i=1}^N x_i y_i$$

Setting the derivatives to 0 gives us:

$$X_2 m + Xq = P$$

$$Xm + Nq = Y$$

Solving this system of equations gives us:

$$(NX_2 - X^2)m = NP-XY \Rightarrow m = \frac{NP - XY}{NX_2 - X^2}$$

$$(X^2 - NX_2)q = XP  - X_2Y \Rightarrow q = \frac{X_2 Y - XP}{NX_2 - X^2}$$


Now it's a *simple matter of programming*. Note that variable $P$ above
is called `$XY` in function `lse`:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

my @points = map {[split m{\D+}]} grep { /\S/ } split m{\s+}mxs, '
   333,129  39,189 140,156 292,134 393,52  160,166 362,122  13,193
   341,104 320,113 109,177 203,152 343,100 225,110  23,186 282,102
   284,98  205,133 297,114 292,126 339,112 327,79  253,136  61,169
   128,176 346,72  316,103 124,162  65,181 159,137 212,116 337,86
   215,136 153,137 390,104 100,180  76,188  77,181  69,195  92,186
   275,96  250,147  34,174 213,134 186,129 189,154 361,82  363,89
   ';
my ($m, $q) = lse(@points);

my $xmin = my $xmax = $points[0][0];
for my $p (@points) {
   my ($x, $y) = $p->@*;
   if    ($x < $xmin) { $xmin = $x }
   elsif ($x > $xmax) { $xmax = $x }
   say "$x,$y";
}
my ($ymin, $ymax) = map { $m * $_ + $q } ($xmin, $xmax);
say "$xmin,$ymin,$xmax,$ymax";

sub lse (@points) {
   my ($N, $X, $Y, $X2, $XY) = (scalar(@points), (0) x 4);
   for my $p (@points) {
      my ($x, $y) = $p->@*;
      $X += $x;
      $Y += $y;
      $X2 += $x * $x;
      $XY += $x * $y;
   }
   my $den = $N * $X2 - $X * $X;
   my $m = ($N * $XY - $X * $Y) / $den;
   my $q = ($X2 * $Y - $X * $XY) / $den;
   return ($m, $q);
}
```

We can have pretty much the same in [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   my @points = '
      333,129  39,189 140,156 292,134 393,52  160,166 362,122  13,193
      341,104 320,113 109,177 203,152 343,100 225,110  23,186 282,102
      284,98  205,133 297,114 292,126 339,112 327,79  253,136  61,169
      128,176 346,72  316,103 124,162  65,181 159,137 212,116 337,86
      215,136 153,137 390,104 100,180  76,188  77,181  69,195  92,186
      275,96  250,147  34,174 213,134 186,129 189,154 361,82  363,89
      '.comb(/\S+/).map({.split(/\,/).Array});
   my ($m, $q) = lse(@points);
   my $xmin = my $xmax = @points[0][0];
   for @points -> ($x, $y) {
      if $x < $xmin { $xmin = $x } elsif $x > $xmax { $xmax = $x }
      put "$x,$y";
   }
   my ($ymin, $ymax) = ($xmin, $xmax).map: {$m * $_ + $q};
   put "$xmin,$ymin,$xmax,$ymax";
}

sub lse (@points) {
   my $N = @points.elems;
   my ($X, $Y, $X2, $XY) = 0 xx 4;
   for @points -> ($x, $y) {
      $X += $x;
      $Y += $y;
      $X2 += $x * $x;
      $XY += $x * $y;
   }
   my $den = $N * $X2 - $X * $X;
   my $m = ($N * $XY - $X * $Y) / $den;
   my $q = ($X2 * $Y - $X * $XY) / $den;
   return $m, $q;
}
```

With a slight change in the solution to challenge 1 for accepting the
definition as a parameter and a few other changes here and there, we
obtain the following picture:

![Hull]({{ '/assets/images/pwc-165-polettix.svg' | prepend: site.baseurl }})

Stay safe and minimize the square of your errors!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#165]: https://theweeklychallenge.org/blog/perl-weekly-challenge-165/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-165/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[least squares method]: https://www.mathsisfun.com/data/least-squares-regression.html
