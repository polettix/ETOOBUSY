---
title: 'App::Easer gets DWIM-mer'
type: post
tags: [ perl, client, terminal ]
series: 'App::Easer'
comment: true
date: 2021-11-28 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> There are a couple new options in [App::Easer][].

I worked on a small application to retrieve data from a few sources and
merge them together to provide a unified view and possibly spot issues
of synchronization. I called this application `quis` (which is latin for
`who`, usually in a question - you can imagine what the application does).

I want the application to provide sub-commands for different specific
tasks (e.g. logging in/out of different systems, etc.), although most of
the times I use *one* specific subcommand that does the
retrieval-and-merging operation (this is sub-command `all`). This means
that a typical session would be something like this:

```shell
$ quis login

# repeated many times...
$ quis all foo.bar           # identifier type #1
$ quis all baz.galook        # ditto
$ quis all 12389             # identifier type #2
$ quis all ABCDEF80A01P023K  # identifier type #3
# you get the idea... 

$ quis logout
```

All those `all` allegedly allow bore to rise (allegorically), so I
want something like this instead:

```shell
$ quis login

# repeated many times...
$ quis foo.bar           # identifier type #1
$ quis baz.galook        # ditto
$ quis 12389             # identifier type #2
$ quis ABCDEF80A01P023K  # identifier type #3
# you get the idea... 

$ quis logout
```

This sort of reminds me of [Natural Language Principles in
Perl][natural], for two reasons:

- *Local ambiguity is OK* and
- it's a terrific opportunity to bookmark that page that is so
  inspirational and always so hard for me to find on the internet. (I'll
  also write *baby perl* just for easier retrieval at some future time).

[App::Easer][] up to version `0.006` does not allow this, because it
will try to match the first word against the list of possible children
for the top level `MAIN` (implicit) command, and fail with all the
identifiers.

[Version 0.007-TRIAL][007], though, gives us [`fallback`][] and its
siblings `fallback-to` and `fallback-to-default`.

So we can set this structure:

```perl
my $app = {
    commands => {
        MAIN => {
            children => [qw< all login logout >], # as before
            'fallback-to' => 'all',   # LOOK AT THIS, MA'!
            ...
        },
        all => {...},
        login => {...},
        logout => {...},
        ...
    },
    ...
}
```

and just expect it to work, delegating to sub-command `all` whatever
command-line that cannot be resolved properly into a sub-command.

Stay safe people!




[Perl]: https://www.perl.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[natural]: http://www.wall.org/~larry/natural.html
[007]: https://metacpan.org/release/POLETTIX/App-Easer-0.007-TRIAL/view/lib/App/Easer.pod
[`fallback`]: https://metacpan.org/release/POLETTIX/App-Easer-0.007-TRIAL/view/lib/App/Easer.pod#fallback
