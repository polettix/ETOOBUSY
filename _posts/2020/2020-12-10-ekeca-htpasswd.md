---
title: ekeca htpasswd
type: post
tags: [ security, openssl, shell ]
comment: true
date: 2020-12-10 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Adding the `htpasswd_line` function to [ekeca][ekeca-post].

After the previous post [Basic Authentication for (nginx) Kubernetes
Ingress][], it just made sense to add a function in [ekeca-post][] to
generate [.htpasswd][]-compatible lines:

```shell
cmd_htpasswd_line() {
#H - htpasswd_line
#H       generate a htpasswd-compatible username/password line
#H
   printf '%s:%s\n' "$1" "$(openssl passwd -apr1 "$2")"
}
```

Note that I'm being very *crude* here, requiring that the password is
provided as a positional argument, with the possibility that the password
can leave visible traces. After all, anyway, [ekeca][] is mostly meant as a
quick'n'dirty study tool, so you have to use it with a grain of salt.


[Basic Authentication for (nginx) Kubernetes Ingress]: {{ '/2020/12/09/k8s-ingress-basic-authentication/' | prepend: site.baseurl }}
[ekeca-post]: {{ '/2020/02/08/ekeca' | prepend: site.baseurl }}
[ekeca]: https://github.com/polettix/ekeca
[.htpasswd]: https://en.wikipedia.org/wiki/.htpasswd
