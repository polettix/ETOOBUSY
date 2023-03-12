---
title: Romeo - slice
type: post
tags: [ perl, romeo ]
series: Romeo
comment: true
date: 2023-03-13 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [Romeo][] now has a couple of **slicing** features.

I sometimes have to manipulate a series of records from a database,
usually coming as a JSON-encoded array, where I'm actually only interested
into a subset of the data. This is when *slicing* comes handy, allowing to
pick only the interesting parts and leave the rest out.

So far I used [jq][], which still is an awesome tool for doing a lot of
creative transformations on JSON data. And yet the *slicing* capabilities
still come handy.

So, for the following examples, let's assume that our input comes from file
`data.json`, with the following data inside:

```json
[
   {
      "foo": "just a string",
      "goo'''": "bar",
      "array": ["one", "two", "three" ],
      "hash": {
         "sub-hash": {
            "baz": "this is important",
            "galook": "this is not"
         },
         "other-stuff": [ 1, 2, 3 ],
         "then": "other data"
      }
   },
   {
      "foo": "JUST A STRING",
      "goo'''": "BAR",
      "array": ["ONE", "TWO", "THREE" ],
      "hash": {
         "sub-hash": {
            "baz": "THIS IS IMPORTANT",
            "galook": "THIS IS NOT"
         },
         "then": "OTHER DATA"
      }
   }
]
```

We have fancy keys with single quotes, as well as some missing data (the
second record misses `other-stuff` inside `hash`).

## Starting simple: the command line

At the basic level, `romeo slice` provides us the possibility to use the
same paths as available in [Template::Perlish][], which is one of my most
beloved modules. This just works:

```
$ romeo slice -i data.json foo hash.then
[
   {
      "foo" : "just a string",
      "hash" : {
         "then" : "other data"
      }
   },
   {
      "foo" : "JUST A STRING",
      "hash" : {
         "then" : "OTHER DATA"
      }
   }
]
```

The data I come across rarely has weird characters inside, so this Just
Works. In the [Perl][] spirit of making hard things possible, though, also
complex keys are supported with some help from quoting:

```
$ romeo slice -i data.json "\"goo'''\"" hash.'"other-stuff"'
[
   {
      "goo'''" : "bar",
      "hash" : {
         "other-stuff" : [
            1,
            2,
            3
         ]
      }
   },
   {
      "goo'''" : "BAR",
      "hash" : {
         "other-stuff" : null
      }
   }
]
```

The slicing *created* some inexistent data, which might be useful or not.
It's possible to skip non-existing data entirely with option `-s`/`--skip`:

```
$ romeo slice -i data.json "\"goo'''\"" hash.'"other-stuff"' --skip
[
   {
      "goo'''" : "bar",
      "hash" : {
         "other-stuff" : [
            1,
            2,
            3
         ]
      }
   },
   {
      "goo'''" : "BAR"
   }
]
```

## Renaming stuff

Sometimes we would just like to have a *summary*, cherry-picking stuff in a
complex data structure and having it all in a plain hash with everything at
the top level.

To help with this, the path definition allows *renaming*, by supporting a
syntax like `dst:src` or "dst=src`, like in the following example:

```
$ romeo slice -i data.json "just_goo:\"goo'''\"" other:hash.'"sub-hash"'.baz
[
   {
      "just_goo" : "bar",
      "other" : "this is important"
   },
   {
      "just_goo" : "BAR",
      "other" : "THIS IS IMPORTANT"
   }
]
```

As a shorthand, it's possible to just request the name of the last part of
the path with character `@`:

```
$ romeo slice -i data.json foo @:hash.'"sub-hash"'.baz
[
   {
      "baz" : "this is important",
      "foo" : "just a string"
   },
   {
      "baz" : "THIS IS IMPORTANT",
      "foo" : "JUST A STRING"
   }
]
```

The *destination* string is a path on itself, so it's possible to move stuff
around:

```
$ romeo slice -i data.json some.where:foo some.there:hash.'"sub-hash"'.baz
[
   {
      "some" : {
         "there" : "this is important",
         "where" : "just a string"
      }
   },
   {
      "some" : {
         "there" : "THIS IS IMPORTANT",
         "where" : "JUST A STRING"
      }
   }
]
```

## Moving on: extracting the same slice over and over

If our extraction needs are to be repeated in time, it just makes sense to
save the slice definitions inside a file and reuse it over and over.

As we already saw, each definition is a mapping from a source to a
destination, which can be represented in JSON like this, saved in file
`def01.json`:

```
[
    { "dst": ["some", "where"], "src": ["foo"] },
    { "dst": ["some", "there"], "src": ["hash", "sub-hash", "baz"] }
]
```

The nice thing about it is that with the expanded array form we don't need
the fancy quoting any more and just use the keys.

Here's the result of applying the slicing, loading it with option
`-d`/`--definition`:

```
$ romeo slice -i data.json -d def01.json 
[
   {
      "some" : {
         "there" : "this is important",
         "where" : "just a string"
      }
   },
   {
      "some" : {
         "there" : "THIS IS IMPORTANT",
         "where" : "JUST A STRING"
      }
   }
]
```

In case of need, additional definitions can be provided using the option
multiple times, as well as providing direct slicing commands on the command
line like before (e.g. to add more data just for checking).

## Interactive selection

Slicing also allows interactively selecting the pieces of interest from the
first record, and then applying it to all records. This is done thanks to
[Term::Choose][], which is an amazing piece of code!

In the following [asciinema][] recording, after entering interactive mode:

- moving is done with up/down keys
- selection of a row is done with the space bar
- completing the selection (including the currently highlighted row) is done
  with the enter/return key

<script async id="asciicast-566840" src="https://asciinema.org/a/566840.js"></script>

## Enough for today!

So... I guess this should be enough for showcasing [Romeo][]'s sub-command
`slice`, see you next time and stay safe!


[Perl]: https://www.perl.org/
[Romeo]: https://codeberg.org/polettix/Romeo
[jq]: https://stedolan.github.io/jq/
[Template::Perlish]: https://metacpan.org/pod/Template::Perlish
[Term::Choose]: https://metacpan.org/pod/Term::Choose
[asciinema]: https://asciinema.org/
