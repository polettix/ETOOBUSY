---
title: 'Web nostalgia: MojoX::Mechanize'
type: post
tags: [ perl, mojolicious, client ]
comment: true
date: 2021-07-17 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some code that will probably remain a proof of concept.

Back when the web was simpler, the clients were dumb and [Perl][] ruled
as the server frontend, interfaces were IMHO more clearly defined and
somehow *standardized*.

I mean, you knew that a *form* would look like more or less the same
everywhere, and you were supposed to fiddle with them in a specific way.

Then of course API *arrived* (well... they were already present of
course) and it *seemed* easier, because the programmer had not to fiddle
with broken HTML any more, trying to figure out how to automate a web
form initially designed for humans.

But this, actually, doomed the fate of this very kind of automation,
where users have to jump through multiple hoops to get some job done,
while not having available a simple API to automate it. Add to this that
a whole lot of the processing moved client side thanks to Javascript...
and your low carbs automation diet is pretty much *spoiled*.

From a personal point of view, while I was an eager user of
[WWW::Mechanize][] in the past, I've not used that any more since a long
time. I still think that it takes a bit too much to install... although
installing it became comparatively simple as [Moose][] made its
appearance 😂

[WWW::Mechanize][] was, and still is, a hell of a module. At that time,
I think it was as good a "programmable shell browser" as it can possibly
be. It gives you easy access to the things that *matter* in the page
(programmatically speaking, at least): navigation, download of content,
handling of forms.

Today, I guess that forms have been mostly obsoleted as a technology, or
at least heavily reduced their footprint. That's why I probably don't
use it too much any more.

On the other hand... I was curious to see if there was anything similar
leveraging on [Mojo::UserAgent][] and, in general, [Mojolicious][]. My
search did not yield meaningful results.

So... I decided to give it a try, and came up with a *proof of concept*.
It currently only does navigation and links filtering/selection, but it
works. My stab at it is available [here][]. It will probably remain like
this - as I said, there's much less need today for this kind of modules
IMHO - but it's been interesting and fun! Here's the example code,
embedded [modulino style][]:

```perl
exit sub {
   $|++;

   my $ua = MojoX::Mechanize->new;
   $ua->get('https://polettix.it');
   $ua->get('https://github.polettix.it/ETOOBUSY/');
   say $ua->url;
   $ua->back;
   say $ua->url;
   $ua->back;
   say $ua->url;

   say '-' x 20;

   $ua->get('https://polettix.it/xmech');
   say $ua->success;
   say $ua->url;

   say '-' x 20;
   say $_ for $ua->find_all_links(url_abs_regex => qr{xmech});

   say $ua->find_link(url_abs_regex => qr{xmech}, n => 2)->to_abs;

   say "\nfollowing link to sibling";
   $ua->follow_link(url_regex => qr{sibling});
   say $ua->url;
   say $ua->body;
  } ->(@ARGV) unless caller;
```

The fun thing is that I didn't even touch upon forms (yet, if ever); so
far, anyway, it seems that the tools in [Mojolicious][] are pretty up to
the expectations.

Stay safe everyone!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[WWW::Mechanize]: https://metacpan.org/pod/WWW::Mechanize
[Mojo::UserAgent]: https://metacpan.org/pod/Mojo::UserAgent
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[here]: {{ '/assets/code/MojoX-Mechanize' | prepend: site.baseurl }}
[modulino style]: https://gitlab.com/polettix/notechs/-/snippets/1868370
[Moose]: https://metacpan.org/pod/Moose
