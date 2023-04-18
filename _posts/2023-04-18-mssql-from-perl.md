---
title: MS SQL Server from Perl in Linux
type: post
tags: [ linux, perl, database ]
comment: true
date: 2023-04-18 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Let's jot down some notes on accessing MS SQL Server from [Perl][] in
> Linux.

As I *often* find when I have to deal with Microsoft stuff, there's a lot
around but it always leaves me with doubts and gray areas. This time it was
connecting to SQL Server from [Perl][] in Linux.

The way to go is to use ODBC. In the distribution that I use, it means
[unixODBC][], which is available as a package.

The real way from our code to the server, though, is a bit longer; I hope
I'm getting the terminology right:

```
      [Our Perl code]
           [DBI]
        [DBD::ODBC]
        [unixODBC]
       [ODBC Driver]
       [SQL Server]
```

Well, I'm *not that sure* about the `[unixODBC]` layer but whatever.

The most popular ODBC Driver for connecting to SQL Server seems to be the
stuff from easysoft. As much as I can appreciate their wide range of
documentation, I'm not really thrilled about paying to play with the driver
beyond the 14 days trial period. In 2023, this also somehow smells *old*.

> I'm pretty happy to pay for support of stuff that goes in production, I
> just think that development & test environments should come for free as in
> beer.

On the other hand, Microsoft themselves have a driver that can be installed
free of charge, [available here][]. I tried the instructions for Alpine
Linux and the installation worked fine (in a Docker container running
version 3.16); it also ended up installing [unixODBC][] along the way.

After the installation, I run the following command to see what was *seen*
as available:

```
$ odbcinst -q -d
[ODBC Driver 18 for SQL Server]
```

The string with brackets can then be used as the `Driver` when `connect`ing
with [DBI][] (with [DBD::ODBC][]), we just have to change the brackets into
curly braces.

> CAVEAT: the [Perl][] code below is untested because I don't have a SQL
> Server instance at hand right now. I hope I remembered well, though.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

use DBI;

my %connect_config = (
   Driver                 => '{ODBC Driver 18 for SQL Server}',
   Database               => $ENV{DATABASE},
   UID                    => $ENV{USERNAME},
   PWD                    => $ENV{PASSWORD},
   Server                 => $ENV{HOST},
   Encrypt                => $ENV{ENCRYPT},                       # Yes/No
   TrustServerCertificate => $ENV{TRUST_CRT},                     # Yes/No
);
my $dbh = DBI->connect(dbi_string(ODBC => %connect_config), '', '',
   { AutoCommit => 0, RaiseError => 1, PrintError => 1 });

for my $tov (@ARGV) {
   my $quoted = $dbh->quote_identifier($tov);
   my ($count) = $dbh->selectrow_array("SELECT COUNT(*) FROM $quoted");
   say "$tov: $count";
}

$dbh->disconnect;

sub dbi_string ($dbd, @pairs) {
   my @joined_pairs;
   while (@pairs) {
      my ($key, $value) = splice @pairs, 0, 2;
      push @joined_pairs, "$key=$value" if defined $value;
   }
   return join ':', dbi => $dbd, join ';', @joined_pairs;
}
```

So there you go, until it's actually tested this is *at least* a good
and complete starting point.

Stay safe!

[Perl]: https://www.perl.org/
[unixODBC]: https://www.unixodbc.org/
[available here]: https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server
[DBI]: https://metacpan.org/pod/DBI
[DBD::ODBC]: https://metacpan.org/pod/DBD::ODBC
