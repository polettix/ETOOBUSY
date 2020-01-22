---
title: Thread of tweets via API
type: post
tags: [ Mojolicious, perl, web, client, twitter ]
comment: true
date: 2020-01-18 00:23:17 +0100
---

**TL;DR**

> We finally download a whole thread of tweets using the [Twitter API][], yay!

We have discussed a lot about getting [Twitter][] threads lately:

- [Scrape a Thread of Tweets][] shows a poor man's way of doing this by
scraping data from a page generated by an online service to unroll threads;

- [Getting started with MojoX::Twitter][mojox-twitter-post-2] introduced us to [MojoX::Twitter][], a handy module to consume the [Twitter API][];

- last, [Tweets from a user][mojox-twitter-post-2] paved the way to getting a
thread by coding a way to get all tweets since a specific one.

In particular, we're leveraging the code from the last post here!

## Filtering tweets in a thread

The following function filters an input anonymous array (such the one returned
by `get_tweets_since`) of tweets to select only those belonging to a thread:

```perl
 1 sub filter_thread ($tweets) {
 2    my @thread = ($tweets->[0]);
 3    my %in_thread = ($thread[0]{id} => 1);
 4    for my $tweet ($tweets->@*) {
 5       defined(my $rid = $tweet->{in_reply_to_status_id}) or next;
 6       $in_thread{$rid} or next;
 7       push @thread, $tweet;
 8       $in_thread{$tweet->{id}} = 1;
 9    } ## end for my $tweet ($tweets->...)
10    return \@thread;
11 } ## end sub filter_thread
```

The thread is assumed to begin at the first tweet in the array, which is
consistent with `get_tweets_since` that we introduced in [Tweets from a
user][mojox-twitter-post-2]. Hence, the first tweet is both collected in
array `@thread` (which is later returned in line 10, as an array reference)
and tracked as being `%in_thread`.

Input tweets are iterated to find interesting ones, depending on two
conditions (lines 5 and 6):

- they MUST have a defined `in_reply_to_status_id`, because follow-ups in a
  thread are always referred to some previous tweet, and
- the `in_reply_to_status_id` MUST be part of the current thread.

If this is the case, the tweet is put in the `@thread` and its identifier is
flagged as being `%in_thread`, for getting possible follow-ups later.


## The complete program

<script src="https://gitlab.com/polettix/notechs/snippets/1930737.js"></script>

See the [local version][] if the above snippet from [GitLab][] is not available.

## Wrap-up for now

Did you enjoy this tour-de-force about getting a thread of tweets? Do you
have comments? By all means use the machinery below!


[Twitter]: https://twitter.com/
[Twitter API]: https://developer.twitter.com/
[Scrape a Thread of Tweets]: {{ '/2020/01/14/scrape-tweets-thread' | prepend: site.baseurl | prepend: site.url }}
[mojox-twitter-post]: {{ '/2020/01/16/mojox-twitter' | prepend: site.baseurl | prepend: site.url }}
[mojox-twitter-post-2]: {{ '/2020/01/17/mojox-twitter-2' | prepend: site.baseurl | prepend: site.url }}
[local version]: {{ '/assets/code/mojox-get-thread.pl' | prepend: site.baseurl | prepend: site.url }}
[GitLab]: https://gitlab.com/
[MojoX::Twitter]: https://metacpan.org/pod/MojoX::Twitter