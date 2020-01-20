---
title: A Public Domain List of Adjectives
type: post
tags: [ perl, text, dwarf fortress ]
comment: true
date: 2020-01-23 08:00:00 +0100
published: false
---

**TL;DR**

> I needed a list of adjectives, [Dwarf Fortress][] helped me get one.


So it happens that I need - well, want - a list of adjectives for some
generative idea. Looking around there are many, but then I figure that I wan
a *public domain* one and avoid headaches.

Again, the mighty internet to the rescue: [Where can I find a public domain
or CC0 list of English adjectives?][quora-question] hits the nail right in
the head.

It turns out that [Dwarf Fortress][] saves the day. Beyond being an
incredibly profound and addictive game, it doubles down on providing help
when you need it. In how many more ways can that *thing* be amazing, I ask?

With absolutely *no pretense* of being useful, I whipped up a quick [Perl][]
program to extract adjectives, and here we are.

<script src="https://gitlab.com/polettix/notechs/snippets/1931789.js"></script>

(Also in a [local version][]).

If you're curious to try it out, here is also the
[`language_words.txt`][lang-words] file.

Last, I know it sounds wasty and horrible, but:

```
perl df-get-words.pl | perl -E 'chomp(@x=<>); say $x[rand @x]'
```

is a way to print a random adjective on the command line.

[quora-question]: https://www.quora.com/Where-can-I-find-a-public-domain-or-CC0-list-of-English-adjectives
[Dwarf Fortress]: https://www.bay12games.com/dwarves/
[Perl]: https://www.perl.org/
[local version]: {{ '/assets/code/df-get-words.pl' | prepend: site.baseurl | prepend: site.url }}
[lang-words]: {{ '/assets/other/language_words.txt' | prepend: site.baseurl | prepend: site.url }}
