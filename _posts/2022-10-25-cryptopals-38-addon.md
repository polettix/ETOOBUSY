---
title: Cryptopals 38 - New insights from a kind reader
type: post
tags: [ security, cryptography ]
series: Cryptopals
comment: true
date: 2022-10-25 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> [Challenge 38][] in [Cryptopals][] had more than I initially thought.

Although, admittedly, I already suspected it. From [Cryptopals 38 -
Offline dictionary attack on simplified SRP][c38]:

> Sometimes I wish these challenges elaborated *a bit more* on the goals
> and the morale of what's requested. You know, just to make sure that
> I'm not missing the full range of lessons.

I thought that the two main lessons were the following:

> - SRP is prone to be attacked with a dictionary attack
> - time and again, we're proven that a weak password defies any effort.

and it turns out that I was *wrong with both of them*.

Before moving on, though, kudos to [skaunov][] for both finding out what
the real point of the challenge was and, more importantly for me, for
gently notifing me about it. Writing stuff does indeed help. folks!

> You might remember [skaunov][] as the **gentle reader** who helped me
> correcting [Cryptopals 25 - Break "random access read/write" AES
> CTR][c25]!

OK, back into the topic, the first lesson should be changed like this:

- **Simplified** SRP is prone to an offline dictionary attack

As pointed out [here][], simplifying the protocol using $B = g^b$:

> [...] opens the protocol to the an active dictionary attack, carried
> out by an attacker who masquerades as a legitimate host and convinces
> Carol to make an authentication attempt.

So well... apologies to **Full** SRP for jumping to conclusions!

It turns out that it's exactly the simplificaiton that makes it possible
to do the dictionary attack that I then proceeded to describe in the
previous post.

I'd argue that it's not necessary for us (the attacker, *Sue* in the
[article][here]) to intercept the legitimate *salt* in a real exchange
between *Carla* and *Steve*, as it is one of the parameters we're
allowed to play with. At the end of the day, the protocol has the server
side send the salt to the client side, and the client to use it.

The second lesson should probably turn into this instead:

- **Full** SRP protects weak passwords from this kind of
  unauthenticated server offline dictionary attack.

I would anyway add: weak passwords are still a bad idea, as they are
prone to many other attacks (e.g. an online dictionary attack from us
towards the server). So changing my comment on this specific instance
does not really change my idea about the general approach.

Stay safe *and secure*!

[Perl]: https://www.perl.org/
[Cryptopals]: {{ '/2022/07/10/cryptopals/' | prepend: site.baseurl }}
[Challenge 38]: https://cryptopals.com/sets/5/challenges/38
[ARGON2]: {{ '/2021/06/05/crypt-argon2/' | prepend: site.baseurl }}
[c38]: {{ '/2022/10/02/cryptopals-38/' | prepend: site.baseurl }}
[skaunov]: https://dev.to/skaunov/
[c25]: {{ '/2022/09/10/cryptopals-25/' | prepend: site.baseurl }}
[here]: http://srp.stanford.edu/ndss.html#SECTION00032300000000000000
