---
title: Setting environment variables in Dokku
type: post
tags: [ dokku ]
comment: true
date: 2020-06-04 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Where we take a look at setting environment variables in [Dokku][].

[Dokku][] is an amazing, minimalistic system for getting your
single, amateur programmer deployment needs out of the way effectively.
I already talked extensively about it in [Dokku - Your Tiny PaaS][].

# Setting environment variables can bite you

One thing that hit me recently is how you can set environment variables
(either globally or for a specific application). The sub command is
`config`, and in particular `config:set`, like this:

```shell
ssh $DOKKU config:set KEY='wow, a value here'
```

Yes, I'm using the low-level interface, i.e. the plain SSH connection.

It so happens that this interface is not *exactly* robust. By design
reasons which are unknown to me, the command above saves the key/value
pair in a file that can be *sourced* easily, but decides to adopt
*double quotes* for saving the thing, like this:

```shell
KEY="wow, a value here"
```

Moreover, it seems to fail *spectacularly* with newlines.

# In-house solution

If you want to be *on the safest side*, you can encode the whole thing
in a single, long, `base64`-encoded string and then set it in the
environment:

```shell
VALUE='Hello
every
body'
ssh $DOKKU config:set myapp \
    KEY="$(printf %s "$VALUE" | base64 -w 0)"
```

Note that we are passing `-w 0` to `base64`, otherwise it will
eventually insert a newline and break the whole thing again.

Then, in your code, you can decode it back:

```perl
use MIME::Base64 'decode_base64';
# ...
my $text = decode_base64($ENV{KEY});
```

This is it, totally under your control.

# Assisted solution

[Dokku][] actually assists you with the *server-side* half of the
solution in the previous section. If you pass parameter `--encoded` to
`config:set`, you'te telling [Dokku][] that the value is
`base64`-encoded and it should treat it as such, decoding before saving
the environment variable:

```shell
VALUE='Hello
every
body'
ssh $DOKKU config:set --encoded myapp \
    KEY="$(printf %s "$VALUE" | base64 -w 0)"
```

Now you have to trust that the escaping in saving the variable is done
properly, but with this you can just do this in your code:

```perl
my $text = $ENV{KEY};
```

i.e. the same as single-line simple-text stuff. Neat!


# The bottom line

If you're lazy and want to just learn **one** thing, it's that you
should *ALWAYS* set variables like this:

```shell
VALUE='...' # whatever, with newlines or not
ssh $DOKKU config:set --encoded myapp \
    KEY="$(printf %s "$VALUE" | base64 -w 0)"
```

This will work independently of how complex the `$VALUE` is and never
fail you.

Well... never say never, but you get the idea.


[Dokku]: http://dokku.viewdocs.io/dokku/
[Dokku - Your Tiny PaaS]: http://blog.polettix.it/dokku-your-tiny-paas/
