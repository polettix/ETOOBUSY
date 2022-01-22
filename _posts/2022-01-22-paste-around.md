---
title: Paste around
type: post
tags: [ web, paste ]
comment: true
date: 2022-01-22 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A few tricks about pasting online, learned during the [2021][aoc2021]
> [Advent of Code][]

Well, actually while lurking in the [Solutions Megathreads in Reddit][].

The first and foremost is a handy Javascript application that runs
directly in the browser. You paste your text in this *browser-based
application* and get a link to it.

What... what? A link to where?!? Well, to the page itself, which will
decode most of the URL itself to get the data to show. This is such a
neat trick.

The pasted text is compressed using [LZMA][], then encoded to make it
URL safe. Overall a brilliant idea, I wonder whether using [Brotli][]
would squeeze things a bit more.

This is so cool because the code isn't actually *pasted* anywhere - it's
just all there in the URL, so if you want to back it up just save the
link!

The drawback is that you end up with a very long URL. This is hardly a
problem, e.g. if you're using [Markdown][] or other ways to render links
with a text of choice. In case, anyway, you can gain a lot more
compression using a *URL shortener* service like [bitly][]. As an
example:

- some code for day 15 is available as [https://topaz.github.io/paste/#XQAAAQC3DQAAAAAAAAARiE...yMy8Z5zcslpkD/6U9WqA==][this is the same link]
which is... *a bit long*;
- [this is the same link][]
- and of course this: [https://bit.ly/3ITbxMd][]

This was not the only discovery about pasting stuff though. Thanks to
[s3aker][] I discovered [glot.io][], which not only allows pasting stuff
in a variety of syntax-highlighted languages, but also allows executing
that code!

Well, it's about time to pass past this post about  pasting! Stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[aoc2021]: https://adventofcode.com/2021/
[Advent of Code]: https://adventofcode.com/
[Solutions Megathreads in Reddit]: https://www.reddit.com/r/adventofcode/wiki/solution_megathreads
[bitly]: https://bitly.com/
[project in GitHub]: https://github.com/topaz/paste
[LZMA]: https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Markov_chain_algorithm
[Brotli]: https://en.wikipedia.org/wiki/Brotli
[Markdown]: http://daringfireball.net/projects/markdown/
[this is the same link]: https://topaz.github.io/paste/#XQAAAQC3DQAAAAAAAAARiEJHiiMzw3cPM/1Vl+2nyBVgln/fSKzB26WdEN//SuX9YfbGQAFRYp98bYMJGEktF+/60C1W3rBkiSGUsNwwTOkt0kcEVojKMZHDQc0ROjuKEPyc8WKQWtd4Ha98Z8fs0aghPyiwPPPgdt57YvCC9V4TVbp+f//0KqrZZk586DHXt4kqDuVtMiHhEgwzCak5MuM8AM6zbsYK7jffpICDvD/mY+Qm6qrwh/7COdIkl5TTf/QVj1kUEtCkARQivpOjPhwCoKmnqhk/b1ud94kdNFnHDr5u0SVHolkSGEIicxVk44kyuT1rw10/ChTGPP3BsykoR17diFOXQNGp1PXrlmYWkGbbPS/EChd1C5MgHSCAcQdO5vQZRtFvP89m5Qr671yeIyamRaHLKdcRTlL680qV2y882k2yOwpJJtzJS6sH59fzx0i7ZW8yaUHu6pUjRl7WH5JuSifZY38ELHyOt4mnuB0lDvgIAXh/r66NMW7e+CfpS5DbPna60SjzgysqpvckB0PFqfMIizMgbr8ZCSeq0TzTPqdvknNBJGEYh08tCdkNwdy7GDwbx58gXuHVoz1W+whpw3WIMhAZUQlwyFgEPqRC/czm57E+Rvs9xrLYmFSnvY0AlSmDloJUibeOHAAPrRD8qDoPvZIA0FcfpWo/Liel+KBTSPgG9PzecvH4r9tPvLhhA6OkRlJNEQyANgvwLK2cnIUNiUNBmoeqXn+uybI+a34MGOHZNXYkmmVm0TzdMm2iDrZ0OXnRuWaEZeG4eDFml+quB2Pyb4pJYG6V5MffHX9To/H+XnZL0FCDU5X246UmgSqyfUJro6B8B1rAJ6zilwyKPaNjTdVTJuXIYYjztqAl95nRPLanR7pllmnaQPiadfH58s6ayuJ0iBZTZAaZh8r/Kc0Mu8oBW3acSw35i33Rrd3mGqpFWyY5p15RLrTGYROaOuL9qwPJj0IbXsNoVth8/SZhYzfCoZqsS09z0N2O3RuqdH6A48hoYy4uyHo+wmLoLHPX79JoHE2e1L1VDv15CxxKxYGw7jld4c+vEeL43eKXIl1g+T3z5NlCDyBrMhOnosFkRcJVVzvPPwgWAsurUGSarj9FSBH0SQjrW9lDB2cifhNKW47mCnfQo2UVLZmdIbkyS0XMdnzftT6hHcwZf2op7M3Hg2dZhmMfJHtSYuwogPi5sC0w4iiy+3wNRKFHjAN96z4w6cm2kzmoAlT+CL7hcLblDQfRie3f54hsJHMd3VwnbDUe7GNalpbR2cRttf+AvGbt3m5DXCzjUcCxCpGGv6UbSXHR/fUHIUXhYj4C4VloZyqdTaDbcAel86OHu5rn6xqGG7cVGYLrWt+VqJzKOZckVWUqvNgZgYBSrc7VpQN/6M9imqQx8xg6w1gS3blf8cX0lyoRf9afwwpDvR9M1heKGfO43wkcpXzCECOKXDfaZokgV1hhDtU1gL95nogzFc4G04iGKHHcpb1Sbhf5DFJHaB/p3hPcUgIn+gQRiPOgTUtwySpQ4LbPz71c1XoBdS2bpYitNC5xgPCB6VubkHvwM7jTdut7uO3UcdedXSq1bRQdTQ9xqSn05IJjkBnM0AGl2J/7Fn39WKryl6pmI4UysBGSydlTC05r4Bv/MYSdNZ+udVy59osK5dbKmuAriX3Y2r5mgcM6vdsrUSXCd7bFHwPwgbDk02Ajlhv4qoHQHnPygSbR6XOjfCYEHc4GVJ+38lvqf1UC0MBkWFGo13zkf96lK2/lbuENbLtlQj/2C+Gp+rii6rSZrk9djM8a57RrwsWbHkJawoxvJiqlpZ3SJ0szjE/jhrJE/qGV7xTnCbYnSQ84u+Mqp5szKnyMy8Z5zcslpkD/6U9WqA==
[https://bit.ly/3ITbxMd]: https://bit.ly/3ITbxMd
[s3aker]: https://www.reddit.com/user/s3aker/
[glot.io]: https://glot.io/
