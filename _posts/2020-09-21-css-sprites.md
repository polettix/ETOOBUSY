---
title: CSS Sprites
type: post
tags: [ css, web ]
comment: true
date: 2020-09-21 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Playing a little with CSS Sprites

I've often been intrigued with how to cram many images into a single one
and then consume it from a web page, snipping just the right portion
from it. It seems that it consumes less resources, and I also find it
easier to manage a lot of images. Let's see.

I found an interesting web page about it: [CSS Sprites: ...][].

Let's see an example, which is based mainly on CSS with a bit of HTML.

The CSS is the following:

```css
<style>
    .sprite-plain, .sprite-ebook, .sprite-punk {
        background-image: url('all-owls.png');
        background-repeat: no-repeat;
        display: inline-block;
    }
    .sprite-plain {
        height: 391px;
        width: 400px;
        background-position: 0 -366px;
    }

    .sprite-ebook {
        height: 366px;
        width: 400px;
        background-position: 0 0;
    }

    .sprite-punk {
        height: 400px;
        width: 389px;
        background-position: 0 -757px;
    }
</style>
```

The image can be found here: [all-owls.png][].

Then, when we want to use one image, we can just include an element with
that specific class. You might use a `div` or a `span` (this latter with
the addition of the `iblock` class to make the image actually visible),
like this:

```html
<div class="sprite-plain"></div>
<div>Somewhere else... <span class="iblock sprite-punk"></span>
happened!</div>
```

Here's how it goes:

<style>
    .iblock { display: inline-block }
    .sprite-plain, .sprite-ebook, .sprite-punk {
        background-image: url('{{'/assets/images/all-owls.png' | prepend: site.baseurl }}');
        background-repeat: no-repeat;
    }
    .sprite-plain {
        height: 391px;
        width: 400px;
        background-position: 0 -366px;
    }

    .sprite-ebook {
        height: 366px;
        width: 400px;
        background-position: 0 0;
    }

    .sprite-punk {
        height: 400px;
        width: 389px;
        background-position: 0 -757px;
    }

    .smaller {
        height: 400px;
        transform: scale(0.5);
        transform-origin: top left;
    }

    .container {
        border: 1px solid gray;
    }
</style>
<div class="container">
<div class="smaller">
<div class="sprite-plain"></div>
<div>Somewhere else... <span class="iblock sprite-punk"></span>
happened!</div>
</div>
</div>

And I guess this is all!

[CSS Sprites: ...]: https://css-tricks.com/css-sprites/
[all-owls.png]: {{'/assets/images/all-owls.png' | prepend: site.baseurl }}
