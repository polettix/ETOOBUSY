---
title: Jekyll blog on GitHub Pages
layout: post
tags: [ jekyll, github, blog ]
comment: true
date: 2019-09-29 12:08:18 +0200
---

This very blog *runs* with [Jekyll][] on [GitHub Pages][ghp]. It does
not require installations in your PC (or *your* PC at all, anyway) and
can be completely managed through [GitHub][]. If you're interested, see
the [ABOUT][etoobusy-about] page for directions.

A few additional notes follow.


## Front Matter

The posts will *mostly* be in [Markdown][], although you must put a
little YAML preamble to set a few metadata, like this:

{% highlight YAML %}
---
title: Jekyll blog on GitHub Pages
layout: post
tags: [ jekyll, github, blog ]
comment: true
date: 2019-09-29 12:08:18 +0200
---
{% endhighlight %}

As a bare minimum, put `title` and `type` (the latter set to `post` like
the example).

## Ordering Posts

The index page already includes listing all available posts, in some
*reversed* order (i.e. backwards from the most recent) based on the
*date*.

Fact is... multiple posts on the same date might not get in the order
you think or would prefer. There is [a simple solution][date-order] this
this, i.e.  just add a `date` field in the [front matter][#front-matter].

{% highlight YAML %}
---
title: yadda yadda yadda
layout: post
date: 2019-09-29 12:08:18 +0200
---
{% endhighlight %}

## Comments with Disqus

Activating comments with [Disqus][] is straightforward:

- create a new discussion site in [Disqus][], e.g. named `whatever`
- set the name of this new site in `_config.yml`:

{% highlight YAML %}
# ...

disqus_shortname: whatever

# ...
{% endhighlight %}


[etoobusy-about]: https://github.polettix.it/ETOOBUSY/about
[GitHub]: https://github.com/
[Jekyll]: https://jekyllrb.com/
[ghp]: https://pages.github.com/
[Markdown]: https://en.wikipedia.org/wiki/Markdown
[date-order]: https://groups.google.com/forum/#!topic/jekyll-rb/8QCIzevauSU
[front-matter]: https://jekyllrb.com/docs/front-matter/
[Disqus]: https://disqus.com/
