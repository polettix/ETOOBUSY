---
title: SVG - embed images
type: post
tags: [ svg, perl, coding ]
comment: true
date: 2020-10-26 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> How to embed PNG or JPEG images in a SVG file. Hopefully.

In [origalea][], we take square images and put them in specific places
inside the page, rotated by 45°. I'll probably talk a bit more about
this in the future, although it's taken some time for me to figure out
and in hindsight I have to admit it's just not that interesting - or
hard to figure out. We will see.

One thing that I wanted to do, anyway, was to *embed* those images in
order to produce a self-consistent (and containing) file, ensuring
that it's the only thing I need to carry around. This, too, is not
rocket science, as there's a mechanism to do this: the [data URI
scheme][].

I'll leave to the [Wikipedia page][data URI scheme] the honor to expose
the details; for all practical reasons, the relevant pieces in
[origalea.tp][] (that is the template where the actual generation
happens, as of this post) are the following (`$die` is the file name of
the face to include at a certain iteration):

```
...
44	my $image = base64(slurp($die));
45	my $ct = $die =~ m{\. jpe?g \z}imxs ? 'image/jpeg' : 'image/png';
...
101	         <image
...
108	            xlink:href="data:[% $ct %];base64,[% $image %]"
109	            />
...
```

In a nutshell, we need to calculate two pieces of information:

- the *image data* as a [Base64][] string that encodes the whole image's
  binary data;
- the right *media type*, which we are assuming that can be either
  `image/jpeg` or `image/png` and we deduce from the filename.

[Teepee][teepee] already includes both `base64` and `slurp` as functions
that are readily available, so using them is a piece of cake.

Which reminds me that I'm in a diet and I *cannot* eat cake. Ouch.

[origalea]: {{ '/2020/10/25/origalea' | prepend: site.baseurl }}
[data URI scheme]: https://en.wikipedia.org/wiki/Data_URI_scheme
[origalea.tp]: https://gitlab.com/polettix/origalea/-/blob/83b3f25b2bf4a353a344dba743a1e1920c411900/origalea.tp
[Base64]: {{ '/2020/08/13/base64' | prepend: site.baseurl }}
[teepee]: https://github.polettix.it/teepee/
