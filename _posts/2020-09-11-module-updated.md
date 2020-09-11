---
title: "New release of Bot::ChatBots::Telegram"
type: post
tags: [ perl, chatbots, telegram ]
comment: true
date: 2020-09-11 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I just pushed a new release of [Bot::ChatBots::Telegram][].

It so happens that *two times* in the same (yester)day I had some
feedback about stuff I share. Considering the average (which is
usually... me thanking my *past self* for leaving a few crumbles of
documentation here and there), it definitely made my
community-contributor day.

The first came from my previous post 
[Sending 204 "No Content" from Mojolicious][no-content], which got -
*hear hear* - **two comments**. Which, by the standards of the blog, is
about the same as saying **too comments**. It made me happy 😄

The second was [issue #10][issue-10] for [Bot::ChatBots::Telegram][], a
[Perl][] module for... [Telegram bots][].
It's not actually an issue with the module *per-se*, because the warning
came from a dependency, but still I was happy that the module was
getting some attention from [a friend][ferz] 😊

So, no big surprise that the resolution actually
amounted to this (thanks to an update in [WWW::Telegram::BotAPI][], of
course!):

```diff
  requires 'Mojolicious',           '7.08';
  requires 'Ouch',                  '0.0409';
  requires 'Try::Tiny',             '0.27';
- requires 'WWW::Telegram::BotAPI', '0.10';
+ requires 'WWW::Telegram::BotAPI', '0.12';
  requires 'Moo',                   '2.002005';
  requires 'namespace::clean',      '0.27';
```

As I discovered, there's *always* something more to do, like e.g. add
some missing dependencies for the dev environment. You're never done
with these babies 😅

So there you go, a new release of [Bot::ChatBots::Telegram][] is out!

[Bot::ChatBots::Telegram]: https://metacpan.org/pod/Bot::ChatBots::Telegram
[no-content]: {{ '/2020/09/10/mojolicious-204' | prepend: site.baseurl }}
[issue-10]: https://github.com/polettix/Bot-ChatBots-Telegram/issues/10
[WWW::Telegram::BotAPI]: https://metacpan.org/pod/WWW::Telegram::BotAPI
[ferz]: https://github.com/ferz
[Telegram bots]: https://blog.polettix.it/a-simple-telegram-bot/
[Perl]: https://www.perl.org/
