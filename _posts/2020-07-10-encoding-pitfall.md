---
title: Encoding pitfall
type: post
tags: [ encoding, utf8, mojolicious ]
comment: true
date: 2020-07-10 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I had a problem with toots and tweets encoding, the net helped solve
> it with [How to make Mojolicious deal with UTF-8?][]

When previous post [Bézier curves][] (note the `LATIN SMALL LETTER E
WITH ACUTE`) was automatically published by [busypub][], the
[Notifications for busypub][] kicked in but something went wrong with
the published messages and I got `BÃ©zier` instead.

How 2000-ish!

[How to make Mojolicious deal with UTF-8?][] got me on the right track:

> As such, `$res->body` is bytes, `$res->text` is text decoded from
> encoding specified in response.

This prompted me to do [this change][]:

```diff
    my $res = Mojo::UserAgent->new(max_redirect => 5)->get($uri)->result;
    die "error getting ($uri): " . $res->message
      unless $res->is_success;
-   (my $body = $res->body) =~ s{\A\s+|\s+\z}{}gmxs;
+   (my $body = $res->text) =~ s{\A\s+|\s+\z}{}gmxs;
    my ($date, $status) = split m{\n}mxs, $body, 2;
    return {
       date   => $date,
```

i.e. switching from considering the notification I was fetchign with
[Mojo::UserAgent][] as sequence of bytes and start considering it...
text made of characters.

And [it worked][]:

![toot with bézier written right]({{ '/assets/images/bézier-written-right.png' | prepend: site.baseurl }})

Time and again, [Mojolicious][] and the [Mojo][] framework prove to be
just... right and amazing.

[Mojo]: https://metacpan.org/pod/Mojo
[Mojo::UserAgent]: https://metacpan.org/pod/Mojo::UserAgent
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[How to make Mojolicious deal with UTF-8?]: https://stackoverflow.com/a/49347378/334931
[Bézier curves]: {{ '/2020/07/06/bezier-curves' | prepend: site.baseurl }}
[busypub]: https://github.com/polettix/busypub
[Notifications for busypub]: {{ '/2020/06/02/busypub-notifications' | prepend: site.baseurl }}
[this change]: https://github.com/polettix/busypub/commit/399d9962b494d2124d35064a8b48e36fddb960ca
[it worked]: https://octodon.social/@polettix/104480255099564847
