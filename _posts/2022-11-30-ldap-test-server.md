---
title: Online LDAP Test Server
type: post
tags: [ ldap, web ]
comment: true
date: 2022-11-30 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Kudos to the [Online LDAP Test Server][olts].

Because you might want to try out some queries and this just comes as a
handy place where to do exactly this.

I can only add that the following queries all seem to work as of... now:

```
ldapsearch -h ldap.forumsys.com -s base -w password \
    -D 'cn=read-only-admin,dc=example,dc=com' '(objectclass=*)'

# also works: gauss, euler, euclid, einstein, newton, galileo, tesla
ldapsearch -h ldap.forumsys.com -s base -w password \
    -D 'uid=riemann,dc=example,dc=com' '(objectclass=*)'
```

There's a whole lot of *things* I'd like that server to contain, just to
do proper testing of *queries* (like OUs with stuff inside), but I think
it's a good start for at least testing some initial things.

Cheers!

[olts]: https://www.forumsys.com/2022/05/10/online-ldap-test-server/
