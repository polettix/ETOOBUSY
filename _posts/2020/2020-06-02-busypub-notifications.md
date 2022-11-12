---
title: Notifications for busypub
type: post
tags: [ jekyll, github, blog, dokku, mastodon, twitter, perl, coding ]
comment: true
date: 2020-06-02 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where [busypub][] gets automatic notification capabilities.

In [ETOOBUSY automated publishing][] we met [busypub][], a little
[Perl][] program to automate publishing blog posts that were writte
beforehand.

It just happens that every time I publish a new post here, I also
announce it in [Mastodon][] and [Twitter][].

So, it should not come as a surprise that the following posts (namely,
[Post status on Mastodon][], its follow-up [Post status on Mastodon -
with Mojo::UserAgent][], and its counterpart [Post status on Twitter][])
looked into posting status updates on these two *microblogging*
platforms.

So there you have it: as of [commit 53b31bd][], [busypub][] got
notification capabilities. As it's meant to be used in [Dokku][], the
configuration is passed through the environment, in particular it
relies upon `RECIPIENTS` and `LAST_URI`.

The first - `RECIPIENTS` - is a JSON-encoded array of hashes that allow
passing configurations specific to the two platforms, like this:

```JSON
[
  {
    "type": "mastodon",
    "uri": "https://octodon.social/api/v1/statuses",
    "token": "yadda-yadda-yadda",
    "visibility": "public"
  },
  {
    "type": "twitter",
    "api_key": "yadda",
    "api_secret_key": "yadda-yadda",
    "access_token": "yadda-yadda-yadda",
    "access_token_secret": "yadda-yadda-yadda-yadda"
  }
]
```

The second - `LAST_URI` - is the URI of where the announcement can be
found. This is an example of what it expects to find at some location in
the blog:

```text
2020-05-30
Post status on Mastodon https://github.polettix.it/ETOOBUSY/2020/05/30/mastodon-post-status/ #mastodon #octodon #perl #coding
```

Initial and final spaces in the *whole string* are trimmed away
automatically.




[ETOOBUSY automated publishing]: {{ '/2020/05/29/busypub'| prepend: site.baseurl }}
[busypub]: https://github.com/polettix/busypub
[Perl]: https://www.perl.org/
[Post status on Mastodon]: {{ '/2020/05/30/mastodon-post-status' | prepend: site.baseurl }}
[Post status on Mastodon - with Mojo::UserAgent]: {{ '/2020/05/31/mastodon-post-status-mojo' | prepend: site.baseurl }}
[Post status on Twitter]: {{ '/2020/06/01/twitter-post-status' | prepend: site.baseurl }}
[Mastodon]: https://mastodon.social/
[Twitter]: https://twitter.com/
[commit 53b31bd]: https://github.com/polettix/busypub/commit/53b31bd912ecc3d9ebc9dcbc51e267684ba9512e
[busypub]: https://github.com/polettix/busypub
[Dokku]: http://dokku.viewdocs.io/dokku/
