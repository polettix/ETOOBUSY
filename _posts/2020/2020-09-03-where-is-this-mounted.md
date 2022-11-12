---
title: 'Where does this belong in the filesystem?'
type: post
tags: [ linux, filesystem ]
comment: true
date: 2020-09-03 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Know how to see which device a file belongs to.

From time to time, I have to rediscover how to do this.

*This* being a very simple thing: find out which underlying device is
actually holding a file or a directory. As an example, I sometimes have
to check whether there is enough space in the current directory, and in
case go somewhere else.

The bottom line is that [df][] is my friend, and I hope I will remember
it when I will need this bit of information the next time:

```shell
$ df "$HOME"
Filesystem                    1K-blocks     Used Available Use% Mounted on
/dev/mapper/foobarx--vg-root  36643428  15040292  19712016  44% /
```

This is it: just pass the path to the file/directory you want checked,
and you will get back the only relevant line from [df][].

Brilliant!

[df]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/df.html#tag_20_33
