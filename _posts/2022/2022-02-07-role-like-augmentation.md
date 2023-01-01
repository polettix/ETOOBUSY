---
title: Role-like augmentation
type: post
tags: [ perl ]
comment: true
date: 2022-02-07 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> One way to add methods in a class, similar to how Roles would work.

One of the design goals of the evolution twist I'd like to give
[App::Easer][] is to move to an object-oriented approach and allow
overriding some of the behaviours through inheritance.

Well, it should suffice to use... *inheritance*, right?

Well, not so fast.

First of all, we should decide *where* to inherit from. I don't want all
the "support" stuff in [App::Easer][] to bloat the class implementing
the command. This might be solved in some way (e.g. with a *workhorse*
sub-package that the command class inherits from), but still I'm playing
with ideas, right?

Second, this would leave open the issue of where to put the
command's specification. One possibility is to keep it in a package's
stash (e.g. see [Augmenting Exporter][], or to put it directly in the
command's stash, much like [Exporter][] itself does).

This is why the *injection* of methods a-posteriori (and only if they
are not present) that is typical of Roles is fascinating: it would allow
us to do the *augmentation* by installing custom crafted methods, which
might close over the specification hash references, thus providing a
higher level of encapsulation.

Let's look at an example. The first class `Augmentable` can be...
*augmented* by class `Augmenting` of two methods `keep_this_please` and
`provide_this_instead`, but only the latter gets installed from
`Augmenting` because `Augmentable` already has it.

OK, this was super-confusing, the code will clear up the fog:

```perl
#!/usr/bin/env perl

package Augmentable;
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';

use File::Basename 'dirname';
use lib dirname(__FILE__);

use Augmenting 'augment';

augment();

exit sub (@args) {
   require Test::More;
   Test::More->import;

   my $obj = Augmentable->new;
   ok($obj, 'inside!');
   can_ok($obj, 'keep_this_please');
   is($obj->keep_this_please, 'this was kept', 'method kept');
   can_ok($obj, 'provide_this_instead');
   is($obj->provide_this_instead, 'here you go', 'method provided');
   done_testing();

   return 0;
}->(@ARGV) unless caller;


sub new { bless {}, shift }

sub keep_this_please { return 'this was kept' }

1;
```

Class `Augmentable` imports function `augment` from `Augmenting` and
will expect to be able to call two methods `keep_this_please` and
`provide_this_instead`, as anticipated.

The `exit sub ... unless caller` stuff is classic [modulino][] style.

The `keep_this_please` is provided by the class itself, so our
expectation is that it will **not** be overwritten, while
`provide_this_instead` should come from `Augmenting`.

So let's look at `Augmenting`:

```perl
package Augmenting;
use v5.24;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw< augment >;

sub augment (@args) {
   my $target = caller;
   for my $name (qw< keep_this_please provide_this_instead >) {
      next if $target->can($name);
      no strict 'refs';
      *{$target . '::' . $name} = __PACKAGE__->can($name);
   }
}

sub keep_this_please { return 'this has been overridden' }
sub provide_this_instead { return 'here you go' }

1;
```

The `augment()` function does all the magic: it iterates through the
methods to inject, skipping them if they are already present in the
`$target`, and adding them otherwise.

The `Augmentable` package file also doubles down as a [modulino][], so
we can see it in action:

```
$ perl ./Augmentable.pm 
ok 1 - inside!
ok 2 - Augmentable->can('keep_this_please')
ok 3 - method kept
ok 4 - Augmentable->can('provide_this_instead')
ok 5 - method provided
1..5
```

One last thought, `augment` must be called explicitly and cannot be
"embedded" in the `use Augmenting ...` statement easily. As `use` works
at *compile* time (as I understand it, in the equivalent of a `BEGIN`
block), it only gets to see the methods in `Augmentable` that have
*already* been defined. As such, at time of loading it has no clue about
what `Augmentable` provides by itself and what it needs to be injected.
Sure I might explore the use of `CHECK` and `INIT`... but I'd like to
keep it simple if possible!

I guess this is all, stay safe everyone 😄

[Augmenting Exporter]: {{ '/2022/02/06/augmenting-exporter/' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[Exporter]: https://metacpan.org/pod/Exporter
[modulino]: https://gitlab.com/polettix/notechs/-/snippets/1868370
