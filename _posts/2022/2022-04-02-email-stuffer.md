---
title: 'Email::Stuffer'
type: post
tags: [ perl, email ]
comment: true
date: 2022-04-02 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I'm using [Email::Stuffer][], not sure for how long I'll do.

There's little to say, *[Email::Stuffer][] is handy*:

```perl
Email::Stuffer->from     ('cpan@ali.as'             )
              ->to       ('santa@northpole.org'     )
              ->bcc      ('bunbun@sluggy.com'       )
              ->text_body($body                     )
              ->attach_file('dead_bunbun_faked.gif' )
              ->transport(SMTP => $opts             )
              ->send;
```

Alas, I'm not 100% sure I'll continue to use it in the project I'm
working on now, because of a little annoyance:

- it's possible to set a `text_body` and a `html_body` separately...
- it's possible to attach files...
- [it's not possible to keep the text and the html body sufficiently
  apart when there are other attachments][issue].

And yes, I need attachments.

So my dilemma now is either to delve into the module and propose
something to remove this limitation, OR shift to the less slick
[Email::MIME][]. I'm tempted by the first, but I'll probably settle for
the second.

[Perl]: https://www.perl.org/
[Email::Stuffer]: https://metacpan.org/pod/Email::Stuffer
[Email::MIME]: https://metacpan.org/pod/Email::MIME
[issue]: https://github.com/rjbs/Email-Stuffer/issues/60
