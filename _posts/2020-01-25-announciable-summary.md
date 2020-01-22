---
title: Announceable Summary for Posts
type: post
tags: [ jekyll, github, blog, octodon, twitter ]
comment: true
date: 2020-01-25 08:00:00 +0100
preview: true
---

**TL;DR**

> This blog's structure evolved to also include generation of a post's
> summary that can be copy-pasted on microblogging sites.

I already wrote about this very blog's scaffolding in [Jekyll blog on GitHub
Pages][blog-jekyll-ghp] and later in [Preview for Jekyll blog on GitHub
Pages][blog-jekyll-ghp-preview].

One thing I've been doing over and over is manually generating a *summary*
that's then used to announce a new post on [Octodon][] and [Twitter][]. It's
usually the *title*, the *URL* and the *tags*.

So I figured... why not make [Jekyll][] do that for me? Please meet the new
*preview page*:

{% raw %}
```html
 1 ---
 2 layout: default
 3 ---
 4 <div class="home">
 5    {% include nav.html %}
 6    <section>
 7       <ul class="post-list">
 8          {% for post in site.posts %}
 9          <li>
10             [<time datetime="{{ post.date | date_to_xmlschema }}"></time>{{ post.date | date: "%Y-%m-%d" }}]
11             <a href="{{ post.url | prepend: site.baseurl | prepend: site.url }}">{{ post.title }}</a>
12 <p class="announceable">{{ post.title }} {{ post.url | prepend: site.baseurl | prepend: site.url }}{% if post.tags.size > 0 %}{% for post_tag in post.tags %} #{{ post_tag | slugify | replace: "-", "_" }}{% endfor %}{% endif %}</p>
13          </li>
14          {% endfor %}
15       </ul>
16    </section>
17 </div>
```
{% endraw %}

The new *stuff* is in line 12: an added paragraph with the summary as
describe before. The styling is simple, in `main.scss`:

```css
.announceable {
  font-size: $small-font-size;
  font-family: $base-font-family;
  color: $grey-color;
  text-indent: 0;
  border-left: 1px solid $grey-color;
  margin-left: 3em;
  padding-left: 0.5em;
}
```

An example rendering is the following:

![Announceable summary examples]({{ '/assets/images/2020-01-announceable-preview.png' | prepend: site.baseurl | prepend: site.url }})

Cheers!

[blog-jekyll-ghp]: {{ '/2019/09/29/jekyll-ghp' | prepend: site.baseurl | prepend: site.url }}
[blog-jekyll-ghp-preview]: {{ '/2020/01/13/jekyll-ghp-preview' | prepend: site.baseurl | prepend: site.url }}
[Octodon]: https://octodon.social/
[Twitter]: https://twitter.com/
[Jekyll]: https://jekyllrb.com/
