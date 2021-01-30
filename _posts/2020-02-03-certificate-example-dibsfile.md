---
title: Generating "Example on Certificates"
type: post
tags: [ security, openssl, docker, dibs ]
series: Playing with CAs
comment: true
date: 2020-02-03 01:39:01 +0100
published: true
---

**TL;DR**

> Curious how the [Docker][] image [polettix/certificate-example][],
> referred in [Example on Certificates][], was generated? I used [dibs][]
> with a possibly overkill [configuration file][].

<script src="https://gitlab.com/polettix/notechs/snippets/1935716.js"></script>

[Local version here][].

As anticipated, the *dibsfile* is possibly overkill, but it allows doing
modifications and re-generation of images very, very quickly.

Additionally, the file is *refactored* so that the duplication of actions is
very low. This adds to the complexity, but also to the readability in my
very humble opinion.

To use it, remember that you have to pull the *base_image* first, i.e.
`alpine:3.8` in this case:

```shell
$ docker pull alpine:3.8
```

I tried with the newer `alpine:3.9` but there seems to be issues compiling
[Net::SSLeay][] so I reverted to the previous release.

After you are done, put the file in a directory and name it `dibs.yml`, then
create a `src` sub-directory according to what explained in [dibs][]... and
you should be all set. Hopefully there will be a full repository in some
future, stay tuned!

[Example on Certificates]: {{ '/2020/02/02/certificate-example' | prepend: site.baseurl | prepend: site.url }}
[Docker]: https://www.docker.com/
[polettix/certificate-example]: https://hub.docker.com/repository/docker/polettix/certificate-example/general
[dibs]: http://blog.polettix.it/hi-from-dibs/
[configuration file]: https://gitlab.com/polettix/notechs/snippets/1935716
[Local version here]: {{ '/assets/other/2020-02-03.dibs.yml' | prepend: site.baseurl | prepend: site.url }}
[Net::SSLeay]: https://metacpan.org/pod/Net::SSLeay
