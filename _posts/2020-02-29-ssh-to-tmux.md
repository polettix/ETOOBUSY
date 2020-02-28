---
title: SSH into tmux
type: post
tags: [ toolbox, ssh, tmux ]
comment: true
date: 2020-03-01 08:00:00 +0100
published: false
---

**TL;DR**

> Sometimes an alias on the local machine can save precious tenths of
> seconds when connecting to a remote machine with [tmux][].

I sometimes connect to some host in the *inside* of a lab, passing
through an intermediate *jumphost*.

```
+--------+   +----------+   +--------+
| laptop |-->| jumphost |-->| target |
+--------+   +----------+   +--------+
```

Up to some time ago, it meant doing something like this:

```shell
foo@laptop$ ssh jumphost
bar@jumphost$ ssh target
galook@target$
```

This is a lot of typing. Additionally, sometimes the VPN would just go
away, disconnecting all precious sessions, so it didn't take long for me
to adopt [tmux][] to work around both problems. Hightly recommended as
something to put in your [#toolbox][]. So, the real interaction is
actually more like this:

```shell
foo@laptop$ ssh jumphost
bar@jumphost$ ssh target
galook@target$ tmux attach -t mysession
```

I recently became aware of a solution provided by [OpenSSH][] to the
double jump problem - see [ProxyJump][] and [ProxyCommand][] for the
details. The bottom line is that I can do this:

```shell
foo@laptop$ ssh target
galook@target$ tmux attach -t mysession
```

i.e. connect to the *target* using a single command from the *laptop*.

# We can compact more

It never occurred to me before that I can also call [tmux][] directly,
because you can pass `ssh` a command to execute. It's not exactly
straightforward though:


```shell
foo@laptop$ ssh target tmux attach -t mysession
open terminal failed: not a terminal
foo@laptop$ echo $?
1
```

The problem is that, in this case, `ssh` is not requesting the
allocation of a remote terminal, because it *thinks* that it's a
one-shot command that does not need one. It's easy to ask for a terminal
though, by means of `ssh`'s option `-t`:

```shell
foo@laptop$ ssh -t target tmux attach -t mysession
```

At this point, we can compact this into a shell alias:

```shell
alias target='ssh -t target tmux attach -t mysession'
# first attempt - we can do better - read on!
```

# What if `mysession` does not exist?

If `mysession` does not already exist in *target* as a [tmux][] session,
you'll get an error:

```shell
foo@laptop$ ssh -t target tmux attach -t my-missing-session
can't find session my-missing-session
Connection to target closed.
```

This [hint by Wesley Baugh][] hits the nail right in the head in this
case: just always ask for creation of a session with that name, but use
option `-A` to reuse any existing one with that same name:

```shell
foo@laptop$ ssh -t target tmux new -A -s my-missing-session
```

So, going back to the original example, the *right* alias would be:

```shell
alias target='ssh -t target tmux new -A -s mysession'
```

And this is it for today, cheers!

[hint by Wesley Baugh]: https://unix.stackexchange.com/a/176885/209167
[OpenSSH]: https://www.openssh.com/
[tmux]: https://github.com/tmux/tmux/wiki
[#toolbox]: {{ '/tagged/#toolbox' | prepend: site.baseurl | prepend: site.url }}
[ProxyJump]: {{ '/2020/02/27/proxyjump' | prepend: site.baseurl | prepend: site.url }}
[ProxyCommand]: {{ '/2020/02/28/proxycommand' | prepend: site.baseurl | prepend: site.url }}
