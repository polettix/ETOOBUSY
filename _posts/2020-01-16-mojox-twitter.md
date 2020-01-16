---
title: Getting started with MojoX::Twitter
type: post
tags: [ Mojolicious, perl, web, client, twitter ]
comment: true
date: 2020-01-16 07:16:47 +0100
preview: true
---

**TL;DR**

> In the quest to fetch a whole thread of tweets from [Twitter][],
> [MojoX::Twitter][] is a very promising [Perl][] module.


In previous post [Scrape a Thread of Tweets][] we left with the intention to
re-do the whole thing without scraping stuff from a web page, but leveraging
the native [Twitter API][]. This is where we start!

## Getting authorised to the [Twitter API][]

The first thing that you have to do is to [apply for a developer account][].

It will take some time to get through, especially if you're honest because
they make you questions like *will your application be available to the
government*? As someone that usually either blogs or anyway puts the crappy
code on [GitHub][polettix], yes it is available to whoever wants to use it!

They ask you questions in the application form and they will ask those
questions again via email. Don't despair, after a couple of rounds you
should be fine.


## Available [Perl][] modules

There are a couple of [Perl][] modules that seem interesting in [CPAN][]:

- [Twitter::API][]: this is an evolution of a previous module `Net::Twitter`
  and seems fairly comprehensive. If anything, it is a bit intimidating that
  the very first example `$client` in the synopsis suggests to include an
  `Enchilada`:

```perl
### Common usage ###
 
use Twitter::API;
my $client = Twitter::API->new_with_traits(
    traits              => 'Enchilada',
    consumer_key        => $YOUR_CONSUMER_KEY,
    consumer_secret     => $YOUR_CONSUMER_SECRET,
    access_token        => $YOUR_ACCESS_TOKEN,
    access_token_secret => $YOUR_ACCESS_TOKEN_SECRET,
);
...
```

- [MojoX::Twitter][]: this is advertised as a *Simple Twitter Client* and
  yes it is. Almost no documentation, apart from an example and the
  indication that it is *without OAuth authentication*. Mmmmh...


I decided to give the simpler one a try. The lack of OAuth authentication
can seem strange - every [Twitter API][] requires some kind of it - so I
figured that it was only in the spirit of the very, very concise
documentation.

Having chosen [MojoX::Twitter][], we will also have to install
[Mojolicious][] that will give us access to the [Mojo][] framework, yay!

## The example client works!

The example client seems to work, here is an adapted form:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use Mojo::JSON 'j';
use Mojo::File 'path';
use MojoX::Twitter;

my $credentials = j path('twitter-credentials.json')->slurp;
my $client      = MojoX::Twitter->new(
   consumer_key        => $credentials->{'api-key'},
   consumer_secret     => $credentials->{'api-secret-key'},
   access_token        => $credentials->{'access-token'},
   access_token_secret => $credentials->{'access-token-secret'},
);

my $user =
  $client->request(GET => 'users/show', {screen_name => 'polettix'});

say j $user;
```

The credentials are stored in a separate file `twitter-credentials.json`,
which is a simple JSON file like this:

```
{
   "api-key": "yadda",
   "api-secret-key": "yadda",
   "access-token": "yadda-yadda",
   "access-token-secret": "yadda"
}
```

The `$client->request(...)` call returns a hash reference in the case of
`users/show`, but it might return something different for other APIs. In
this example, we're just turning it (back) to JSON and printing it in the
last line. Considering that `j` prints out minified JSON, you'll probably
want to pipe it to [jq][] to read it!

## Enough for today

So this is it for today, stay tuned for the evolutions and leave a comment
if you want!

[Scrape a Thread of Tweets]: {{ '/2020/01/14/scrape-tweets-thread' | prepend: site.baseurl | prepend: site.url }}
[Twitter API]: https://developer.twitter.com/
[Twitter]: https://twitter.com/
[GitHub]: https://github.com/
[Mojo]: https://metacpan.org/pod/Mojo
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Perl]: https://www.perl.org/
[CPAN]: https://metacpan.org/
[Twitter::API]: https://metacpan.org/pod/Twitter::API
[MojoX::Twitter]: https://metacpan.org/pod/MojoX::Twitter
[apply for a developer account]: https://developer.twitter.com/en/apply
[polettix]: https://github.com/polettix/
