---
title: A card layout
type: post
tags: [ svg, board game ]
series: Playing Cards with SVG
comment: true
date: 2020-08-23 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Just for fun, I've been thinking about a generic layout for playing
> cards.

And here it is:

![]({{ '/assets/images/card-layout.svg' | prepend: site.baseurl }})

[Download it here][].

The available slots are those with different colors. so that the card
can be rotated upside-down and keep the same *face* to the player.

Units can vary in the two $X$ and $Y$ dimensions, allowing for different
card aspect-ratios. So the $1$ may be of different actual lenghts in the
two dimensions.

The choice of $K$ allows adjusting to one's preferences. The picture
shows $K = 5$.

[Download it here]: {{ '/assets/images/card-layout.svg' | prepend: site.baseurl }}
