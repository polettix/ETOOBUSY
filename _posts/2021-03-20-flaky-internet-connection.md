---
title: Flaky internet connection
type: post
tags: [ networking, shell ]
comment: true
date: 2021-03-20 09:30:47 +0100
mathjax: false
published: true
---

**TL;DR**

> A small program to monitor my Internet connection.

I lately activated a new Internet connection and so far it's been...
*flaky*. Technically speaking, it starts going nuts at around 5 PM for about
a couple of hours, with occasional events in other hours of the day.

Not very good when you're smart working in a meeting and your connection
resets so often.

My Internet Provider told me to reset the router to its factory settings. I
was skeptical of this measure, first because I received the router with its
factory settings about 10 days ago (and I always had the issue!), second
because it definitely seems to be a remote issue. Whatever, this is the
process so let's follow it.

Then I had to "monitor" the connection for about 24 hours. Time for some
coding! Although I'm sure there must be so many tools to do this... why not?

```shell
#!/bin/sh

URL="$1"
highlight="$(printf %b \\033)[1;97;45m"
reset="$(printf %b \\033)[0m"
n=0
while true ; do
   outcome='ok' # be optimistic
   curl -s --connect-timeout 2 -I "$URL" >/dev/null 2>&1 \
      || outcome="${highlight}not ok"
   n=$(( n + 1 ))
   printf '%s %d %s%s\n' "$outcome" "$n" "$(date)" "$reset"
   sleep 10
done | tee monitor.log
```

I'm using a simple check using [curl][] to send a `HEAD` request towards URL
provided as argument on the command line.

This enters an infinite (well... *indefinite*) loop to send the request, log
the result, and take some rest (10 seconds).

The monitor both provides a visual clue when something goes wrong (using [A
cheap terminal trick][]) and log the results on a file (using the `| tee
monitor.log` redirection from the `while` loop). The visual clue is useful
because if I'm looking at the screen I can go and see what's happening on
the router (lights are normally white, but go red when the connection is
lost).

So here's what happened yesterday, at around 6:30 PM:

![Flaky internet connection]({{ '/assets/images/flaky-internet-connection.png' | prepend: site.baseurl }})

Should I start serving web pages from home? 🤬


[A cheap terminal trick]: {{ '/2021/03/05/cheap-terminal-trick/' | prepend: site.baseurl }}
[curl]: https://curl.se/
