---
title: Try with Docker
type: post
tags: [ docker ]
comment: true
date: 2020-01-21 08:00:00 +0100
published: false
---

**TL;DR**

> Want to try out something in your Linux distro, but don't want to bloat
> your system? [Docker][] might help you doing this and get rid of the thing
> after you're done.

To experiment with a [Perl][] module requiring a system library to be
installed, I figured that I would need to install a lot of stuff in my
[Debian][] system, which I wasn't sure about:

```
$ sudo apt-get install libzbar-dev
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  yadda yadda yadda...
Suggested packages:
  yadda yadda yadda...
The following NEW packages will be installed:
  yadda yadda yadda...
The following packages will be upgraded:
  libglib2.0-0 libglib2.0-bin libicu57 libx11-6
4 upgraded, 77 newly installed, 0 to remove and 91 not upgraded.
Need to get 64.0 MB of archives.
After this operation, 193 MB of additional disk space will be used.
Do you want to continue? [Y/n]
```

Well... thanks but no thanks, I don't want all this stuff just for trying
out a few programs and then move on!

## Why not with Docker?

[Docker][] can provide the right experimenting environment to try out stuff
and then get rid of it when we're done.

In this case, I already had the image for [debian:slim-9][dockerhub-debian]
in my local Docker cache of images, so why not using it?

```
$ docker run --rm -itv "$PWD:/mnt" debian:slim-9
root@769f7f634955:/mnt# apt-get update
# ...
root@769f7f634955:/mnt# apt-get install -y libzbar-dev perlmagick
# ...
```

And voilà, the perfect environment for experimenting. When I'm done with it,
it suffices to exit from the shell *inside* the container and command line
`--rm` will make sure to get rid of everything, releasing precious
resources.

As I'm starting a shell to interact with, I'm also passing both options `-i`
(interactive) and `-t` (to allocate a tty).

Last, I'm also mapping the current directory onto path `/mnt` *inside* the
container. In this way, I can still edit files within the host system, while
running them inside the container, with the advantage of not losing those
programs when the container goes away - yay!

## Summing up

[Docker][] can provide a lot of benefits, including quick throw-away
environment to test things out. I'd suggest giving it a try!


[Perl]: https://www.perl.org/
[Debian]: https://www.debian.org/
[Docker]: https://www.docker.com/
[dockerhub-debian]: https://hub.docker.com/_/debian
