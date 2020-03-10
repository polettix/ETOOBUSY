---
title: ssh and LD_IDENTIFICATION
type: post
tags: [ ssh, security ]
comment: true
date: 2020-03-10 07:00:00 +0100
preview: true
---

**TL;DR**

> Where we talk about ssh, a shared account in the lab and how to still get
> some personalization.

Sometimes I log in a lab host through a shared account. I know it's not the
best practice in the world, but at the end of the day it's indeed a *lab*
host, where speed of solving problems takes precedence over tight security
and rigid processes.

I'm not young any more, and I had my first ventures with the command line
using DOS. So, for example, I use `dir` to view the list of files in a
directory, and I like to get all the details, like `ls -l` does. Which
brings me to type this over and over:

```shell
$ alias dir='ls -l'
```

In my hosts, this is called from `~/.bashrc` so I don't need to type it
every time. When logging in a shared account, though, I don't have it and I
also don't want to clutter everyone's space with this alias.

My first step is to put a function like the following in `~/.bashrc`:

```shell
polettix() {
   alias dir='ls -l'
   # other personal customizations...
}
```

I use a *function name* that would not clash with something meaningful and
it's clearly tied to me. This means that I can call the function after
logging in, and get all my customizations in one shot.

But.

Why should I type this command every time? My next mental stop is to have
the system do this for me. My initial thought was to set an environment
variable and use it in `~/.bashrc`, like this:

```shell
if [ -n "$IS_POLETTIX" ] ; then
   alias dir='ls -l'
   # ...
fi
```

Alas, this does not work as expected in the general case, because `sshd` (in
[OpenSSH][], at least) does not allow (by default) to carry whatever
environment variable you set, for security reasons. Bummer!

There is still *some* hope anyway. A few environment variables related to
the *locale* are *usually* let through, so... why not leverage one of
them?!? These variables begin with `LC_`, here's a list I got in my system:

```
LC_CTYPE
LC_NUMERIC
LC_TIME
LC_COLLATE
LC_MONETARY
LC_MESSAGES
LC_PAPER
LC_NAME
LC_ADDRESS
LC_TELEPHONE
LC_MEASUREMENT
LC_IDENTIFICATION
LC_ALL
```

I guess most of them aren't really used if not by some program I don't have,
and I'm particularly intrigued by `LC_IDENTIFICATION` because it resonates
so well with what I want to do! So here's how the thing is modified:

```shell
if [ "$LC_IDENTIFICATION" = 'polettix' ] ; then
   alias dir='ls -l'
   # ...
fi
```

Now that this should (normally) get through, we can set things up
client-side. On reasonably recent versions of [OpenSSH][] (the client), the
configuration file supports the `SetEnv` variable, so the configuration
would look something like this:

```
Host foobar
   HostName foobar.example.com
   IdentityFile ~/.ssh/id_rsa-foobar
   SetEnv LC_IDENTIFICATION=polettix
```

If you have an older version, the trick is to use `SendEnv` instead, but at
this point you should set the `LC_IDENTIFICATION` variable in your shell:

```
Host foobar
   HostName foobar.example.com
   IdentityFile ~/.ssh/id_rsa-foobar
   SendEnv LC_IDENTIFICATION
```

which is a but of a bummer if you want to set it and forget it because it
will be one value only. It's life.

[OpenSSH]: https://www.openssh.com/
