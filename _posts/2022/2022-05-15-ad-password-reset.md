---
title: ActiveDirectory password reset with LDIF
type: post
tags: [ active directory, ldap ]
comment: true
date: 2022-05-15 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> How to reset the password in ActiveDirectory with [LDIF][].

The [main source][] takes a bit too much for granted, so I'll try to put
what I learned here... hoping to do well, because I'll test it later. I
also found [Passwords using LDIF][] very enlightening, so I'll get some
examples from there.

The password in Active Directory MUST be set via attribute `unicodePwd`.

# Password format

The password can contain whatever characters, so there's the need to do
some *encoding* before fitting it in the [LDIF][].

These are the rules:

- we start from `password_string`, a string containing the password! In
  our example, it will be `newPassword`:

```
|<--             hex dump            -->|  |<--   value  -->|
|6e65 7750 6173 7377 6f72 64            |  |newPassword     |
```

- `password_string` MUST be enclosed between exactly two double-quote
  characters `"`. These will be stripped off eventually, so this
  operation is totally within the bounds of *encoding*. Let's call this
  new string `quoted_password_string`. In our example, note the
  additional `22` at the beginning and at the end of the hex dump,
  representing the double quotes:

```
|<--             hex dump            -->|  |<--   value  -->|
|226e 6577 5061 7373 776f 7264 22       |  |"newPassword"   |
```

- `quoted_password_string` is encoded in [UTF-16LE][], obtaining
  `password_utf16_string`.

```
|<--             hex dump            -->|  |<--   value  -->|
|2200 6e00 6500 7700 5000 6100 7300 7300|  |".n.e.w.P.a.s.s.|
|7700 6f00 7200 6400 2200               |  |w.o.r.d.".      |
```

> We're always aiming to keep the highest standards when doing stuff.
> Please let's always use the right way of doing encoding and resist the
> temptation to "just add a `\000` after each byte"...


- The last value `password_utf16_string` is basically a bunch of binary
  data, and we know how to fit it in a [LDIF][] file from previous post
  [LDIF binary data][]. This gets us `password_for_ldif`, which in our
  example is the printable string
  `IgBuAGUAdwBQAGEAcwBzAHcAbwByAGQAIgA=`:

```
|<--             hex dump            -->|  |<--   value  -->|
|4967 4275 4147 5541 6477 4251 4147 4541|  |IgBuAGUAdwBQAGEA|
|6377 427a 4148 6341 6277 4279 4147 5141|  |cwBzAHcAbwByAGQA|
|4967 413d 0a                           |  |IgA=.           |
```

- `password_for_ldif` is set as the value of attribute `unicodePwd`,
  making sure to use **two** colon characters `:` to indicate that the
  value we're providing is encoded in [base64][].

```ldif
unicodePwd:: IgBuAGUAdwBQAGEAcwBzAHcAbwByAGQAIgA=
```


# Reset or change?

A password reset can be done only by a properly authorized
administrator, using a `modify` operation:

```ldif
dn: CN=TestUser,DC=testdomain,DC=com
changetype: modify
replace: unicodePwd
unicodePwd::IgBuAGUAdwBQAGEAcwBzAHcAbwByAGQAIgA=
```

As regular users, we're only allowed to change our own password in two
steps, i.e. a `delete` followed by a `create`:

```ldif
dn: CN=John Smith, OU=Users,DC=Fabrikam,DC=com
changetype: modify
delete: unicodePwd
unicodePwd::HgBuAGUAdwBKLSQAGEAcwBzAHcAbwByHJE=
-
add: unicodePwd
unicodePwd::IgBuAGUAdwBQAGEAcwBzAHcAbwByAGQAIgA=
```

The `delete` MUST include the previous password to prove our identity
and get authorized to do the change.





(From [Passwords using LDIF][]).




[Perl]: https://www.perl.org/
[LDIF]: https://www.ietf.org/rfc/rfc2849.txt
[Main source]: https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/set-user-password-with-ldifde
[Passwords using LDIF]: https://ldapwiki.com/wiki/Passwords%20Using%20LDIF
[UTF-16LE]: https://en.wikipedia.org/wiki/UTF-16#Byte-order_encoding_schemes
[LDIF binary data]: {{ '/2022/05/14/ldif-binary-data/' | prepend: site.baseurl }}
[base64]: {{ '/2020/08/13/base64/' | prepend: site.baseurl }}
