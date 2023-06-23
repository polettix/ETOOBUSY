---
title: ValiDNS is useable
type: post
tags: [ dns, perl ]
comment: true
date: 2023-06-24 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [validns][] is pretty useable.

*Shameless plug*: it's also *useful*, in my opinion.

Example:

```
validns foo.example.com bar.example.org > result.json
```

The following checks are performed:

- retrieval of basic information from the relevant Registry, possibly via
  RDAP, using a WHOIS API provider as a fallback (API key mostly needed
  here)
- retrieval of delegation in DNS
- comparison of nameserver lists from Registry and delegation in DNS
- comparison of SOA records across all authoritative nameservers
- comparison of nameserver lists across all authoritative nameservers
- availability of one IPv4 address for each authoritative nameserver or any
  other namerserver that is depended upon.

The result is printed as a JSON array of objects in standard output, each
object carrying the results for one input domain.

We can't fail providing an `example.com`:

```json
[
   {
      "checks" : [
         {
            "auth_registry" : {
               "changed" : "2023-05-12T15:13:35Z",
               "domain" : "example.com",
               "expires" : "2023-08-13T04:00:00Z",
               "nameservers" : [
                  "a.iana-servers.net",
                  "b.iana-servers.net"
               ],
               "rdap" : "https://rdap.verisign.com/com/v1/",
               "source" : "rdap",
               "status" : [
                  "client delete prohibited",
                  "client transfer prohibited",
                  "client update prohibited"
               ]
            },
            "name" : "authority data in registry",
            "status" : "ok"
         },
         {
            "auth_dns" : {
               "branch" : "example.com.",
               "domain" : "example.com",
               "nameserver" : [
                  "a.iana-servers.net",
                  "b.iana-servers.net"
               ]
            },
            "name" : "authority data in DNS",
            "status" : "ok"
         },
         {
            "name" : "Registry/DNS correpondence",
            "status" : "ok"
         },
         {
            "name" : "SOA alignment",
            "soa" : {
               "a.iana-servers.net" : [
                  "example.com.   3600   IN   SOA   ( ns.icann.org. noc.dns.icann.org.",
                  "            2022091302   ;serial",
                  "            7200      ;refresh",
                  "            3600      ;retry",
                  "            1209600      ;expire",
                  "            3600      ;minimum",
                  "   )"
               ],
               "b.iana-servers.net" : [
                  "example.com.   3600   IN   SOA   ( ns.icann.org. noc.dns.icann.org.",
                  "            2022091302   ;serial",
                  "            7200      ;refresh",
                  "            3600      ;retry",
                  "            1209600      ;expire",
                  "            3600      ;minimum",
                  "   )"
               ]
            },
            "status" : "ok",
            "warnings" : [
               {
                  "a.iana-servers.net (a.iana-servers.net)" : "SOA primary NS not in NS list"
               },
               {
                  "b.iana-servers.net (b.iana-servers.net)" : "SOA primary NS not in NS list"
               }
            ]
         },
         {
            "name" : "NS correspondence",
            "nss" : {
               "a.iana-servers.net" : [
                  "a.iana-servers.net",
                  "b.iana-servers.net"
               ],
               "b.iana-servers.net" : [
                  "a.iana-servers.net",
                  "b.iana-servers.net"
               ]
            },
            "status" : "ok"
         },
         {
            "addresses" : {
               "a.iana-servers.net" : "199.43.135.53",
               "a.icann-servers.net" : "199.43.135.53",
               "b.iana-servers.net" : "199.43.133.53",
               "b.icann-servers.net" : "199.43.133.53",
               "c.iana-servers.net" : "199.43.134.53",
               "c.icann-servers.net" : "199.43.134.53",
               "ns.icann.org" : "199.4.138.53"
            },
            "name" : "NS resolution to IPv4",
            "status" : "ok"
         }
      ],
      "domain" : "example.com",
      "name" : "Checks for example.com",
      "status" : "ok"
   }
]
```

All the rest is in the [README.md][] file (still a reasonably sized way to
go, but still!) - happy RTFM*in'*!

[Perl]: https://www.perl.org/
[validns]: https://codeberg.org/polettix/validns
[README.md]: https://codeberg.org/polettix/validns/src/branch/main/README.md
