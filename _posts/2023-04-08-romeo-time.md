---
title: Romeo time
type: post
tags: [ perl ]
series: Romeo
comment: true
date: 2023-04-08 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some notes about the `time` sub-command in [Romeo][].

As a small note to future me, and to excercise my muscle memory a bit, some
usage examples on using the `time` sub-command.

The main goal is to transform... time across different representations:
epoch, ISO-8601(ish) strings, Active Directory monstrous integers.

It aims at being useful while not taking itself too seriously, so beware:
anything before the start of the Unix epoch (`1970-01-01T00:00:00`) or
sufficiently ahead in the future is officially unsupported.

I played a bit with the interface, eventually settling on a *dwim* default
where it's possible to specify the input format directly (defaulting to
epochs if it's just a bunch of digits). So...

```
$ romeo time iso:2023-04-01 1680300000 ad:133247736000000000
2023-04-01T00:00:00+0200
2023-04-01T00:00:00+0200
2023-04-01T00:00:00+0200
```

As it's clear, the output defaults to my favourite flavor of ISO-8601
format. This is in the spirit that most of the time *I* want to figure out
what an epoch or an AD time *mean* in my local time.

It's possible that some different conversion is needed, though. Especially
when we're *starting* from an ISO-8601 date/datetime, right? It's of course
possible to set a differnet target format:

```
$ romeo time iso:2023-04-01 -t epoch
1680300000

$ romeo time iso:2023-04-01 -output-format ad
133247736000000000

# Look! No offset!
$ romeo time iso:2023-04-01 -t gm
2023-03-31T22:00:00+0000
```

There's also some rudimentary arithmetic capability, where it's possible to
add offsets either directly when providing an input:

```
$ romeo time iso:2023-04-01+2w-1d
2023-04-14T00:00:00+0200
```

or using the specific offset option `-D`/`--offset`:

```
$ romeo time iso:2023-04-01 -D +2w-1d
2023-04-14T00:00:00+0200
```

What's the difference? Well, the option is applied to all inputs, so it's
useful if we want to apply a specific offset to a bunch of input dates:

```
$ romeo time iso:2023-04-01 1680300000 ad:133247736000000000 -D +2w-1d
2023-04-14T00:00:00+0200
2023-04-14T00:00:00+0200
2023-04-14T00:00:00+0200
```

The other alternative is more a shorthand to set a specific point in time,
so to say. This is because there's more to the *do what I mean* interface,
like using words like `now`, `today`, `yesterday`, and `tomorrow`:

```
$ romeo time now today yesterday tomorrow
2023-04-07T17:51:36+0200
2023-04-07T00:00:00+0200
2023-04-06T00:00:00+0200
2023-04-08T00:00:00+0200
```

This makes it easy to express *the day before yesterday* ([ereyesterday][]
seemed a bit too archaic) or *the day after tomorrow*:

```
$ romeo time yesterday-1d today-2d today+2d tomorrow+1d
2023-04-05T00:00:00+0200
2023-04-05T00:00:00+0200
2023-04-09T00:00:00+0200
2023-04-09T00:00:00+0200
```

OK, I hope this will be a useful refresher... bye bye, future me!

Everyone else stay safe!



[Perl]: https://www.perl.org/
[Romeo]: {{ '/2023/03/07/fun-with-romeo/' | prepend: site.baseurl }}
[ereyesterday]: https://en.wiktionary.org/wiki/ereyesterday
