---
title: Certificate example on GitHub
type: post
tags: [ security, openssl, github ]
series: Playing with CAs
comment: true
date: 2020-02-10 00:00:01 +0100
published: true
---

**TL;DR**

> After a bit of polishing I put the code for
> [polettix/certificate-example][] in a proper [GitHub][] [repository][].

And this is really all there's to it. If you want to know more about
[polettix/certificate-example][]:

- it's a [Docker][] image to experiment with [OpenSSL][]
- you can find more about it in [Example on Certificates][], [Intermediate
  CA Solution][] and [Certificate example now with ekeca][].

History starts with the setup to generate the image since version 1.3.0.

Cheers!

[polettix/certificate-example]: https://hub.docker.com/repository/docker/polettix/certificate-example
[GitHub]: https://github.com/
[repository]: https://github.com/polettix/certificate-example
[Docker]: https://www.docker.com/
[OpenSSL]: https://www.openssl.org/
[Example on Certificates]: {{ '/2020/02/02/certificate-example' | prepend: site.baseurl | prepend: site.url }}
[Intermediate CA Solution]: {{ '/2020/02/07/intermediate-ca-solution' | prepend: site.baseurl | prepend: site.url }}
[Certificate example now with ekeca]: {{ '/2020/02/09/ekeca-in-example' | prepend: site.baseurl | prepend: site.url }}
