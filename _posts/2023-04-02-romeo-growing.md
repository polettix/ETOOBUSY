---
title: Romeo is growing
type: post
tags: [ perl ]
series: Romeo
comment: true
date: 2023-04-02 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Romeo][] is growing.

Well, maybe a bit too organically, but hey! It's my commemoration of a cat,
and I'm going to put whatever I want inside:

```
sub-commands for /home/poletti/bin/romeo
         blocky: Turn stuff into Unicode blocky stuff
                 (also as: blk)
             cf: validate Italian "Codice Fiscale"
                 (also as: codicefiscale, codice-fiscale)
          color: Colorize lines according to regular expressions
                 (also as: colorize)
      corkscrew: Corkscrew in Perl (https://github.com/bryanpkc/corkscrew)
       csv2json: Turn a CSV into a JSON file
          frame: Put a frame around the input
          heail: head and tail a file
           hmac: calculate HMAC from several hashing algorithms
       json2csv: Turn a JSON into a CSV file
            pad: Pad input with whitespaces
           pass: generate a random password
                 (also as: password)
            png: Get PNG metadata from files
                 (also as: pngmeta, png-meta)
     same-width: Make all lines the same width (or at least try)
          slice: Slice input data and keep tasty samples
    slice-build: Slice input data and keep definitions for tasty samples
         teepee: Render Template::Perlish templates from JSON data
                 (also as: tp)
           time: Convert times depending on needs
      urldecode: url decode (or encode, depending on the name)
                 (also as: urlencode)
            xxd: hex dumper a-la xxd (shipped with the Vim editor)
```

It's about 600 kB right now, which is fair. Maybe I could squeeze some
additional docs out.

Lately it underwent a bit of refactoring, so a few features might be
temporarily lost. I expect to be the only user, though, so it should not be
a big deal.

And I truly need to write systematic tests so that I don't have to write
statements as the previous sentence, which is admittedly embarassing!

Stay safe!

[Perl]: https://www.perl.org/
[Romeo]: {{ '/2023/03/07/fun-with-romeo/' | prepend: site.baseurl }}
