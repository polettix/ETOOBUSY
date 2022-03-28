---
title: Secrets in Git
type: post
tags: [ git ]
comment: true
date: 2022-03-28 23:27:11 +0200
mathjax: false
published: true
---

**TL;DR**

> Storing secrets in a [Git][] repository is still not fully solved in
> my opinion.

I know, I know. Secret stuff do not belong to code, but to
configuration, so they have no place in a source code versioning system.

But [Git][] can be much more, including helping out track configurations
in a system to allow for controlled evolution of... configurations. When
this is the case, *secrets* might be one of the things that should
belong into the repository.

Locally this makes sense: if the secret is there, why shouldn't the
`.git` sub-directory contain it? But at this point we would lose the
capability of [Git][] of replicating stuff in a central location for
ease of backup, evolution, whatever.

Now there can be a phylosophical approach where the stuff in this
central repository belong to the same security perimeter as the one for
the system we're storing the configurations and secrets for, or even
something more *core*.

Another case is that we don't or can't, which pushes to find ways to
store these secrets *securely* in the repository, i.e. encrypting them
before storing them.

Project [git-secret][] aims at solving this problem, and it's a good
help. In my opinion, though, it still feels like a half-baked solution,
because of a couple of shortcomings:

- some sub-commands only work by decrypting stuff, which is fair of
  course but also require that the encryption includes a full keypair in
  the place that does the encryption. This assumption might not be true
  in some setups
- It's not easy to track changes to the plaintext files, because they're
  explicitly ignored. This is correct from a security point of view, but
  somehow defeats the use of a SCM.
- Connected to be bullet above, it's not clear what a best practice for
  refreshing the encrypted data should be. There is a vague suggestion
  to always do this at every commit, but there's no clear example and I
  think this is on purpose.

*So OK, there's some software and it can use some enhancements. It's
open source baby, why don't you shut up and show us some code?*

Right, I don't have any to be honest! But I'm thinking about an approach
where the digests of the plaintext files are tracked somehow, and can be
used to figure out the status of secret stuff - including the need to
`hide`/`commit` it. I hope the ideas will reach a good point.

Incidentally, I also miss a lot *not* having [Git][] [hooks][] for
read-only stuff like - you know - `status`. I understand that I can
*wrap* the command somehow, but this seems a bit too far-reaching and
having a hook might help in my opinion.

Well, it is not the case, anyway. Stay safe folks!



[Git]: https://www.git-scm.com/
[git-secret]: https://git-secret.io/
[hooks]: https://git-scm.com/docs/githooks
