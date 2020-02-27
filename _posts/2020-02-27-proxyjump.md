---
title: ProxyJump
type: post
tags: [ security ]
comment: true
date: 2020-02-27 23:13:50 +0100
preview: true
---

**TL;DR**

> If you want to `ssh` to a host but that you can't access directly,
> `ProxyJump` can be very, very handy to pass through an intermediate
> with little hassle.

Often times, I find myself in this situation:

- I can connect to a test lab through `ssh`, usually to a specific host;
- from that host, I can access other hosts *inside* the lab, that I
  cannot reach directly.

So, if I'm interested into connecting to a host *inside*, I still have
to connect to the intermediate specific host first; we will call this
intermediate host a *jumphost* and the situation is like this:

```
+--------+   +----------+   +--------+
| laptop |-->| jumphost |-->| target |
+--------+   +----------+   +--------+
```

This is usually not a *tremendous* hassle, but (for me, at least) it
falls in that category of annoyances whose resolution is an annoyance of
about the same energy level. All in all, I just `ssh` into the
*lab-pivot*, then `ssh` to the *target* from there. It has to be said
that using `tmux` helps a lot amortizing this double ssh process,
because after the initial login I can open an indefinite number of
subshells.

This is a bit *suboptimal* when I have to transfer files: they have to
be transferred in the *jumphost*, then to the *target*. This might prove
time consuming, as well as requiring some effort if the *jumphost* does
not have too much available storage.

# How old is `ssh`?

If you happen to have a version of [OpenSSH][] that is [release-7.3][]
or later, then enter `ProxyJump`:

> Add a ProxyJump option and corresponding -J command-line flag to allow
> simplified indirection through a one or more SSH bastions or "jump
> hosts".

Let's see an example, supposing that...

- you are user `foo` on *laptop*
- you are user `bar` on *jumphost*, using key `~foo/.ssh/jumphost.key`
  stored in *laptop*
- you are user `galook` on *target*, using key `~foo/.ssh/target.key`
  stored in *laptop*

This is the most *complicated* setup, but with a little help from
`~foo/.ssh/config` we will have no problem:

```
Host jumphost
   HostName jumphost.local
   User bar
   IdentityFile ~/.ssh/jumphost.key
Host target
   HostName target.internal
   User galook
   IdentityFile ~/.ssh/target.key
   ProxyJump jumphost
```

At this point, it's as simple as:

```shell
foo@laptop$ ssh target
```

and *voilà*, we are logged into *target*.

# Then, with a key...

If you happen to use the same key for both `bar@jumphost.local` and
`galook@target.internal`, it can be even simpler! Forget about
`~foo/.ssh/config` and just use option `-J` from the command line:

```shell
foo@laptop$ ssh -i ~/.ssh/oneforall.key \
   -J bar@jumphost.local galook@target.internal
```

In a nutshell, the `-J` option allows us to specify the intermediate
*jumphost* to use, straight from the command line.

It's even simpler if the key is also your default one (usually
`~/.ssh/id_rsa`):

```shell
foo@laptop$ ssh -J bar@jumphost.local galook@target.internal
```

... and yes, if you're using the same username all over the place, then
it becomes really really easy:

```shell
foo@laptop$ ssh -J jumphost.local target.internal
```

# Summary

This was super-interesting to discover... thanks!!!

[OpenSSH]: https://www.openssh.com/
[release-7.3]: https://www.openssh.com/txt/release-7.3
