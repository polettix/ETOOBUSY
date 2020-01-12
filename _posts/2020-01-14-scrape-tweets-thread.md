---
title:  Scrape a Thread of Tweets
type: post
tags: [ Mojolicious, perl, web, client, twitter ]
comment: true
date: 2020-01-14 08:00:00 +0100
published: false
---

**TL;DR**

> Scraping a whole thread of tweets into a data structure (e.g. JSON) might
> be easier than you think if you **don't** use the [Twitter API][].

Some days ago I was reading through my [Twitter][] feed and stumbled in an
interesting *thread* by [Corey Quinn (@QuinnyPig)][QuinnyPig], this is where
it starts:

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Okay. For every retweet this gets (TO A POINT!) I&#39;ll add a thought / tip / observation about speaking at conferences.</p>&mdash; Corey Quinn (@QuinnyPig) <a href="https://twitter.com/QuinnyPig/status/1215710451343904768?ref_src=twsrc%5Etfw">January 10, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script> 

The thread is very interesting as it contains tweet-sized suggestion about
speaking in public and the like. I was intrigued by the idea to have some
kind of automatic "suggestion of the day" somewhere, e.g. provided by a
[Telegram][] bot. Of course, I would have to get all the suggestions in a
suitable place/format before going on, so here we are.

## The slow, clean and correct way

Not much to say, the *slow*, *clean* and *correct* way to get the thread
of tweets would be consuming the [Twitter API][].

Alas, it's not straightforward as you're required to apply for credentials,
answer a bunch of questions and *wait for approval*. So yes I did that, but
I'm waiting.

Just as a side note, one question you have to answer is whether your
application or output data will be available to *the government*. As I code
mostly open source stuff that anybody can take from [GitHub][], and not
knowing *which specific government they're talking about*, I thought it fair
to just state that yes, it will be available to *the government*. I'm not
sure that's what they meant, but words have a meaning, folks.

## The quick, dirty and brittle way

So I'm back at square one, wanting to get hold on that thread before the
world crumbles (which I think we should fear much these days). What to do
about it?

I remembered that there are apps (actually, [Twitter][] bots too) that allow
you to produce a page out of a thread of tweets. The first one I stumbled
upon is [Thread reader][], which happily contains [the whole thread as a
page][the-thread]. (For good measure, I also saved that page [locally][]).
So why not scrape the thread from there?

Before going on, a word of caution. This way is:

- *quick*, because we just have to read data from a page;
- *dirty*, because using the [Twitter API][] is the clean way to do this;
- *brittle*, because the structure of the page in any of those thread
  unrolling applications/bots is subject to change at the developer's will
  and likely to break everything I'm writing here without notice.

You have been warned.

### The page structure

It turns out that the [Thread reader][] application output is extremely
scrape-friendly: all tweets in a thread are put in their own individual
`div` block, each of them with a unique identifier of the form `tweet_N`
(`N` here indicates the sequence number of the tweet in the thread, i.e.
`1`, `2`, and so on).

For example, this is the very first tweet:

```
<div id="tweet_1" data-screenname="QuinnyPig" data-tweet="1215710451343904768" class="content-tweet allow-preview" dir="auto">
Okay. For every retweet this gets (TO A POINT!) I'll add a thought / tip / observation about speaking at conferences.
<sup class="tw-permalink"><i class="fas fa-link"></i></sup>
</div>
```

Anything that allows us to traverse the page's [Document Object Model][DOM]
(or *DOM* as a shorthand) will be fine!

### A script to scrape it

The following script scrapes the tweets out of the page:

<script src="https://gitlab.com/polettix/notechs/snippets/1929163.js"></script>

In case you don't see the script above, you can find a [local version
here][].

The script itself is fairly straighforward. After the boilerplate to import
all relevant helpers from the excellent [Mojo][] web development toolkit
(part of the [Mojolicious][] distribution), we first make sure to get the
page's DOM, either from a locally saved copy, or directly from the URL
(either one provided as a command-line parameter):

```perl
my $ua    = Mojo::UserAgent->new;
my $input = shift @ARGV;
my $dom =
    $input =~ m{\A https?:// }imxs
  ? $ua->get($input)->result->dom
  : Mojo::DOM->new(Mojo::File->new($input)->slurp);
```

Then, we collect all tweet's contents in a `@tweets` array, iterating over
the DOM and looking for all `div` blocks that have an identifier that starts
with the string `tweet_`:

```perl
my @tweets;
$dom->find('div[id^=tweet_]')->each(sub { push @tweets, $_[0]->content });
```

The chaining interface is so nice.

Last, we only have to print out the JSON encoding of the array:

```perl
say j \@tweets;
```

And this is really all!

## This was the first step

Of course this step only allowed me to get the right data in some
*structured* way that I can later use in my bot. Which will be - hopefully -
material for additional posts in the future.

In the meantime, please let me know what you think in the comments below!


[Twitter API]: https://developer.twitter.com/
[Twitter]: https://twitter.com/
[QuinnyPig]: https://twitter.com/QuinnyPig
[Telegram]: https://telegram.org/
[GitHub]: https://github.com/
[Thread reader]: threadreaderapp
[the-thread]: https://threadreaderapp.com/thread/1215710451343904768.html
[locally]: {{ '/assets/other/QuinnyPig-tweets-on-presenting.html' | prepend: site.baseurl | prepend: site.url }}
[DOM]: https://dom.spec.whatwg.org/
[local version here]: {{ '/assets/code/scrape-tweets-thread' | prepend: site.baseurl | prepend: site.url }}
[Mojo]: https://metacpan.org/pod/Mojo
[Mojolicious]: https://metacpan.org/pod/Mojolicious
