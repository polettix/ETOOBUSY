---
title: Private git repos (some thoughts)
type: post
tags: [ git ]
comment: true
date: 2022-07-03 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some thoughts about keeping private git repos.

I started using [Git][] some time ago, when public hosting sites for
repositories were not very popular. I used the venerable [repo.or.cz][],
where I still have [a few repos][], apparently.

At the time, though, I did not like having everything so widely
available, as I do now anyway. Mostly for paranoia reasons, you know.
Anyway, I kept a few repos in a VPS and it suited perfectly to these
*privacy* needs.

I recently added two-factor authentication on that VPS (see
[Two-factors authentication with OpenSSH][]), which now means that every
push to those repos requires a verification token. This is not *too*
annoying, because it happens seldom, but still it triggered the need to
find a solution for a problem that does not exist.

I thought about a couple ways to address this (beyond typing the dang
code, I mean):

- change how 2FA is done, and see if it's possible to tie it to the SSH
  key instead of the whole account;
- move the repos under a different user, where 2FA is *not* enabled but
  where actions are restricted to interacting with the [Git][] repos.

Now this *of course* means that the [Git][] repos would not get the
benefit of 2FA. Are they really *less* valuable to me than access to the
server? Am I really sure about it?!?

If the answer is yes, the first approach would probably mean that I'd
have to ditch the PAM configuration described in [Two-factors
authentication with OpenSSH][] and think about fiddling with commands in
`~/.ssh/authorized_keys`. Do I really want to venture in this unexplored
land? It might be an interesting journey, and I might learn a few things
on the way, with the risk of *learning them the hard way* though.

The second approach is much safer, as there already exist systems around
that provide programs to restrict operations to [Git][]. I can't say
they are perfect, but at least they've been used and looked by many more
people than... me only. The only drawback I see in this approach is that
I would have to change the `remote` configuration for all clones. Not a
big deal, anyway.

Which makes me think that it might be useful to define *two* (or more)
configurations in `~/.ssh/config` from now on, like this:

```
Host vps
   Hostname vps.example.com
   User urist
   IdentityFile ~/.ssh/id_rsa
Host vps-git
   Hostname vps.example.com
   User urist
   IdentityFile ~/.ssh/id_rsa
```

They're identical, but they would be used in different scenarios (remote
shell and [Git][] access, respectively). This would associate `vps-git`
to all clones, and it would then be easy to change afterwards, like
this:

```
Host vps
   Hostname vps.example.com
   User urist
   IdentityFile ~/.ssh/id_rsa
Host vps-git
   Hostname vps.example.com
   User gituser
   IdentityFile ~/.ssh/id_rsa-gituser
```

OK, enought rambling for today... stay safe!

[Git]: https://www.git-scm.com/
[repo.or.cz]: https://repo.or.cz/
[a few repos]: https://repo.or.cz/projlist.cgi?name=1f34fd19efd04f944b9db5d053afab57
[Two-factors authentication with OpenSSH]: {{ '/2022/06/26/ssh-2fa/' | prepend: site.baseurl }}
