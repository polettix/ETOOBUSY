---
title: xmpl - visibility API
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-02-28 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> So you thought that the neverending series about [xmpl][] was over,
> didn't you?!? Yet another little facility...

The latest addition to [xmpl][] allows something that I would normally
**not** include in any code meant for production: a way to ask the
program to check the visibility of *other URLs*.

This is clearly a security issue, because the program might be exploited
to generate queries towards any destination, making us look bad for
this.

Again, this is something for experimenting and testing, so we can live
with this.

The new API endpoint is [here][new-api]:

```perl
   get '/visible' => sub ($c) {
      my @targets = split m{\n+}mxs, $c->param('targets');
      $c->render(json => check_visible(@targets));
   };
```

This accepts a single query parameter `targets`, which is supposed to
hold a newlines-separated list of URLs. To be more precise, it's also
possible to associated a name/title to each URL, so this will work:

```
this has a title = http://www.example.com/
http://www.example.com/not-existent
```

The first one will be referred to as `this has a title` (leading and
trailing spaces removed), while the second one will be called the same
as the URL itself.

The actual implementation of the splitting logic and following check of
target URLs is [here][new-check]:

```perl
   sub check_visible (@targets) {
      state $ua = Mojo::UserAgent->new(
         max_redirects   => 3, # allow some amount of redirection
         request_timeout => 2, # don't bother too much
      );
      return {
         map {
            my ($name, $url) = m{\A(?:([.\-\w\s]+) =\s*)? (.*)\z}mxs;
            $name //= '';
            $name =~ s{\A\s+|\s+\z}{}gmxs;
            $name = $url unless length $name;
            $name => ($ua->head($url)->res->is_success ? 1 : 0);
         } @targets
      };
   }
```

The [Mojo::UserAgent][] (remember [Mojo::UserAgent introductory
notes][]?) is kept as a `static` object and reused over and over; its
patience is limited to a maximum of 3 redirections and 2 seconds to get
a connection, so that we will not wait too much time for unreachable
targets.

The main part of the code inside the `map` takes care to extract the
(optional) name discussed above, defaulting to the URL if it ends up
being empty.

The last line inside `map`'s block is the actual check: we go for the
`HEAD` verb (to avoid too much data flying around) and check for
success, which is probably a bit restrictive (e.g. if we get a `Not
Found` back, the endpoint is still *visible*, right?) but as long as we
know it we should be fine.

The new API returns a JSON object where *keys* are the name/URLs, each
having an associated value that is either `0` (failure in visibility) or
`1` (resource was visible). For our example:

```
{"http:\/\/www.example.com\/not-existent":0,"this has a title":1}
```

> Yes! The mythical [example.com][] actually exists!

It will be up to you to ensure that the names are different 😅

At this point... I can only recommend you to stay safe!



[xmpl - an example web application]: {{ '/2020/02/05/xmpl/' | prepend: site.baseurl }}
[xmpl]: https://gitlab.com/polettix/xmpl
[code]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl
[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Kubernetes]: https://kubernetes.io/
[README.md]: https://gitlab.com/polettix/xmpl/-/blob/master/README.md
[series]: {{ '/series#xmpl' | prepend: site.baseurl }}
[xmpl - the key/value API]: {{ '/2021/02/06/xmpl-kv.api.md' | prepend: site.baseurl }}
[xmpl - in-memory key/value store]: {{ '/2021/02/07/xmpl-kv-memory.md' | prepend: site.baseurl }}
[xmpl - on-file key/value store]: {{ '/2021/02/07/xmpl-kv-file.md' | prepend: site.baseurl }}
[Mojo::File]: https://metacpan.org/pod/Mojo::File
[Mojo::UserAgent]: https://metacpan.org/pod/Mojo::UserAgent
[head to it]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl#L48
[new-api]: https://gitlab.com/polettix/xmpl/-/blob/v0.2.0/xmpl#L173
[new-check]: https://gitlab.com/polettix/xmpl/-/blob/v0.2.0/xmpl#L362
[Mojo::UserAgent introductory notes]: {{ '/2021/02/22/mojo-useragent-intro-notes/' | prepend: site.baseurl }}
[example.com]: http://www.example.com
