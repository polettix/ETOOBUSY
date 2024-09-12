---
title: "Getting the `ntSecurityDescriptor` with an LDAP query"
type: post
tags: [ perl, ldap, 'active directory' ]
comment: true
date: 2024-09-13 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I found out how to retrieve the `ntSecurityDescriptor` in Active
> Directory, via LDAP.

Active Directory is a... *beast* and it's not always easy to get what's
needed. This took me... some time.

One configuration that is supported for an account is the possibility to
set a flag for preventing a user to change password. I'm not sure *why*
there's such a flag; I can only imagine that's an easy way to lock an
account (you just set a very random password, then prevent anyone from
changing it).

There's a promising flag `PASSWD_CANT_CHANGE` in `userAccountControl`,
but alas:

> You can't assign this permission by directly modifying the
> UserAccountControl attribute. For information about how to set the
> permission programmatically, see the [Property flag descriptions][]
> section.

The link eventually lands us on page [Modifying User Cannot Change
Password (LDAP Provider)][], which is *somehow* helpful but not too
much, because it includes code examples that assume the use of some
Microsoft library for C++. I guess 🙄

Anyway, the page includes some interesting info:

- the information that we're after is in an *Discretionary Access
  Control List* (DACL)
- it is included in property (/attribute) `ntSecurityDescriptor` in the
  LDAP record.

Only fact is that this attribute is nowhere to be found.

Wait a minute. What?!?

It turns out that depending on how you set the query parameters, this
field will contain more or less information. By default it is supposed
to contain everything, except that normal users are *not* supposed to
see everything, so Active Directory does not include this attribute in
the answer.

The trick consists in *asking for less*. [This answer][] got me on the
right track for a solution *in [Perl][]*: we have to set the extension
control `LDAP_SERVER_SD_FLAGS_OID` to a value that excludes the *System
Access Control List* part from the answer, while keeping everything
else. The answer also includes a quick and dirty way of building up the
right value to pass for this control:

```php
$sdFlags = 7;
...
   "value" => sprintf("%c%c%c%c%c", 48, 3, 2, 1, $sdFlags)
```

This even works in [Perl][], but it's a bit too *hackish* and I'd like
to know more.

[This page][] contains the information I was after:

> The `LDAP_SERVER_SD_FLAGS_OID` control is used with an LDAP Search
> request to control the portion of a [Windows security descriptor][] to
> retrieve.
>
> ...
>
> When sending this control to the DC, the controlValue field is set to
> the BER encoding of the following ASN.1 structure.
>
>     SDFlagsRequestValue ::= SEQUENCE {
>         Flags    INTEGER
>     }

This makes it clearer the trick in the PHP code; it's just a way to
produce the BER encoding of the required data structure. In particular:

```
0x30 (48 decimal)    tag for a SEQUENCE
0x03 (3 decimal)     length of SEQUENCE (# of following octets)
    0X02 (2 decimal)     tag for an INTEGER
    0x01 (1 decimal)     length of INTEGER (# of following octets)
    0x07 ($sdFlags)      value of INTEGER
```

When using [Perl][], especially when using [Net::LDAP][], there's a
cleaner and more readable way of producing the same:

```perl
use Convert::ASN1;
use constant OWNER_SECURITY_INFORMATION => 0x01;
use constant GROUP_SECURITY_INFORMATION => 0x02;
use constant DACL_SECURITY_INFORMATION  => 0x04;
use constant SACL_SECURITY_INFORMATION  => 0x08;
my $asn = Convert::ASN1->new;
$asn->prepare(<<'END');
   SDFlagsRequestValue ::= SEQUENCE {
      Flags    INTEGER
   }
END
my $ldap_control_sd_flags = $asn->encode(Flags =>
     OWNER_SECURITY_INFORMATION
   | GROUP_SECURITY_INFORMATION
   | DACL_SECURITY_INFORMATION
);
```

Setting the control for the query is quite straightforward, as it's part
of the interface for the [search][ldap-search] method:

```perl
use Net::LDAP::Constant qw< LDAP_CONTROL_SD_FLAGS >;
use Net::LDAP::Control;
my $control = Net::LDAP::Control->new(
    critical => 1,
    type     => LDAP_CONTROL_SD_FLAGS,
    value    => $ldap_control_sd_flags,
);
...
my $res = $ldap->search(..., control => $control);
...
```

This should eventually give us the `ntSecurityDescriptor` we're after
(including the DACL), even when we're not super-administrators.

Stay safe!


[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Property flag description]: https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/useraccountcontrol-manipulate-account-properties#property-flag-descriptions
[Modifying User Cannot Change Password (LDAP Provider)]: https://learn.microsoft.com/en-us/windows/win32/adsi/modifying-user-cannot-change-password-ldap-provider
[This answer]: https://stackoverflow.com/questions/40771503/selecting-the-ad-ntsecuritydescriptor-attribute-as-a-non-admin/40773088#40773088
[This page]: https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/3888c2b7-35b9-45b7-afeb-b772aa932dd0
[Windows security descriptor]: https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/b645c125-a7da-4097-84a1-2fa7cea07714#gt_e5213722-75a9-44e7-b026-8e4833f0d350
[Net::LDAP]: https://metacpan.org/pod/Net::LDAP
[ldap-search]: https://metacpan.org/pod/Net::LDAP#search-(-OPTIONS-)
