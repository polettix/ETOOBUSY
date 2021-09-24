---
title: 'SAMLRequest inspection'
type: post
tags: [ saml, perl, web, security ]
comment: true
date: 2021-09-27 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Some message parts in [SAML 2.0][] require fiddling to see what's
> inside.

In [SAML 2.0][], the `SAMLRequest` parameter is included in a URL like
this:

```
https://example.com/?SAMLRequest=...the-request...
```

where `...the-request...` is built as follows:

- start from the XML text that represents the `AuthnRequest`
- apply the [DEFLATE][] algorithm to obtain a compressed binary string
- apply the [Base64][] encoding
- apply [url encoding][] to the [Base64][] string

So, if we start from this example:

```xml
<samlp:AuthnRequest
    xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    ID="identifier_1"
    Version="2.0"
    IssueInstant="2004-12-05T09:21:59Z"
    AssertionConsumerServiceIndex="1">
    <saml:Issuer>https://sp.example.com/SAML2</saml:Issuer>
    <samlp:NameIDPolicy 
      AllowCreate="true"  
      Format="urn:oasis:names:tc:SAML:2.0:nameid-format:transient"/>
</samlp:AuthnRequest>
```

we end up with this:

```
https://example.com/?SAMLRequest=fZFLa8MwEITvhf4Ho3v8ojlksQ0hoWBoS2lKD70UYW%2BIQA9Xu2rdf1%2FFSUqaQ3ScmU87WlUkjR5gGXhnX%2FAzIPHtTRLPaLQlmNxaBG%2FBSVIEVhok4A42y8cHKNMcBu%2FYdU6LS%2B46JonQs3L2yLXrWqgeLautQv9RHOU39BRDtYjMKUkUsLXE0nLU8%2FxuVpSzfP6aL6AsYL54PwaXpxErZykY9Bv0X6qLbI9jLQrRHHLVvi1M1%2FpmxzwQZBkNKY7SDBrTzpls37ussvPkGTzAU3xgu352WnU%2FycGJBbR23yuPkrEW7AOK5M%2B7d95Ivr6jvaL62XaKAntpScUNiSzOPnT5%2F3PNLw%3D%3D
```

OK, now we received this and want to look inside... what do we do?

This:

<script src="https://gitlab.com/polettix/notechs/-/snippets/2180170.js"></script>

Local versions: [cpanfile][] and [saml-request][].

If [we use Carton][], the `cpanfile` will help us installing the modules. We're standing on the shoulders of giants here: [IO-Compress][], [XML::Twig][], and [Mojolicious][].

The program does the reverse of the encoding operations described above:

- function `get_urlparam` gives us the value of the `SAMLRequest` URL
  parameter. [Mojo::URL][] takes care to reverse the [url encoding][]
  for us;
- function `decode_saml` does the heavylifting of turning the encoded
  value back into an XML string
- function `pretty_xml` helps us pretty-printing the XML text on the
  output.

Let's see how it goes:

```
$ perl saml-request 'https://example.com/?SAMLRequest=fZFLa8MwEITvhf4Ho3v8ojlksQ0hoWBoS2lKD70UYW%2BIQA9Xu2rdf1%2FFSUqaQ3ScmU87WlUkjR5gGXhnX%2FAzIPHtTRLPaLQlmNxaBG%2FBSVIEVhok4A42y8cHKNMcBu%2FYdU6LS%2B46JonQs3L2yLXrWqgeLautQv9RHOU39BRDtYjMKUkUsLXE0nLU8%2FxuVpSzfP6aL6AsYL54PwaXpxErZykY9Bv0X6qLbI9jLQrRHHLVvi1M1%2FpmxzwQZBkNKY7SDBrTzpls37ussvPkGTzAU3xgu352WnU%2FycGJBbR23yuPkrEW7AOK5M%2B7d95Ivr6jvaL62XaKAntpScUNiSzOPnT5%2F3PNLw%3D%3D'

SAMLRequest = fZFLa8MwEITvhf4Ho3v8ojlksQ0hoWBoS2lKD70UYW+IQA9Xu2rdf1/FSUqaQ3ScmU87WlUkjR5gGXhnX/AzIPHtTRLPaLQlmNxaBG/BSVIEVhok4A42y8cHKNMcBu/YdU6LS+46JonQs3L2yLXrWqgeLautQv9RHOU39BRDtYjMKUkUsLXE0nLU8/xuVpSzfP6aL6AsYL54PwaXpxErZykY9Bv0X6qLbI9jLQrRHHLVvi1M1/pmxzwQZBkNKY7SDBrTzpls37ussvPkGTzAU3xgu352WnU/ycGJBbR23yuPkrEW7AOK5M+7d95Ivr6jvaL62XaKAntpScUNiSzOPnT5/3PNLw==

<samlp:AuthnRequest AssertionConsumerServiceIndex="1" ID="identifier_1" IssueInstant="2004-12-05T09:21:59Z" Version="2.0" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol">
  <saml:Issuer>https://sp.example.com/SAML2</saml:Issuer>
  <samlp:NameIDPolicy AllowCreate="true" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:transient"/>
</samlp:AuthnRequest>
```

It seems to be working... good.

Enough for today, stay safe folks!

[Perl]: https://www.perl.org/
[Raku]: https://www.raku.org/
[SAML 2.0]: https://www.oasis-open.org/committees/tc_home.php?wg_abbrev=security#samlv20
[DEFLATE]: https://datatracker.ietf.org/doc/html/rfc1951
[Base64]: https://github.polettix.it/ETOOBUSY/2020/08/13/base64/
[url encoding]: https://en.wikipedia.org/wiki/Percent-encoding
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Mojo::URL]: https://metacpan.org/pod/Mojo::URL
[XML::Twig]: https://metacpan.org/pod/XML::Twig
[IO-Compress]: https://metacpan.org/dist/IO-Compress
[we use Carton]: https://github.polettix.it/ETOOBUSY/2020/01/04/installing-perl-modules/
[cpanfile]: {{ '/assets/2021-09-27/cpanfile' | prepend: site.baseurl }}
[saml-request]: {{ '/assets/2021-09-27/saml-request' | prepend: site.baseurl }}
