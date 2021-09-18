---
title: 'Sub::Import'
type: post
tags: [ perl ]
comment: true
date: 2021-09-19 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A module to name your imports to your liking.

Sometimes I use functions from [Perl][] modules but I don't like the
name of those functions. As an example, `encode_base64` and
`decode_base64` from [MIME::Base64][] have perfectly fine an readable
names, but I'd like to be able to just call `base64` the first, of give
them very short names like `e64` and `d64`. Additionally, that `md5_hex`
from [Digest::MD5][] is, too, a good and readable name... but I would so
like to just call it as `md5sum` 🙄

This is where [Sub::Import][] comes handy: it allows to import *subs*
(nothing more) with custom names:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use FindBin '$Bin';
use lib "$Bin/local/lib/perl5", "$Bin/lib";

use Sub::Import 'MIME::Base64',
  encode_base64 => {-as => 'e64'},
  decode_base64 => {-as => 'd64'};
use Sub::Import 'Digest::MD5', md5_hex => {-as => 'md5sum'};
use Sub::Import 'Math::Trig', -all => {-prefix => 'trig_'};
use Sub::Import 'Math::Trig', -pi  => {-suffix => '_the_great'};


my $text    = 'whateeeevah!';
my $encoded = e64($text, '');
my $decoded = d64($encoded);
my $digest  = md5sum($text);
say "$text\n$encoded\n$decoded\n$digest";
say trig_tan(trig_deg2rad(45));
say trig_tan(pi_the_great() / 4);
```

Output:

```
whateeeevah!
d2hhdGVlZWV2YWgh
whateeeevah!
9584f59f3b8c14b8719a57af7cf2b76e
1
1
```

My personal opinions after using it for about 5 minutes:

- I like that functions can get custom names;
- I like that it's possible to `use` it multiple times for multiples
  imports;
- I don't like the documentation. It *somehow* points to
  [Sub::Exporter][] for using it, which seems *too lazy even for me*.

So I would like a lot having *at least* the following SYNOPSIS:

```perl
# import a function with a custom name
use Sub::Import 'Digest::MD5', md5_hex => {-as => 'md5sum'};

# import multiple functions, each with its own name
use Sub::Import 'MIME::Base64',
  encode_base64 => {-as => 'e64'},
  decode_base64 => {-as => 'd64'};

# Import most functions with the "trig_" prefix, e.g. "trig_log",
# "trig_sin", "trig_cos", etc.
use Sub::Import 'Math::Trig', -all => {-prefix => 'trig_'};

# Import PI-related functions with the "_the_great" suffix, e.g.
# "pi_the_great", "pi2_the_great", etc.
use Sub::Import 'Math::Trig', -pi  => {-suffix => '_the_great'};
```

Which is why... [there's this Issue now][issue] 🤞

Stay safe everyone!


[Perl]: https://www.perl.org/
[MIME::Base64]: https://metacpan.org/pod/MIME::Base64
[Digest::MD5]: https://metacpan.org/pod/Digest::MD5
[Sub::Import]: https://metacpan.org/pod/Sub::Import
[issue]: https://github.com/rjbs/Sub-Import/issues/1
[Sub::Exporter]: https://metacpan.org/pod/Sub::Exporter
