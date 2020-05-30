---
title: "Generating busypub's LAST_URI"
type: post
tags: [ blog, jekyll ]
comment: true
date: 2020-06-03 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where we see how to generate [busypub][]'s `LAST_URI` file.

In previous post [Notifications for busypub][] we saw that [busypub][]
got notification capabilities. Yay!

The *status* to send to the microblogging sites, though, does not come
out of thin air. We are glad to let [Jekyll][] generate it for us, by
means of the following little template that we will call `latest.txt`:

{% raw %}
```text
---
layout: null
---
{% for post in site.posts limit:1 %}
{{ post.date | date: "%Y-%m-%d"}}
{{ post.title }} {{ post.url | prepend: site.baseurl | prepend: site.url }}{% if post.tags.size > 0 %}{% for post_tag in post.tags %} #{{ post_tag | slugify | replace: "-", "_" }}{% endfor %}{% endif %}
{% endfor %}
```
{% endraw %}

An example can be found in this very blog: [latest.txt][].

The iteration is just a trick to alias variable `post` to the first item
in the array `site.posts` - in fact, it comes with `limit:1`. Maybe
there's a better way, my [Liquid][]-fu is weak (but effective!).

The generated file has an empty line at the beginning, maybe because of
the loop line itself. This is why in [busypub][] the file's content is
*trimmed* before the proper parsing (see [line 178] and following):

```perl
(my $body = $res->body) =~ s{\A\s+|\s+\z}{}gmxs;
my ($date, $status) = split m{\n}mxs, $body, 2;
```

I guess it's enough for today!

[ETOOBUSY automated publishing]: {{ '/2020/05/29/busypub'| prepend: site.baseurl }}
[Notifications for busypub]: {{ '/2020/06/02/busypub-notifications'| prepend: site.baseurl }}
[busypub]: https://github.com/polettix/busypub
[Jekyll]: https://jekyllrb.com/
[latest.txt]: {{ '/latest.txt' | prepend: site.baseurl }}
[Liquid]: https://shopify.github.io/liquid/
[line 178]: https://github.com/polettix/busypub/blob/53b31bd912ecc3d9ebc9dcbc51e267684ba9512e/busypub#L178
