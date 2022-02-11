---
title: Active Directory Bit Fields
type: post
tags: [ ldap, active directory ]
comment: true
date: 2022-02-11 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [Filtering for Bit Fields][].

I know this is supposed to be a blog and that there exist services to
keep bookmarks (e.g. [Pinboard][]), but I've found myself looking for
this lately and it's just useful.

LDAP filters can be *unflexible* at times, especially coming from a
[Perl][] (and [Raku][]!) mindset where regular expressions are such a
prominent tool in the box.

With this in mind, I was sincerely afraid when I discovered that
attribute [userAccountControl][] is a *bit field* and I wanted to look
for records matching a particular value in a particular bit. Oh my.

Then it occurred to me that, well, I *can not* be the only one to have
this need, or to ever need this at all. So... search engines to the
rescue! Which landed me to [Filtering for Bit Fields][].

So it appears that Active Directory is one of the few to use bit fields
extensively, which led people at Microsoft to implement a syntax that
targets specific bits.

It's possible to test multiple bits in a single filter rule, allowing
for *AND*-ing them or *OR*-ing them:

```
# looking for disabled records, AND style
(userAccountControl:1.2.840.113556.1.4.803:=2)


# ditto, OR style (804 instead of 803)
(userAccountControl:1.2.840.113556.1.4.804:=2)
```

Well, of course the two styles collapse when we're only looking for
*one* bit, but you get the idea.

Just to ease copy-and-paste, it's worth to add the negated condition for
enabled records:

```
# looking for enabled records, AND style
(!(userAccountControl:1.2.840.113556.1.4.803:=2))
```

The general rule for bit fields (from the linked page) is the following:

```
# AND --> 803 <---------------------.
<Attribute name>:1.2.840.113556.1.4.803:=<decimal comparative value>

# OR  --> 804 <---------------------.
<Attribute name>:1.2.840.113556.1.4.804:=<decimal comparative value>
```

Alas, the `comparative value` on the right hand side has to be a
`decimal` apparently and cannot be, say, a binary or a hexadecimal
value. I think this is pretty lame, but there's worse.

Stay safe folks!


[Filtering for Bit Fields]: https://ldapwiki.com/wiki/Filtering%20for%20Bit%20Fields
[Pinboard]: https://pinboard.in/
[Perl]: https://perl.org/
[Raku]: https://raku.org/
[userAccountControl]: https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/useraccountcontrol-manipulate-account-properties
