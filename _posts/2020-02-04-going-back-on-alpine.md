---
title: Going Back on Alpine Linux 3.6
type: post
tags: [ linux, alpine, docker ]
comment: true
date: 2020-02-04 20:25:37 +0100
preview: true
---

**TL;DR**

> While writing another post, I stumbled upon a change in [Alpine Linux][]
> 3.7 that forced me to go back to 3.6, or I couldn't prove my point.

In previous post [Intermediate CAs are hard!][] I promised to follow-up with
an investigation of what goes wrong in the certificates chain. So I set up a
[Docker][] image in [Example on Certificates][] to prove the point in a
repeatable way, if anyone (read: most probably future me) is interested.

Fact is that what I had previously experienced - which also set me on the
right path to the solution - didn't happen in the Docker image I generated
(which is still available for historical reasons, by the way, as
`polettix/certificate-example:20200202-232014-29867`).

So... an investigation inside the investigation! It turns out that moving
from [Alpine Linux][] 3.6 to 3.7, the installation of the [OpenSSL][]
package puts completely different configuration files in place, in a manner
that the issue I wanted to show is not visible any more (still there,
though!).

So... I reverted back to version 3.6, and generated the image that is
available now on [Docker Hub][] (which is [here][dimage], currently
available as `polettix/certificate-example:1.1.0`).

Sometimes you have to go back to go forward!


[Alpine Linux]: https://www.alpinelinux.org/
[Intermediate CAs are hard!]: {{ '/2020/02/01/intermediate-cas-are-hard' | prepend: site.baseurl | prepend: site.url }}
[Example on Certificates]: {{ '/2020/02/02/certificate-example' | prepend: site.baseurl | prepend: site.url }}
[Docker]: https://www.docker.com/
[OpenSSL]: https://www.openssl.org/
[Docker Hub]: https://hub.docker.com/
[dimage]: https://hub.docker.com/repository/docker/polettix/certificate-example
