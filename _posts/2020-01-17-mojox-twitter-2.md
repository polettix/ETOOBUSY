---
title: Tweets from a user
type: post
tags: [ mojolicious, perl, web, client, twitter ]
comment: true
date: 2020-01-17 00:01:02 +0100
---

**TL;DR**

> In our quest to fetch a whole thread of tweets via the [Twitter API][],
> this stop we get all tweets following a specific one.

You already know it: we know how to [Scrape a Thread of Tweets][] but we
want to do the same using the [Twitter API][]. It's not difficult but also
not totally straightforward, so let's start with a simpler problem: getting
all tweets that were posted by a specific user starting from one of our
choice.

## We start with some boilerplate

Well, we can just copy some of our latest post about [using
MojoX::Twitter][mojox-twitter-post] and adapt it a bit for starters:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use Mojo::JSON 'j';
use Mojo::File 'path';
use MojoX::Twitter;

my $id = shift // '1215710451343904768';

my $credentials = j path('twitter-credentials.json')->slurp;
my $client      = MojoX::Twitter->new(
   consumer_key        => $credentials->{'api-key'},
   consumer_secret     => $credentials->{'api-secret-key'},
   access_token        => $credentials->{'access-token'},
   access_token_secret => $credentials->{'access-token-secret'},
);
my $tweets = get_tweets_since($client, $id);
say j $tweets;

sub get_tweets_since ($client, $id) {...}
```

It's pretty basic: the starting tweet's id can be optionally provided on the
command line, defaulting to the one that got all of this started (see
[Scrape a Thread of Tweets][]).

The client object is created exactly as in [Getting started with
MojoX::Twitter][mojox-twitter-post], although this time we delegate to a sub
(`get_tweets_since`) the job of retrieving all tweets since that specific
identifier, including the very tweet. After we get this, we turn it into a
JSON string (via function `j` from [Mojo::JSON][]) and print it (via `say`).

## Getting all tweets

The [Twitter API] has a (remote) method to get all tweets in a user's
timeline, i.e. [`GET statuses/user_timeline`][statueses-user_timeline]. How
to work properly with timelines is explained in [Get Tweet
timelines][ww-timelines], which is an interesting reading.

The bottom line is that:

- you start getting the latest tweets in the user's timeline, going
  backwards in time and getting at most 200 tweets per request;
- to go back in time, you provide parameters to put a boundary;
- when you hit the identifier of the *original* tweet you stop.

The two key parameters to do this *windowing* are `since_id` and `max_id`.

The former is probably the easier to understand: `since_id` tells the API to
only include tweets that came *strictly after* the specific identifier. In
our quest for a thread this is good, because for sure there are no
interesting tweets in a thread *before* the initial tweet!

The `max_id` parameter requires some care. As we anticipated, the [Twitter
API][] works backwards, so we can use `max_id` to set an upper boundary to
the tweets we are interested into (i.e. we don't want anything *strictly
after* `max_id`).

Let's see some code:

```perl
 1 sub get_tweets_since ($client, $id) {
 2    my $tweet = $client->request(    # needed to get the user
 3       GET => "statuses/show/$id",
 4       {tweet_mode => 'extended'}
 5    );
 6    my @tweets;
 7    my %options = (
 8       user_id    => $tweet->{user}{id},
 9       since_id   => $id,
10       count      => 200,                  # max value possible
11       tweet_mode => 'extended',
12    );
13    while ('necessary') {
14       my $chunk =
15       $client->request(GET => 'statuses/user_timeline', \%options);
16       my @chunk = sort { $a->{id} <=> $b->{id} } $chunk->@*;
17       pop @chunk if exists $options{max_id};    # remove duplicate
18       last unless @chunk;                       # no more available
19       $options{max_id} = $chunk[0]{id};         # remark for next iteration
20       unshift @tweets, @chunk;                  # older ones in front
21    } ## end while ('necessary')
22    unshift @tweets, $tweet;                     # the starting one...
23    return \@tweets;
24 } ## end sub get_tweets_since
```

First of all, we have to get the initial tweet. This is necessary because
this also allow us to fetch the specific *user* of the tweet and peruse the
`user_timeline` of associated to the *user*'s identifier.

Hash `%options` contains all parameters that we will pass in our successive
calls to the `statuses/user_timeline` endpoint. The first iteration we are
only setting `since_id` (i.e. the lower bound) but not `max_id`, which means
that we will get the most recent available tweets.

The result of the call is an anonymous array that we "store" as `$chunk`.
Immediately after we unroll it into array `@chunk`, sorting by `id` on the
fly. It's not entirely clear whether this sorting is really needed or not,
let's just do this to be on the safe side.

One tricky thing about `max_id` is that the tweet with `max_id` is included
in the result. We get it from the lowest identifier found in the iteration
(line 19), so if `%options` contains it then it would be a duplicate. This
accounts for line 17 where we pop it away, which happens only starting from
the second iteration, because `$options{max_id}` is not set when the test in
line 17 is performed during the first iteration.

If `@chunks` remains empty after removing the duplicate tweet, then our
backwards iteration has come to an end and we can stop the loop (line 18).

Tweets in `@chunk` are put in the overall array `@tweets` considering that
they are ordered and are also received from the most recent to the older
one. For this reason we use `unshift` in line 20.

Last, remember that `since_id` selects only tweets *strictly after* it? If
we are interested into that tweet, then, we have to add it explicitly as the
first item in `@tweets`, which we do  in line 23.


## Putting it all together

The following snippet contains the whole code:

<script src="https://gitlab.com/polettix/notechs/snippets/1930733.js"></script>

There is also a [local version][local-code] if the above snippet from
[GitLab][] is not working.

If you have a comment please leave it below, until next time happy hacking!

[Scrape a Thread of Tweets]: {{ '/2020/01/14/scrape-tweets-thread' | prepend: site.baseurl | prepend: site.url }}
[Twitter API]: https://developer.twitter.com/
[mojox-twitter-post]: {{ '/2020/01/16/mojox-twitter' | prepend: site.baseurl | prepend: site.url }}
[Mojo::JSON]: https://metacpan.org/pod/Mojo::JSON
[statuses-user_timeline]: https://developer.twitter.com/en/docs/tweets/timelines/api-reference/get-statuses-user_timeline
[ww-timelines]: https://developer.twitter.com/en/docs/tweets/timelines/guides/working-with-timelines
[local-code]: {{ '/assets/code/mojox-get-tweets-since.pl' | prepend: site.baseurl | prepend: site.url }}
[GitLab]: https://gitlab.com/
