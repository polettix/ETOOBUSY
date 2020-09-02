---
title: Fixing an example in Mojolicious
type: post
tags: [ mojolicious, perl, web ]
comment: true
date: 2020-09-04 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Another drop in the open source sea.

I think many of us have the same feeling: our (software) contribution to
the world is just a drop in an sea.

Instead of being discouraged, though, I feel reassured: there's a lot to
do, and even minor fixes can help improve things (e.g. by letting the
next person to avoid spending 5 minutes to figure out why an error
popped out). Also, there's a lot of people doing this.

It happened to me while reading the [Cookbook guide][] for
[Mojolicious][], in particular the section about the *Eventsource web
service* which has the following example:

```perl
use Mojolicious::Lite -signatures;

# Template with browser-side code
get '/' => 'index';

# EventSource for log messages
get '/events' => sub ($c) {

  # Increase inactivity timeout for connection a bit
  $c->inactivity_timeout(300);

  # Change content type and finalize response headers
  $c->res->headers->content_type('text/event-stream');
  $c->write;

  # Subscribe to "message" event and forward "log" events to browser
  my $cb = $c->app->log->on(message => sub ($log, $level, @lines) {
    $c->write("event:log\ndata: [$level] @lines\n\n");
  });

  # Unsubscribe from "message" event again once we are done
  $c->on(finish => sub ($c, $code, $reason = undef) {
    $c->app->log->unsubscribe(message => $cb);
  });
};

app->start;
__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
  <head><title>LiveLog</title></head>
  <body>
    <script>
      var events = new EventSource('<%= url_for 'events' %>');

      // Subscribe to "log" event
      events.addEventListener('log', function (event) {
        document.body.innerHTML += event.data + '<br/>';
      }, false);
    </script>
  </body>
</html>
```

I tried it and I got one error upon closing one of the listener browser
tabs:

```text
Mojo::Reactor::Poll: I/O watcher failed: Too few arguments for subroutine at ...
```

It turns out that when [Mojo::Transaction][] fires the [finish][] event,
it does not pass any argument (beyond the instance object), which makes
the following subroutine signature pretty unhappy because it expects
`$code` to be passed:

```perl
  # Unsubscribe from "message" event again once we are done
  $c->on(finish => sub ($c, $code, $reason = undef) {
    $c->app->log->unsubscribe(message => $cb);
  });
```

So *presto*! Let's file a [pull request][]!


[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Perl]: https://www.perl.org/
[Cookbook guide]: https://metacpan.org/pod/Mojolicious::Guides::Cookbook
[finish]: https://metacpan.org/pod/Mojo::Transaction#finish
[Mojo::Transaction]: https://metacpan.org/pod/Mojo::Transaction
[pull request]: https://github.com/mojolicious/mojo/pull/1560
