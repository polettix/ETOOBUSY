---
title: LDIF Tutorial (link & gist)
type: post
tags: [ ldap, ldif ]
comment: true
date: 2022-05-19 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Some notes about LDIF][tut].

That's a very useful tutorial.

Some *quick stuff* in the following sections.

# Attributes

To manipulate attributes, the `changetype` is `modify` and then the
operations can be `add`, `delete`, and `replace`.

```ldif
dn: CN=Foo,OU=Here,DC=example,DC=com
changetype: modify
add: galook
galook: some value

dn: CN=Bar,OU=There,DC=example,DC=com
changetype: modify
delete: galook


dn: CN=Baz,OU=Whatever,DC=example,DC=com
changetype: modify
replace: galook
galook: ahoy
```

The `replace` acts as a *create if not exists*.

It's possible to merge operations over the same `dn`:

```ldif
dn: CN=Foo,OU=Here,DC=example,DC=com
changetype: modify
add: galook1
galook1: some value
-
delete: galook2
-
replace: galook3
galook3: ahoy
```

Most attribute can contain multiple values, becoming arrays. It's
possible to delete a specific value instead of all of them:

```ldif
dn: CN=Bar,OU=There,DC=example,DC=com
changetype: modify
delete: galook
galook: value to remove
```

# Groups

Lifecycle management of group belonging is an operation over the
`member` attribute of the group. Same rules as above apply:

```ldif
dn: CN=FrotzGroup,OU=MyGroups,DC=example,DC=com
changetype: modify
add: member
member: CN=Foo,OU=Here,DC=example,DC=com
```

To delete a single element **make sure you specify the `member` value to
remove**:

```ldif
dn: CN=FrotzGroup,OU=MyGroups,DC=example,DC=com
changetype: modify
delete: member
member: CN=Bar,OU=There,DC=example,DC=com
```

# Position in LDAP tree

Each *item* is put in the hierarchy and can be moved. Let's move
`CN=Foo,OU=Here,DC=example,DC=com` into `CN=Foo,OU=Somewhere
Else,DC=example,DC=com`, using `modrdn`:

```ldif
dn: CN=Foo,OU=Here,DC=example,DC=com
changetype: modrdn
newrdn: Foo
newsuperior: OU=Somewhere Else,DC=example,DC=com
deleteoldrdn: 1
```

The `deleteoldrdn` is suggested to be kept to `0` in the [tutorial][tut]
but I've seen errors so I usually stick to `1`.

In this case we're keeping the same `CN`, but that can change too via
`newrdn`:

```ldif
dn: CN=Foo,OU=Here,DC=example,DC=com
changetype: modrdn
newrdn: FooBarBaz
newsuperior: OU=Somewhere Else,DC=example,DC=com
deleteoldrdn: 1
```

# So happy...

... LDAP*ing*, and stay safe!

[tut]: https://www.digitalocean.com/community/tutorials/how-to-use-ldif-files-to-make-changes-to-an-openldap-system
