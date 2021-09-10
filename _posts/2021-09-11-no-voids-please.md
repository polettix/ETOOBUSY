---
title: No voids, please
type: post
tags: [ shell, cli ]
comment: true
date: 2021-09-11 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I did a small filtering program to rename files removing spaces and tabs.

I'm experimenting the usage of a *pipeline* approach to do some
transformations upon a starting sets of images, so I'm finding useful to
pass filenames through the pipeline (*stdout*/*stdin*).

Sometimes, though, I need to use *many* of these files all at once (e.g.
to aggregate them inside the same command) and the easiest way to do
this is to cope with file names without spaces. Which is not always the
starting situation.

So here I am, re-inventing this wheel:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2173496.js"></script>

Basically, sequences of consecutive spaces are all turned into a single
`"-"` character. Files that comply with the no-voids rule are not
touched.

It does some attempt to avoid overwriting a pre-existing files, checking
for existence and trying to generate a different file name until a
*free* one is found. The mechanism is not perfect though, as it leaves a
time window between the *check for existence* and the *file renaming*
where a new file with that name might be created. Now you know it.

As anticipated, it uses standard input and output to pass the file
names. Each line is a file name; output filenames are those without
spaces, which might be the input file name if it does not have spaces in
the first place. I mean, *do what I mean*.

Here's how we would use it:

```
# Rename all files that have `bar` in their name, but not `foo`, so that
# they don't contain spaces. Then `cat` them all.
$ cat $(ls *bar* | grep -v foo | novoids)
```

I hope it can be useful! Stay safe and... see you next time.
