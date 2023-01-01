---
title: eml-gist - web edition
type: post
tags: [ perl, security, mojolicious ]
comment: true
date: 2022-07-17 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Adapting [eml-gist][] for the Web.

After spurting [eml-gist][], it came somehow natural to have it around
and to share it with some people. They still have to know what they are
doing, because saving email messages in `eml` format from Outlook is
definitely **not straightforward**:

- create a new message
- drag-and-drop the message you want to save in it, as attachment
- send it to yourself
- open the web version of Outlook
- save the attachment - it will be in `eml` format.

In case you're wondering *no, the fourth step cannot be done in desktop
Outlook*.

I guess the whole thing is not a business priority. Anyway, enough
ranting and back to the web version.

There's a first reshaping in [the web branch of the repository][web].
It's still just a POST endpoint handler that expects to receive a file
via an upload, but it's a start. Next steps will be to add a minimal
page to ease the upload from a browser, and pack in a Docker image.

Cheers!

[Perl]: https://www.perl.org/
[eml-gist]: {{ '/2022/07/15/eml-gist/' | prepend: site.baseurl }}
[web]: https://codeberg.org/polettix/eml-gist/src/branch/web
