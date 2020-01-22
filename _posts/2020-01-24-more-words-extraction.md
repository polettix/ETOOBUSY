---
title: A Public Domain List of Words
type: post
tags: [ perl, text, dwarf fortress ]
comment: true
date: 2020-01-24 08:00:00 +0100
preview: true
---

**TL;DR**

> In [A Public Domain List of Adjectives][list-of-adjectives] we found about
> how you can get some words out of [Dwarf Fortress][]. Now let's turn all
> of that in a JSON file.

{{ page.title }} {{ page.date | date: '%Y/%m/%d' }}

## What word types are available?

The file in [Dwarf Fortress] has a regular shape, like this:

```
language_words

[OBJECT:LANGUAGE]

[WORD:ABBEY]
	[NOUN:abbey:abbeys]
		[FRONT_COMPOUND_NOUN_SING]
		[REAR_COMPOUND_NOUN_SING]
		[THE_NOUN_SING]
		[REAR_COMPOUND_NOUN_PLUR]
...
        [ADJ:ace]
                [ADJ_DIST:1]
                [FRONT_COMPOUND_ADJ]
                [THE_COMPOUND_ADJ]
...
        [VERB:act:acts:acted:acted:acting]
                [STANDARD_VERB]
...
        [PREFIX:after]
                [FRONT_COMPOUND_PREFIX]
                [THE_COMPOUND_PREFIX]
```

So, it seems that:

- *interesting* stuff is inside bracket pairs;
- *word types* appear first, followed by a colon (e.g. `NOUN`, `VERB`, ...)
- there is other stuff matching this pattern (e.g. `WORD` and `PREFIX`).

Let's do some [Perl][] magic to extract all candidates:

```bash
$ perl <language_words.txt \
   -E '$/=undef; $_=<>; $x{$_}=1 for m{\G.*?\[(\w+):.*?\]}gmxs; say for keys %x'
VERB
PREFIX
OBJECT
ADJ_DIST
WORD
NOUN
ADJ
```

A little breakdown:

- `$/=undef` turns on *slurp mode*, i.e. all the input file
  (`language_word.txt`, provided as standard input) is read in one single
  string;
- `$_=<>` reads the whole file into *Perl's topic variable*, i.e. the
  variable where most operators apply in lack of an explicit variable;
- the match `m{\G...}gmxs` is a global match (modifier `g`) to catch all
  stuff that is enclosed in brackets and has at least one colon character
  inside;
- the match being global, it returns *all* the matching captures in list
  context, so we iterate over it with `for` and set a flag in hash `%x`
  (with `$x{$_}=1 for m{...}gmxs`)
- last, we print out all the collected keys.

Looking at the output list, I'd bet on `VERB`, `NOUN`, and `ADJ` as our
targets.

## Turn that into JSON

It's time to take a closer look at the different word types:

- `ADJ` always include one item, so that's it. We will just put that as a
  string, inside an array;
- `NOUN` always includes two items, possibly empty, the first one being the
  singular form and the other one the plural form;
- `VERB` is the more *complicated*, with five parts: present, present (third
  person), past, past participle, *ing* form.

Time to code:

<script src="https://gitlab.com/polettix/notechs/snippets/1932144.js"></script>

There's also a [local version][], as usual.

*Slurping* the input data has no mysteries for us (line 8).

When matching the data with modifier `g`, [Perl][] happily goes through all
matches. In this case, we have two capturing groups, one for the *type* and
one for its *payload*, which will end up filling array `@pairs` in this
order (i.e. *type*, *payload*, *type*, *payload*, ...).

The main loop iterates until there are items in `@pairs`, extracting two
items at each round and putting them into `$type` and `$payload`
respectively (line 13). The rest of the loop is pretty straighforward:
depending on the `$type`, a different part of the collecting hash is
populated.

Last, we leverage `JSON::PP` to print out the collected data as JSON.

## So...

... we now have our public domain word list, in JSON format. Do you want a
version available as of release 0.44.12 of [Dwarf Fortress][]? Be my guest
and find it here: [words as json][]. In case you're wondering yes, it has
been pretty-printed using [jq][] 😅.


[Perl]: https://www.perl.org/
[list-of-adjectives]:  {{ '/2020/01/23/list-of-adjectives' | prepend: site.baseurl | prepend: site.url }}
[Dwarf Fortress]: https://www.bay12games.com/dwarves/
[local version]: {{ '/assets/code/df-language_words-to-json.pl' | prepend: site.baseurl | prepend: site.url }}
[words as json]: {{ '/assets/other/public-domain-words.json' | prepend: site.baseurl | prepend: site.url }}
[jq]: https://stedolan.github.io/jq/
