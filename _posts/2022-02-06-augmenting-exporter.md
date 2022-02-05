---
title: Augmenting Exporter
type: post
tags: [ perl ]
comment: true
date: 2022-02-06 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> [Exporter][] can be easily "augmented".

One of the things I'm looking into for deciding a slick interface for
[App::Easer][] is the `import` mechanism that happens when some module
is `use`d.

Which brings us to [Exporter][], of course.

My idea is to allow specifying *something* in the import list, while
still allowing it to have its usual meaning of *list of stuff that can
be imported, according to `@EXPORT_OK`*.

In the following example, we intercept import option `-spec` and its
following companion hash reference, while letting the rest go to
[Exporter][]'s import mechanism:

```perl
package Augmenter;
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use Carp ();

our %spec_for;
our @EXPORT_OK = qw< foo bar >;

sub import ($package, @args) {
   my $target = caller;
   my @args_for_exporter;
   while (@args) {
      my $request = shift @args;
      if ($request eq '-spec') {
         Carp::croak "no specification provided"
            unless @args;
         Carp::croak "invalid specification provided"
            unless ref($args[0]) eq 'HASH';
         $spec_for{$target} = shift @args;
      }
      else { push @args_for_exporter, $request }
   }
   $package->export_to_level(1, $package, @args_for_exporter);
}

sub foo { ... }
sub bar { ... }

1;
```

The basic trick is to filter the "extension" parts out of the array that
is eventually passed down to `export_to_level` (which is [Exporter][]'s
suggested method for doing this kind of intermediate stuff).

It's interesting that we have to put the `$package` value between the
`1` and `@args_for_exporter`. Well, I'm not 100% sure that it *MUST
always* by `$package`, probably any scalar value will do; in any case,
the function is supposed to expect a list of parameter in the same shape
as that that arrives to `import()` itself, which *includes* the package
name. In my `perl` installation, for example, I find this in
[Exporter::Heavy][] (which carries the actual implementation for
`export_to_level`):

```perl
sub heavy_export_to_level
{
      my $pkg = shift;
      my $level = shift;
      (undef) = shift;                  # XXX redundant arg
      my $callpkg = caller($level);
      $pkg->export($callpkg, @_);
}
```

The `(undef) = shift` line tells us that anything can do... but I'll
stick to pass in the `$package` name, just to be on the safe side 🙄

So... I invite you too to remain on the safe side, as always!


[Perl]: https://www.perl.org/
[Exporter]: https://metacpan.org/pod/Exporter
[Exporter::Heavy]: https://metacpan.org/pod/Exporter::Heavy
[App::Easer]: https://metacpan.org/pod/App::Easer
