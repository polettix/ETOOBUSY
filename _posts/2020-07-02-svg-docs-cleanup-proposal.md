---
title: SVG documentation cleanup proposal
type: post
tags: [ perl, cpan, github, pull request ]
comment: true
date: 2020-07-02 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where I opened a documentation pull request towards [Perl][] module
> [SVG][].

I was looking for a module to deal with SVG files in [CPAN][] and I
obviously stumbled upon [SVG][].

Although I was looking for a module to *read* SVG files, I was actually
lucky to land on [SVG][] because it pointed to [SVG::Parser][] anyway,
and this latter module actually produced a [SVG][] object instance (so I
have to deal with [SVG][] anyway).

To be honest, I first opened the page for [SVG::DOM][], where I found
this example:

```perl
my $svg=new SVG(id=>"svg_dom_synopsis", width=>"100", height=>"100");
...
```

This started itching a bit, because the [Indirect Object Syntax][] "*is
discouraged as it can confuse the Perl interpreter*" and, as a matter of
fact, version 5.32 of [Perl][] (here the [release
notes][perl5320-delta]) introduced a new option for module [feature][]
to explicitly disable it and ease the parser's life (it is called
[indirect][], of course).

The I moved to the main documentation for [SVG][], and found this:

```text
See the other modules in this distribution: SVG::DOM, SVG::XML, SVG::Element,
SVG::Parser, SVG::Extension
```

But... [SVG::Parser][] is no more a module in *this* distribution, it
lives in its own. I'm starting to feel a urge to scratch...

Last, this module comes from a time when there was a company providing
commercial support for SVG with [Perl][] (maybe more than one). I don't
know what happened to these companies (I hope the best!), but those
links don't work any more. This itch is unbearable now!

It's like you are in a beatiful garden and you see a few bits of litter
around. Nobody left them there on purpose: you can see it's been the
joint work of time and some wind. Cleaning up a bit seems the right
thing to do, doesn't it?

So... inspired by [MANWAR][] the Mighty Pull Requester (who is also the
latest person to have released the [SVG][] module, by the way), I
resolved to propose a [pull request][] - I hope I didn't miss anything
😅


[Perl]: https://www.perl.org/
[SVG]: https://metacpan.org/pod/SVG
[SVG::Parser]: https://metacpan.org/pod/SVG::Parser
[SVG::DOM]: https://metacpan.org/pod/SVG::DOM
[CPAN]: https://metacpan.org/
[GitHub]: https://www.github.com/
[Indirect Object Syntax]: https://perldoc.perl.org/perlobj.html#Indirect-Object-Syntax
[perl5320-delta]: https://perldoc.perl.org/5.32.0/perl5320delta.html
[feature]: https://metacpan.org/pod/feature
[indirect]: https://metacpan.org/pod/feature#The-'indirect'-feature
[MANWAR]: http://www.manwar.org/
[pull request]: https://github.com/manwar/SVG/pull/12
