---
title: Loving The Alien
type: post
tags: [ perl, alien ]
comment: true
date: 2020-01-29 22:37:41 +0100
preview: true
---

**TL;DR**

> Sometimes you just get to love the [Perl][] community and its *Do What I
> Mean* mindset.

For reasons I prefer to gloss over, I recently *thought* that I needed to
install [XML::LibXML][] in a local installation with [Carton][], and it
ended up like this:

```shell
$ carton
Installing modules using ...
Successfully installed File-Which-1.23
Successfully installed PkgConfig-0.23026
Successfully installed FFI-CheckLib-0.26
Successfully installed File-chdir-0.1010
Successfully installed Path-Tiny-0.112
Successfully installed Test-Simple-1.302171
Successfully installed Capture-Tiny-0.48
Successfully installed Alien-Build-1.96
Successfully installed Sort-Versions-1.62
Successfully installed Mojo-DOM58-2.000
Successfully installed Alien-Libxml2-0.12
Successfully installed XML-NamespaceSupport-1.12
Successfully installed XML-SAX-Base-1.09
Successfully installed XML-SAX-1.02
Successfully installed XML-LibXML-2.0202
15 distributions installed
Complete! Modules were installed into ...
```

This is just amazing. I didn't have the underlying library in my [Debian][]
system, but the whole system was set up to figure this out and install a
privately compiled version to be consumed by [XML::LibXML][].

I sincerely thank the amazing people that make this possible - I mean, both
[Alien][] but also the whole toolchain!

[Perl]: https://www.perl.org/
[XML::LibXML]: https://metacpan.org/pod/XML::LibXML
[Carton]: https://metacpan.org/pod/Carton
[Debian]: https://debian.org/
[Alien]: https://metacpan.org/pod/Alien

