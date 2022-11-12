---
title: 'Date::Parse'
type: post
tags: [ perl, date, parsing ]
comment: true
date: 2021-04-04 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Date::Parse][] is a useful module.

Now that we know how to determine a [Certificate expiration date][], it's
time to parse the resulting date into something more *useable*.

I mean, some people may like a date like `May 10 03:09:21 2021 GMT`, but I
surely don't.

(I just noticed that my previous sentence has `may like ... like May...`,
fun!)

This is where [Perl][] module [Date::Parse][] comes handy: it accepts a
range of different input formats:

```
1995:01:24T09:08:17.1823213           ISO-8601
1995-01-24T09:08:17.1823213
Wed, 16 Jun 94 07:29:35 CST           Comma and day name are optional 
Thu, 13 Oct 94 10:13:13 -0700
Wed, 9 Nov 1994 09:50:32 -0500 (EST)  Text in ()'s will be ignored.
21 dec 17:05                          Will be parsed in the current time zone
21-dec 17:05
21/dec 17:05
21/dec/93 17:05
1999 10:02:18 "GMT"
16 Nov 94 22:28:20 PST
```

and gives you back nicely parsed data, either in the form of an *epoch* (via
[str2time][]) or of pieces of information (via [strptime][]).

Example:

```
$ certificate_expiration_date polettix.it \
    | perl \
        -MDate::Parse=str2time \
        -MPOSIX=strftime \
        -pale 's{.*=(.*)}
                {strftime("%Y-%m-%dT%H:%M:%SZ", gmtime(str2time($1)))}emxs'
2021-05-10T03:09:21Z
```

*This* I like better, despite being less... readable 😅

[Certificate expiration date]: {{ '/2021/04/03/certificate-expiration-date' | prepend: site.baseurl }}
[Date::Parse]: https://metacpan.org/pod/Date::Parse
[Perl]: https://www.perl.org/
[str2time]: https://metacpan.org/pod/Date::Parse#str2time(DATE-[,-ZONE])
[strptime]: https://metacpan.org/pod/Date::Parse#strptime(DATE-[,-ZONE])

