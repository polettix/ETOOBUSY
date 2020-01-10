---
title: Preview for Jekyll blog on GitHub Pages
type: post
tags: [ jekyll, github, blog ]
comment: true
date: 2020-01-13 08:00:00 +0100
preview: true
---

**TL;DR**

> Using [GitHub Pages][] on the server side only leaves you without a
> preview of your posts. Or does it?


We already touched upon [GitHub Pages][] in the previous blog post
[Jekyll blog on GitHub Pages][blog-jekyll-ghp]. I still think it's a sane
way to go, and I'm sticking to writing here.

There's a catch though: getting a preview of an article is not available
*out of the box*, especially if you're not willing to run [Jekyll][] locally
but only rely on [GitHub Pages][] to do the rendering. So, here we are.


## Generating previews with [GitHub Pages][]

The idea is simple:

- change the *index* page to *exclude* posts that have some specific
  characteristic, e.g. whenever they have field `preview` set to a true
  value;

- create another page like *index* with the listing of all posts, including
  those that are not included in *index* as a result of the previous bullet;

- mark draft posts with the exclusion characteristic.

Let's see an example.

### Excluding posts from listing

This is [ETOOBUSY's `index.html`][ETOOBUSY-index] as of this writing:

```
---
layout: default
---
 1 <div class="home">
 2    {% include nav.html %}
 3    <section>
 4       <ul class="post-list">
 5          {% for post in site.posts %}
 6             {% unless post.preview %}
 7          <li>
 8             [<time datetime="{{ post.date | date_to_xmlschema }}"></time>{{ post.date | date: "%Y-%m-%d" }}]
 9             <a href="{{ post.url | prepend: site.baseurl | prepend: site.url }}">{{ post.title }}</a>
10          </li>
11             {% endunless %}
12          {% endfor %}
13       </ul>
14    </section>
15 </div>
```

As you can see, lines 7-10 print out an item for a post, but only *unless*
the post has the `preview` characteristic set (line 6). This means that
posts with `preview` set to `true` are *not* shown here.

### Keeping a preview list

This is [ETOOBUSY's `preview.html`][ETOOBUSY-preview] as of this writing:

```
---
layout: default
---
 1 <div class="home">
 2    {% include nav.html %}
 3    <section>
 4       <ul class="post-list">
 5          {% for post in site.posts %}
 6          <li>
 7             [<time datetime="{{ post.date | date_to_xmlschema }}"></time>{{ post.date | date: "%Y-%m-%d" }}]
 8             <a href="{{ post.url | prepend: site.baseurl | prepend: site.url }}">{{ post.title }}</a>
 9          </li>
10          {% endfor %}
11       </ul>
12    </section>
13 </div>
```

This is what the *previous* version of `index.html` was, before the
exclusion of `preview` posts. Hence, the
[preview][ETOOBUSY-preview-rendered] page includes all posts, including the
draft ones. Yes! You can get a sneak peek!

### Mark posts as `preview`

The last thing to do is to mark a post as `preview` in its front matter,
like this example at line 7:

```
 1 ---
 2 title: Yadda Yadda!
 3 type: post
 4 tags: [ yadda ]
 5 comment: true
 6 date: 2020-01-10 08:00:00 +01:00
 7 preview: true
 8 ---
 9
10 Yadda yadda...
```

## This is it!

That's right, when you push the changes above, you will be able to get the
full listing in one page (`preview` in my case) and keep the *official*
index free of drafts.

Happy writing!


[GitHub Pages]: https://pages.github.com/
[blog-jekyll-ghp]: {{ '/2019/09/29/jekyll-ghp' | prepend: site.baseurl | prepend: site.url }}
[Jekyll]: https://jekyllrb.com/
[ETOOBUSY-index]: https://github.com/polettix/ETOOBUSY/blob/master/index.html
[ETOOBUSY-preview]: https://github.com/polettix/ETOOBUSY/blob/master/preview.html
[ETOOBUSY-gh]: https://github.com/polettix/ETOOBUSY
[ETOOBUSY-preview-rendered]: https://github.polettix.it/ETOOBUSY/preview/
