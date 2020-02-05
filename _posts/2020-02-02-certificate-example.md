---
title: Example on Certificates
type: post
tags: [ security, openssl, docker ]
comment: true
date: 2020-02-02 16:36:07 +0100
published: true
---

**TL;DR**

> In the recent posts we discussed certificates a bit. Curious to try that
> suff out? There's a [Docker][] image for that!

<script id="asciicast-297368" src="https://asciinema.org/a/297368.js" async></script>

If the recent posts about certificates ([Bare-bones Root CA][], [Bare-bones
Web Server][] and [Intermediate CAs are hard!][]) tickled you, you're just a
`docker pull` command away from trying all that stuff out. You remember
about [Try with Docker][], do you?

Let's take a look:

```shell
$ docker pull polettix/certificate-example
Using default tag: latest
latest: Pulling from polettix/certificate-example
...
Status: Downloaded newer image for polettix/certificate-example:latest
```

To avoid any kind of bloat, let's start the container with option `--rm` so
that the container will be reaped as soon as we will have ended:

```shell
$ docker run -it --rm polettix/certificate-example:latest
```

Now we are inside the container, the first example is in directory `simple`:

```shell
7b38b2c7b269:/app# cd simple
7b38b2c7b269:/app/simple# ls -l
total 12
-rwxr-x--x    1 user     user           427 Feb  2 10:17 root-ca.sh
-rwxr-xr-x    1 user     user           786 Feb  2 10:17 setup.sh
-rwxr-xr-x    1 user     user           121 Feb  2 10:17 start-server.sh
7b38b2c7b269:/app/simple# ./setup.sh 
Generating a RSA private key
...........+++++
...........................................................................................+++++
writing new private key to 'rca.key'
-----
Generating a RSA private key
...................................................................................................................................................................+++++
...................+++++
writing new private key to 'srv.key'
-----
Signature ok
subject=/CN=srv.example.com/C=IT/ST=RM/L=Roma/O=Everish/OU=Server
Getting CA Private Key

Ready. Now:

- run tmux
- <CTRL-B "> to split the terminal in two
- in one half, run `./start-server.sh`
- <CTRL-B DOWN-ARROW> to move onto the other half
- run `curl --cacert rca.crt https://srv.example.com:3000/`
```

The rest is better executed inside `tmux`, which is included inside the
terminal. Just follow the hints above!

There's another directory with the example of the... *wrong* way to do the
intermediate CA, just jump into `wrong-intermediate` and you will know what
to do.

Cheers!


[Docker]: https://www.docker.com/
[Bare-bones Root CA]: {{ '/2020/01/30/bare-bones-root-ca' | prepend: site.baseurl | prepend: site.url }}
[Bare-bones Web Server]: {{ '/2020/01/31/bare-bones-web-server' | prepend: site.baseurl | prepend: site.url }}
[Intermediate CAs are hard!]: {{ '/2020/02/01/intermediate-cas-are-hard' | prepend: site.baseurl | prepend: site.url }}
[Try with Docker]: {{ '/2020/01/21/try-with-docker' | prepend: site.baseurl | prepend: site.url }}
