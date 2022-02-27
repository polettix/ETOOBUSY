---
title: Run an OpenSSH server as a regular, unprivileged user
type: post
tags: [ ssh, OpenSSH, security ]
comment: true
date: 2022-02-27 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> It's easy to run `sshd` as a regular user.

It's not wonder I'm looking at [Gitolite][] and I'm using the SSH part
of it. It seems the most straightforward to set up, at least for me,
involving no other software/configuration.

As it relies on SSH, it relies upon the presence of a SSH server, which
for me means relying upon [OpenSSH][].

It usually runs with `root` privileges, mostly because it needs to bind
to port 22 (which is below 1024, which means it's privileged). As I
don't like it, I've looked around to see how to avoid doing this.

Well, maybe the SSH alternative **does involve** other
software/configuration in the end 🙄

I'd like to give credits to [SOLVED: Run SSHD as non-root user (without
sudo) in Linux][] for giving me the right hints. The suggestions work
well, as it is demonstrated by the fact that [gitolite-dibs][] produces
a container that is run as an unprivileged user without any specific
tweaking. Yay!

You're encouraged to read the tutorial, of course, as I want to give due
credits for the help I received. Anyway, the *TL;DR* is more or less the
following:

- arrange your own configuration file (e.g. [`sshd_config`][])
- make sure to bind to an unprivileged port (e.g. I use port `22022` in
  [`sshd_config`][])
- generate the appropriate *host keys* with `ssh-keygen` end point them
  from the configuration file
- set everything readable/writeable/possibly executable only by the
  owner and exclude everything else for anybody else (including group).

I hope it helps!

[Perl]: https://www.perl.org/
[gitolite-dibs]: https://gitlab.com/polettix/gitolite-dibs
[Docker]: https://docker.com/
[Kubernetes]: https://kubernetes.io/
[Gitolite]: https://gitolite.com/gitolite/index.html
[registry]: https://gitlab.com/polettix/gitolite-dibs/container_registry/
[dibs]: https://github.com/polettix/dibs
[Gitolite - a dibs repository]: {{ '/2022/02/21/gitolite-dibs/' | prepend: site.baseurl }}
[OpenSSH]: https://www.openssh.com/
[SOLVED: Run SSHD as non-root user (without sudo) in Linux]: https://www.golinuxcloud.com/run-sshd-as-non-root-user-without-sudo/
[`sshd_config`]: https://gitlab.com/polettix/gitolite-dibs/-/blob/main/src/sshd_config
