---
title: Generate an example "name"
type: post
tags: [ generative, Perl, text ]
comment: true
date: 2020-01-28 21:08:16 +0100
---

**TL;DR**

> Want a name for your *initiative*? Why not pair an *adjective* and a
> *noun* then? Why not generate it programatically?!?

In a couple of previous posts we looked at how to get our hands on some
words - for example [A Public Domain List of Words][list-of-words].

Let's put that list to work:

<script src="https://gitlab.com/polettix/notechs/snippets/1933477.js"></script>

[Local version here][]. If you need it, you can also find the [JSON file
with words][words-json].

Reading the whole JSON file in a [Perl][] data structure is encapsulated in
its own function `read_json` in lines 27-31.

Function `generate_pair` is devoted to draw an *adjective* and a *noun*
randomly:

- for *adjectives*, we consider the *direct* ones with the addition of a
  couple of verbal forms, namely *past participles* and *ing forms*;
- for *nouns*... we just use nouns.

After drawing them, the pair is returned as an anonymous array (line 24) and
printed out (line 11).

Time for a sample run:

```shell
$ for x in 1 2 3 4 5 ; do ./generate-name.pl ; done
trotting moons
chopping scratches
good crews
lathering crevices
screamed cyclone
```

Funny 😄

[list-of-adjectives]:  {{ '/2020/01/23/list-of-adjectives' | prepend: site.baseurl | prepend: site.url }}
[list-of-words]:  {{ '/2020/01/24/more-words-extraction' | prepend: site.baseurl | prepend: site.url }}
[Perl]: https://www.perl.org/
[Local version here]: {{ '/assets/code/generate-name.pl' | prepend: site.baseurl | prepend: site.url }}
[words-json]: {{ '/assets/other/public-domain-words.json' | prepend: site.baseurl | prepend: site.url }}
