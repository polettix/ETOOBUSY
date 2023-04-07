---
title: 'Data::Resolver - trial release with OOP interface'
type: post
tags: [ perl ]
comment: true
date: 2023-03-04 06:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I uploaded a [TRIAL release for Data::Resolver][Data::Resolver], with
> the new OOP interface.

And this is pretty much it.

Now, it's possible to do something like this:

```perl
use Data::Resolver::FromDir;

my $res = Data::Resolver::FromDir->new(root => '/path/to/somewhere');

# get list of assets (files)
say for $res->list_assets;

# check presence of asset
say 'present!' if $res->has_asset('foobar.txt');

# retrieve it as Data::Resolver::Asset
my $asset = $res->get_asset('foobar.txt');

say 'asset available as file at ', $asset->file;
say 'asset contains: ', $asset->raw_data;
```

The same interface is supported for TAR archives too, making it possible
to switch from one to the other seamlessly.

Next in line there will be a "canned" version that allows giving a list
of resolvers, and will try all of them in sequence.

Stay resolved!

[Perl]: https://www.perl.org/
[Data::Resolver]: https://metacpan.org/release/POLETTIX/Data-Resolver-0.003-TRIAL/view/lib/Data/Resolver.pod
