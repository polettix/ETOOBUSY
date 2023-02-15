---
title: A quick look at Skate
type: post
tags: [ terminal, charm ]
comment: true
date: 2023-02-15 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A quick look at [Skate][], from [charm.sh][].

Almost a month ago [I expressed my curiosity][post] for [charm.sh][], so
every now and then I take a look at the project.

One of the most promising elements for adding *fun and ease* to terminal
applications is [Skate][]:

> The personal key value store with a simple, powerful command line user
> interface. You can also sync it across all your machines to access
> your data anywhere. And since its Charm Cloud backed (which is totally
> self-hostable) data is encrypted end-to-end.

I was not *totally thrilled* with the *results*, although I still find
that there can be some good when a few additional pieces will be in
place.

The installation can be as straightforward as grabbing a binary (which,
in the case of Linux, is statically compiled and linked, so it has no
external dependencies apart from the kernel), so this is definitely a
big plus for portability. On the flip side, though, I don't think that
this is a tool that needs the same level of portability as the stuff
that goes into a toolbox to carry around.

The command line is surely well crafted. At the end of the day, though,
going past the excellent help system (which I love and found very
valuable), when its main use case is supposed to resolve keys to values
in a shell script, other tools can be similarly effective in a wide
range of occasions, e.g. [pass][]:

```
somefunction() {
    local value1="$(skate get "$1"@bar.baz)"
    local value2="$(pass -c bar/baz/"$1")"
    [ "$value1" = "$value2" ]
}
```

> Why [pass][]? Hold on...

The performance is not... *optimal*:

```
$ time skate get foo
bar

real	0m4.043s
user	0m0.047s
sys	0m0.165s
```

This is a [known problem][]: the *distributed access* model stores
the encryption password in a central place, protected (which is good).
Still, this encryption password is not cached locally, so *every.
single. access.* requires retrieving it.

To this regard, [pass][] enables a *distributed access* via pre-syncing
with [Git][], without suffering the same penalty and providing a robust
way of encrypting stuff out of the box.

I'd also say that [pass][]'s model is a bit ahead at the moment, as it
leverages [gnupg][] under the hood and, as an aside, protecting secret
keys with a password, which [at the moment isn't possible with
charm][unprotected-keys]. Hence, I'd turn to [pass][] for storing e.g.
access tokens for APIs in a developer's box.

There's more to it: even when supporting the protection of secret keys
with passwords/passphrases, there will be the problem to provide that
password/passphrase only once in a while in a developer's box (so that
the data at rest are protected, but the developer is not supposed to
type the password over and over to unlock it). [Gnupg][gnupg] addresses
this using [gpg-agent][], so either a similar solution, or something
different will have to be coded/debugged/exploited-then-fixed.

One thing that is very attractive of [Skate][] over [pass][] is its
*volatility*. It can be useful to keep a few snippets around, e.g. stuff
that is pasted every once in a while:

```
skate get mydata@pastes | pbcopy
```

or some configurations that can be useful to share across different
boxes. Changing the data is made very easy by just `set`ting a new
value, which is eventually catched up at the first `sync` and the old
value is gone for good.

Conclusion: I still find this an interesting piece of technology,
although I fail to find a real use case in my hobbyst workflow.

Stay safe!

[charm.sh]: https://charm.sh/
[post]: {{ '/2023/01/23/charm/' | prepend: site.baseurl }}
[Skate]: https://github.com/charmbracelet/skate
[pass]: https://www.passwordstore.org/
[known problem]: https://github.com/charmbracelet/skate/issues/21
[Git]: https://www.git-scm.com/
[unprotected-keys]: https://github.com/charmbracelet/charm/issues/107
[gnupg]: https://gnupg.org/
