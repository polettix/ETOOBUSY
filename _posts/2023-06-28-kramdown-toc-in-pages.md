---
title: kramdown Table of Contents in pages
type: post
tags: [ blog, jekyll ]
comment: true
date: 2023-06-28 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I hopefully restored the table of contents in wide-range pages.

In previous post [GitHub Pages failed me][] I ranted a bit about lack of
support for [jekyll-toc][] in GitHub Pages.

Anwyay, no fault on GitHub side: that's what is written on the can and they
stick to it. For security reasons, which is good.

Anyway, the table of content rendered like badly smelling stuff so I tried
to look for alternatives. It turns out that [kramdown][] already knows how
to generate a table of contents, so it was a matter of using it.

With a twist, though: I wanted to preserve my hardly crafted side navigation
bar, and it was not exactly *straighforward*.

To make a long story short, this is the page template:

{% raw %}
```
---
layout: default
---
<article class="post">
  <header class="post-header">
    <h1 class="post-title">{{ page.title }}</h1>
  </header>
  <div class="page-container">
     {{ content }}
  </div>
  {% include clipboard.html %}
</article>
```
{% endraw %}

I had to go back to a single {% raw %}`{{ content }}`{% endraw %} thingie,
which means moving the two-divs structure inside the page.

*Each* page must then have the following structure inside:

{% raw %}
```
<div class="page-nav">

{:toc}
* this is the toc

</div>
<div class="post-content" id="content">

Yadda yadda yadda

</div>
```
{% endraw %}

The last bit is to tell the [kramdown][] processor to indeed consider some
HTML blocks for expansion:

```
markdown: kramdown
kramdown:
   parse_block_html: true
```

And with this, I guess that's all folks!


[GitHub Pages failed me]: {{ '/2023/06/27/github-pages-failed-me/' | prepend: site.baseurl }}
[kramdown]: https://kramdown.gettalong.org/
