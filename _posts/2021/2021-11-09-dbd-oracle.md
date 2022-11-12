---
title: 'Installing DBD::Oracle in Perl'
type: post
tags: [ perl, dbi, oracle ]
comment: true
date: 2021-11-09 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Installing [DBD::Oracle][] **seems** easy.

I still have to *use* it properly though, so I might be deluding myself.

Anyway, back to the installation: some libraries and associated header
files will be needed. Thankfully, they are both available as part of the
[Instant Client][].

The main entry point is the [download page][], I followed the link for
the [Linux x86-64 (64-bit)][] version (I hope these links will survive
the test of time!) and proceeded to download two files:

- [Basic Package (ZIP)][], which contains the libraries ([local copy
  here][basic]), and
- [SDK Package (ZIP)][], which contains the stuff needed for compiling
  [DBD::Oracle][] against those libraries ([local copy here][sdk]).

Example:

```shell
# Basic Package (ZIP)
curl -LO 'https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip'

# SDK Package (ZIP)
curl -LO 'https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip'
```

Both archives (which should refer to the same version if they are
downloaded at the same time) should be extracted in the same directory.
Example:

```
# Extract the basic package
unzip instantclient-basic-linuxx64.zip

# Extract the addiitonal header files
unzip instantclient-sdk-linuxx64.zip
```

At this point, we're left with a sub-directory (something like
`instantclient_21_4`, the actual name will change in time as the package
is updated) with everything needed inside. Let's set it in the
`ORACLE_HOME` environment variable then:

```
export ORACLE_HOME="$PWD/instantclient_21_4"
```

We are now ready to install [DBD::Oracle][], e.g. like this:

```
printf %s\\n "requires 'DBD::Oracle';" >> cpanfile

carton
```

See [Installing Perl Modules][] for the details and other alternatives.

That's all folks!

[Perl]: https://www.perl.org/
[Instant Client]: https://www.oracle.com/database/technologies/instant-client.html
[download page]: https://www.oracle.com/database/technologies/instant-client/downloads.html
[Linux x86-64 (64-bit)]: https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html
[DBD::Oracle]: https://metacpan.org/pod/DBD::Oracle
[Installing Perl Modules]: {{ '/2020/01/04/installing-perl-modules/' | prepend: site.baseurl }}
[Basic Package (ZIP)]: https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip
[SDK Package (ZIP)]: https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip
[basic]: {{ '/assets/other/instantclient-basic-linuxx64.zip' | prepend: site.baseurl }}
[sdk]: {{ '/assets/other/instantclient-sdk-linuxx64.zip' | prepend: site.baseurl }}
