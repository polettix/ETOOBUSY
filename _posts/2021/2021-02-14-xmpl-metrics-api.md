---
title: 'xmpl - the metrics API'
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-02-14 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A closer look to the [implementation][code] of the metrics API in
> [xmpl][]. This is a [series of posts][series].

Modern-time applications that aim to be good citizens in [Kubernetes][]
clusters usually send logs to the standard channels and provide an
endpoint to *scrape metrics*.

I use the term *scrape* because it's what the leading platform in
collecting these metrics does: [Prometheus][]. This has the benefit to
unlock some use cases while testing, e.g. the collection and
visualization of data (e.g. via [Grafana][]) as well as generation of
alerts via the [Alertmanager][].

For this reason, [xmpl][] provides a `GET` endpoint for scraping
metrics, at the customary `/metrics` path used by [Prometheus][]:

```perl
get '/metrics' => sub ($c) {
   state $calls = 0;
   my $life_time = time() - $^T;
   my $is_healthy = is_healthy() ? 1 : 0;
   ++$calls;
   my $d6 = 1 + int rand 6;
   (my $kvtype = ref kvstore()) =~ s{\A.*::}{}mxs;
   $c->render(text => <<"END");
# HELP life_time_seconds Time since start of process
# TYPE life_time_seconds counter
life_time_seconds $life_time
# HELP healthz_status Status of health (1 healthy, 0 unhealthy)
# TYPE healthz_status gauge
healthz_status $is_healthy
# HELP metrics_calls Calls to the /metrics endpoint
# TYPE metrics_calls counter
metrics_calls $calls
# HELP random_d6 A random value from a regular 6-sided die
# TYPE random_d6 gauge
random_d6 $d6
# HELP kvstore_info Info on the key/value store (as labels)
# TYPE kvstore_info gauge
kvstore_info{kind=$kvtype} 1
END
};
```

It is actually a very small set of metrics, and probably not a
particularly clever one. It does the job of getting the ball started
though, suggestions are very, very welcome!

Monitor yourself!

[xmpl - an example web application]: {{ '/2020/02/05/xmpl/' | prepend: site.baseurl }}
[xmpl]: https://gitlab.com/polettix/xmpl
[code]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl
[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Kubernetes]: https://kubernetes.io/
[README.md]: https://gitlab.com/polettix/xmpl/-/blob/master/README.md
[series]: {{ '/series#xmpl' | prepend: site.baseurl }}
[Prometheus]: https://prometheus.io/
[Grafana]: https://grafana.com/
[Alertmanager]: https://www.prometheus.io/docs/alerting/latest/alertmanager/
