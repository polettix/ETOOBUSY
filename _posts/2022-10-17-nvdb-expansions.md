---
title: Expanding words in NVdB
type: post
series: Passphrases
tags: [ security, text, perl ]
comment: true
date: 2022-10-17 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Expanding the list of words taken from [Nuovo vocabolario di
> base][nvdb].

Italian is my native language so it's pretty natural for me to
concentrate on it. Additionally, I'd like to get some people onboard
with making their passphrases stronger, and they're mostly Italians.

One *great* thing is that Italian has a lot of variants of basic words,
to be used depending on the specific situation. As an example, whereas
English has very little variations for the present tense (just adding an
`s` letter for the singular third person), Italian usually has a
specific variant for the different alternatives.

As an example, let's *play* a bit:

```
I      play    |  Io        gioco
You    play    |  Tu        giochi
She/He plays   |  Ella/Egli gioca
We     play    |  Noi       giochiamo
You    play    |  Voi       giocate
They   play    |  Esse/Essi giocano
```

Something similar happens for adjectives (which might have alternatives
for female/male forms, as well as singular/plural) and, to a lesser
degree, nouns. As an example, this is *cat*:

```
Singular, female  cat  |  gatta
Singular, male    cat  |  gatto
Plural,   female  cat  |  gatti
Plural,   male    cat  |  gatte
```

Hence, I think it's just *right* to take advantage of these variations
to spice things up in passphrases generations. Like we might end up
adding a couple of bits of entropy, or more!

This also helps us address a little elephant in the room. Many words are
admittedly *long*, so having to type four long words might scare people
away. On the other hand, removing long words has an impact on the
entropy we can expect out of each word, so we hope that we can somehow
compensate with these variations.

Let's see!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[nvdb]: https://www.internazionale.it/opinione/tullio-de-mauro/2016/12/23/il-nuovo-vocabolario-di-base-della-lingua-italiana
