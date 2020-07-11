---
title: 'SVG path bounding box: merge multiple boxes'
type: post
tags: [ perl, svg, bounding box ]
comment: true
date: 2020-07-15 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Merging many bounding boxes together.

Also in this case, the code is straightforward:

```perl
 1 sub merged_bb ($first, @others) {
 2    my %retval = (min => {$first->{min}->%*}, max => {$first->{max}->%*});
 3    for my $bb (@others) {
 4       for my $axis (qw< x y >) {
 5          $retval{min}{$axis} = $bb->{min}{$axis}
 6             if $retval{min}{$axis} > $bb->{min}{$axis};
 7          $retval{max}{$axis} = $bb->{max}{$axis}
 8             if $retval{max}{$axis} < $bb->{max}{$axis};
 9       }
10    }
11    return \%retval;
12 }
```

In short, it suffices to take the minimum and maximux values for both
the `x` and the `y` axes and voilà, we have our overall merged bounding
box.

Stay tuned!
