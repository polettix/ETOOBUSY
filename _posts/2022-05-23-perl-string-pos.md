---
title: "Perl's pos"
type: post
tags: [ perl ]
comment: true
date: 2022-05-23 07:00:00 +0200
mathjax: false
published: true
whatever: Happy birthday mom!
---

**TL;DR**

> A few notes about `pos`, to teach something to **past me**.

If it seems anti-causal... it is, but it makes sense in some sense.

OK, I was reading through [some past code][crumble] and I saw this
(redacted):

```perl
sub crumble {
   my ($input) = @_;
   # ...
   my $chunk = qr{yadda yadda yadda...};
 
   # save and reset current pos() on $input
   my $prepos = pos($input);
   pos($input) = undef;
 
   my @path;
   push @path, $1 while $input =~ m{\G [.]? ($chunk) }cgmxs;
 
   # save and restore pos() on $input
   my $postpos = pos($input);
   pos($input) = $prepos;
```

The gist is that I'm using the repeated matching (`/g` modifier) in the
regular expression for extracting many parts separated by a dot.

The thing that caught my eye was all the `pos()` fiddling *before* and
*after* applying the match. This *might* make sense because that
matching is both influenced by `pos()` and alters it, but in this case
it's totally not necessary because `$input` is a **different** variable
than `$_[0]` (they just happen to have the same value).

So yes, I'm trying to address a non-existent problem here.

Not convinced? Check this out:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

sub report ($text, $pos) { say $text, ' ', $pos // '**undef**' }

sub moves_it {
   $_[0] =~ m{\G hello}gmxs;
   report('moves_it, original at', pos($_[0]));
}

sub keeps_it {
   my ($input) = @_;
   $input =~ m{\G hello}gmxs;
   report('keeps_it,     copy at', pos($input));
   report('keeps_it, original at', pos($_[0]));
}

sub keeps_it_too ($input) {
   $input =~ m{\G hello}gmxs;
   report('keeps_it_too,     copy at', pos($input));
   report('keeps_it_too, original at', pos($_[0]));
}

my $text = 'hello all';

pos($text) = undef;
report('outside, now at', pos($text));
moves_it($text);
report('outside, now at', pos($text));

say '';
pos($text) = 2;
report('outside, now at', pos($text));
keeps_it($text);
report('outside, now at', pos($text));

say '';
report('outside, now at', pos($text));
keeps_it_too($text);
report('outside, now at', pos($text));
```

Note that we set `pos($text) = 2` to place it in some place that would
make the match in `moves_it` fail. The output is the following:

```
outside, now at **undef**
moves_it, original at 5
outside, now at 5

outside, now at 2
keeps_it,     copy at 5
keeps_it, original at 2
outside, now at 2

outside, now at 2
keeps_it_too,     copy at 5
keeps_it_too, original at 2
outside, now at 2
```

The only way to affect (or be affected by) the variable outside is to
work *directly* on `$_[0]`, because that's an *alias* to the outside
variable so we're operating on it *directly*.

In the other two cases we defined the explicit `$input` variable which
is a *copy* of the input one, which also means that it gets its own
global tracker for regular expressions and the like.

So there you go, *past me*: you've been overly paranoid.

Stay safe everybody!

[Perl]: https://www.perl.org/
[Template::Perlish]: https://metacpan.org/pod/Template::Perlish
[crumble]: https://metacpan.org/dist/Template-Perlish/source/lib/Template/Perlish.pm#L499
