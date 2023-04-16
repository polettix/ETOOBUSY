---
title: No back button after logout
type: post
tags: [ web, security ]
comment: true
date: 2023-04-17 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Prevent the back button after logging out.

While playing with pages in a [Mojolicious][] application, which has some
parts only visible after logging in and other freely accessible, I realized
that I should have done something to block the usage of the *Back* button in
the browser after logging out.

I'm not the first one to think about it, of course, so [I found this][] and
added this to the code:

```perl
$app->hook(
   after_dispatch => sub ($c) {
      $c->res->headers->cache_control('no-store, must-revalidate')
         if $c->is_user_authenticated;
   },
);
```

I'm not going to fuss over all the different browsers, but in case the link
above has plenty of discussions.

Stay safe!

[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[I found this]: https://stackoverflow.com/questions/49547/how-do-we-control-web-page-caching-across-all-browsers/2068407#2068407
