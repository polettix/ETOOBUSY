---
title: Awesome exiftool
type: post
tags: [ perl, audio, metadata ]
comment: true
date: 2023-04-03 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [exiftool][] works for audio files too.

I was downloading an audiobook (from [here][]) and I wanted to generate an
[M3U][] playlist programmatically.

One interesting line in such file "format" is useful for setting a title,
but it also needs the track duration. I initially thought to use [ffmpeg][]:

```
$ ffmpeg -i hawthorne_lettera_mc_01_coperti.mp3
...
Input #0, mp3, from 'hawthorne_lettera_mc_01_coperti.mp3':
  Metadata:
    artist          : Nathaniel Hawthorne
    comment         : Liber liber, progetto "Libro parlato" <https://www.liberliber.it/progetti/libroparlato/>
    title           : Copertina
    genre           : Speech
    track           : 1
    album           : LA LETTERA SCARLATTA
    date            : 2019
  Duration: 00:00:47.60, start: 0.025056, bitrate: 277 kb/s
    Stream #0:0: Audio: mp3, 44100 Hz, mono, fltp, 102 kb/s
    Metadata:
      encoder         : LAME3.99r
    Stream #0:1: Video: mjpeg (Baseline), yuvj444p(pc, bt470bg/unknown/unknown), 2000x2000, 90k tbr, 90k tbn, 90k tbc (attached pic)
    Metadata:
      title           : Libro parlato
      comment         : Cover (front)
```

Uhm... there's a lot to parse here. Having already introduced the wonderful
[Image::ExifTool][] in the past, *I wonder if...*

```
$ exiftool hawthorne_lettera_mc_01_coperti.mp3
ExifTool Version Number         : 12.42
File Name                       : hawthorne_lettera_mc_01_coperti.mp3
...
Artist                          : Nathaniel Hawthorne
Comment                         : Liber liber, progetto "Libro parlato" <https://www.liberliber.it/progetti/libroparlato/>
Year                            : 2019
Genre                           : Speech
Track                           : 1
Album                           : LA LETTERA SCARLATTA
Title                           : Copertina
...
Duration                        : 0:00:48 (approx)
```

Wow, it's supported! Moreover, it's definitely easier to get something
trivial to parse, as it's capable of providing JSON data back and resrict to
only attributes of interest:

```
$ exiftool -j -Artist -Year -Genre -Album -Title -Duration hawthorne_lettera_mc_01_coperti.mp3
[{
  "SourceFile": "hawthorne_lettera_mc_01_coperti.mp3",
  "Artist": "Nathaniel Hawthorne",
  "Year": 2019,
  "Genre": "Speech",
  "Album": "LA LETTERA SCARLATTA",
  "Title": "Copertina",
  "Duration": "0:00:48 (approx)"
}]
```

At this point, it's easy to feed this into [teepee][] (or [Romeo][]) with
the following template:

```
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
```

to generate the playlist file:

```
$ exiftool -j -q -Artist -Year -Genre -Album -Title -Duration *.mp3 \
    | romeo tp -t m3u8.tp2

#EXTM3U
#EXTALB: LA LETTERA SCARLATTA
#EXTART: Nathaniel Hawthorne
#EXTGENRE: Speech

#EXTINF:48,Copertina
hawthorne_lettera_mc_01_coperti.mp3

#EXTINF:137,Preambolo alla seconda edizione
hawthorne_lettera_mc_02_preambo.mp3

#EXTINF:6651,La Dogana. Introduzione a "La lettera scarlatta"
hawthorne_lettera_mc_03_la_doga.mp3

...
```

Let's face it: [exiftool][] is amazing, and we are should all stay safe!

[Perl]: https://www.perl.org/
[exiftool]: https://exiftool.org/
[here]: https://www.liberliber.it/online/autori/autori-h/nathaniel-hawthorne/la-lettera-scarlatta-audiolibro/
[M3U]: https://en.wikipedia.org/wiki/M3U
[ffmpeg]: https://ffmpeg.org/
[Image::ExifTool]: {{ '/2021/10/09/image-exiftool/' | prepend: site.baseurl }}
[teepee]: {{ '/2021/03/16/teepee/' | prepend: site.baseurl }}
[Romeo]: {{ '/2023/03/07/fun-with-romeo/' | prepend: site.baseurl }}
