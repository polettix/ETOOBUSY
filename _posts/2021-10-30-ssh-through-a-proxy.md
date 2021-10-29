---
title: SSH through a proxy
type: post
tags: [ OpenSSH, security ]
comment: true
date: 2021-10-30 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A setup to connect an SSH client to a destination through a web proxy.

Networks are partitioned, and this is a Good Thing. Sometimes it's
possible to overcome some of the restrictions, which is good to know
(it's at least good to know the limits of the fences that are in place,
anyway).

In this case, we're assuming that all traffic to the outside is allowed
through a web proxy, with the clear intent to allow... web traffic only.

Now Alice wants to connect with her laptop in the inside network to her
server in the outside network, using SSH. Which is, as we saw, forbidden
because all ports are forbidden for direct access.

In this case, Alice can try to convince the proxy to let her through
with a little effort and some help from a few programs.

The gist of this technique is to make the SSH client "proxy aware" by
means of a helper program, by means of the `ProxyCommand` option. Let's
see some examples.

# Netcat from BSD

A basic command to make it work relies on the availability of the BSD
flavor of Netcat:

```
ssh -o "ProxyCommand=nc -X connect -x $proxy_host:$proxy_port %h %p" \
    $user@$target_host
```

The variables have *sensible* names: data about proxy goes in
`$proxy_host:$proxy_port`, the rest is the usual connection details.

The `-X` has been set to `connect` in the example; it can also be set to
`4` or `5`, respectively for a SOCKS4 or SOCKS5 proxy type.

More can be found [here][post1].

# Netcat from Nmap

The BSD flavor of Netcat has options `-X` and `-x` which are not part of
the original Netcat. It turns out that the [Nmap][] flavor of Netcat
(usually named [ncat][]) has two equivalent long options, respectively
`--proxy-type` and `--proxy`:

```
ssh -o "ProxyCommand=ncat --proxy-type http --proxy $proxy_host:$proxy_port %h %p" \
    $user@$target_host
```

The hint is still [here][post1], though it's not that explicit about the
flavor of Netcat. Whatever!

Also in this case it's possible to specify a different `way
`--proxy-type` than `http` (which corresponds to using a `CONNECT`), by
setting it to `socks4` and `socks5` instead.

# Socat

There are a few programs that will always appear as too damn useful and
simple to use for me to really understand them, and [socat][] is one of
them.

It too supports going through the proxy:

```
ssh -o "ProxyCommand=socat - PROXY:$proxy_host:%h:%p,proxyport=$proxy_port" \ 
    $user@$target_host
```

It's interesting that no answer in [this post][post2] makes any
reference to Netcat... go figure.

Also in this case, there is a variant for the SOCKS4 proxy:

```
ssh -o "ProxyCommand=socat - SOCKS4:$proxy_host:%h:%p,socksport=$proxy_port" \
    $user@$target_host
```

The versions of [socat][] I had access to are all in the 1.7 series and
don't support SOCKS5 though. If one that does is available, though, this
is the command copied from the [post cited above][post2]:

```
ssh -o "ProxyCommand=socat - 'SOCKS5:%h:%p|TCP:$proxy_host:$proxy_port'"  \
    $user@$target_host
```

This appears to be supported in socat version 2 only, which I don't
have... so I'm not sure that the above line actually works. Cross
fingers!

# Saving for the future

Whatever the tool, it's possible to set the `ProxyCommand` option in the
`~/.ssh/config` file to avoid typing the option over and over:

```
Host target
   HostName target.example.com
   User foobar
   ProxyCommand ncat --proxy-type http --proxy proxy.example.com:8080 %h %p
```

This said... so long, and stay safe folks!

[post1]: https://stackoverflow.com/questions/19161960/connect-with-ssh-through-a-proxy
[socat]: http://www.dest-unreach.org/socat/
[post2]: https://unix.stackexchange.com/questions/68826/connecting-to-host-by-ssh-client-in-linux-by-proxy
[Nmap]: https://nmap.org/
[ncat]: https://nmap.org/ncat/
