---
title: Advent of Code puzzle input downloader
type: post
tags: [ advent of code, shell ]
comment: true
date: 2022-11-28 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A shell program to download inputs for [Advent of Code][] puzzles.

This is probably a note to myself for 2023.

It needs to access the cookie `session` from an authenticated browser. In Firefox:

- open [Advent of Code][] and open the Developer Tools
- go to the `Network` tab
- login if you haven't yet, refresh otherwise
- look for cookie `session` in one of the fetched items
- save it in `/path/to/local/session-cookie`

You can call it in different ways:

```shell
/path/to/get-inputs.sh 2018 15      # 15th puzzle of 2018 edition

# in a directory named 2022
/path/to/get-inputs.sh 4            # 4th puzzle of 2022 edition

# in a directory named 2022, on December 13th
/path/to/get-inputs.sh              # 13th puzzle of 2022 edition
```

Here's the code:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2463984.js"></script>

Enjoy!

[Advent of Code]: https://adventofcode.com/
