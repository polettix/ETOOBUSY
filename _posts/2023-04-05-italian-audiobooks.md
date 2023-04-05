---
title: Italian Audiobooks
type: post
tags: [ audiobook, web ]
comment: true
date: 2023-04-05 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [RaiPlaySound][] has an interesting selection of [audiobooks][rps-ab] (in
> Italian), and [LiberLiber][] has [audiobooks][ll-ab] too!

If you're interested into listening to audiobooks in Italian *for free*,
you're *kinda* out of luck. I mean, there's definitely a selection, but not
even comparable to what's available in English (or many other languages).

Most of what I found online is from [LiberLiber][] ([here][ll-ab]), which is
interesting but a bit *limited*, being restricted to public domain material
only. It's great and it's very easy to download audiobooks for offline
listening.

More recently I found that [RaiPlaySound][] has a section about
[audiobooks][rps-ab] too. Alas, it *seems* that we are able to get
audiobooks for offline listening only accessing the service through the App
for mobile or tablet devices, while the web access is only restricted to
streaming.

This is both unfortunate and *irritating*, considering that [RaiPlaySound][]
is a service by [Rai][], which in turn is the national television which gets
public money, mine included.

Anyway, they decided that they should have a walled garden and strict
control over what and when and where we citizens can listen to stuff that
they're paying... but they know better, right? **Right?!?**

For this reason, I will not reiterate my enthusiasm for [Cosmic
mitmproxy][], possibly dumping traffic in a file:

```
$ mitmdump --flow-detail=2 --showhost | tee session.txt
```

I wonder if it would be able to capture anything if we then set the browser
to use it as a proxy and then click around in an audiobook's page, possibly
for later extraction with a couple of regular expressions...

```
$ grep -Po '\A\S+\s+(?mxs:GET|HEAD)\s+\K\S+' session.txt > urls.txt
$ grep -Po '\Ahttps://creative.*?\.mp3' urls.txt | sort -u > urls-mp3.txt
```

Does the second regular expression work? Will it tomorrow? Who knows?

Finally, who knows whether `curl` will be available to download those URLs
with just the default settings, or fail miserably? I discovered that there's
no way to give it a file with a list of urls, so will `xargs` do the trick?

```
$ xargs -n 1 curl -LO <urls-mp3.txt
```

Well, I guess that I will never know...

Moving on to a totally different topic, I figured that the [Awesome
exiftool][], together with [Romeo][], can do wonders to organize a few MP3
files you might have around:

```
$ cat m3u-template.tp2
#EXTM3U
#EXTALB: [% 0.Album %]
#EXTART: [% 0.Artist %]
#EXTGENRE: [% 0.Genre %]
[%
   for my $item (A) {
      my ($h, $m, $s) = $item->{Duration} =~ m{(\d+)}gmxs;
      $s += 60 * ($m + 60 * $h);
%]
#EXTINF:[%= $s %],[%= $item->{Title} %]
[%= $item->{SourceFile} %]
[% } %]

$ exiftool -j -q -Artist -Year -Genre -Album -Title -Duration *.mp3 \
  | romeo tp -t m3u-template.tp2 > playlist.m3u
```

OK, not too much for today, but some days can be a bit weaker, can't they?

Stay safe!

[RaiPlaySound]: https://www.raiplaysound.it/
[rps-ab]: https://www.raiplaysound.it/programmi/adaltavoce/audiolibri
[LiberLiber]: https://www.liberliber.it/
[ll-ab]: https://www.liberliber.it/online/opere/audiolibri/
[Rai]: https://www.rai.it/
[Cosmic mitmproxy]: {{ '/2023/04/04/cosmic-mitmproxy/' | prepend: site.baseurl }}
[Awesome exiftool]: {{ '/2023/04/03/awesome-exiftool/' | prepend: site.baseurl }}
