---
title: 'App::Easer V2 - an object in the object (sort of)'
type: post
tags: [ perl, client, terminal ]
comment: true
date: 2022-02-14 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> The basic object underlying [App::Easer][] V2.

One of the design choices when moving to V2 was to switch to an object
oriented interface *and* make it so each command would be an object with
some pre-defined, overridable methods. Nothing really new here, because
the idea is stolen from other modules in [CPAN][], notably [App::Cmd][].

This of course has the drawback of *polluting* the class the the user of
the module will eventually build, by placing a lot of methods that are
supposed to have a specific semantic. While I would normally be
skeptical of such *pervasiveness*, on the other hand the user of the
module is there to take advantage precisely of those methods, by filling
in the minimal stuff and having ample space to do whatever they like
with the rest of the namespace. Except, of course, if [App::Easer][] is
going to evolve further.

One thing, though, where I'm a bit more *weary* of imposing an
implementation choice is how data is kept inside the object, and surely
[App::Easer][] V2 tracks a lot of data, from the specification-side
parts (like the sources to look for configuration, the `help` and the
`description`, ...) up to the dynamically gathered configuration.

This, coupled with **not** taking a decision to adopt a specific object
system (it would have been [Moo][], anyway), led to a problem at a
higher level: how to keep the stuff and how much it would clash with a
user's stuff.

This is why I went for a sort of "object in the object" approach, in
which the code in `App::Easer::V2::Command` (which is the base class
for... commands) only relies in the presence of a sub-hash where it
keeps all the stuff.

So, by default the object is a *classic* hash reference, which only
contains one single key/value pair, the key being the package name with
which the `new` method is being called (I'm still trying to figure out
if this is a clever or a dumb move), and the value being a hash
reference with the relevant data:

```perl
sub new ($pkg, @args) {
   ...
   my $slot = {
      ...
   };
   my $self = bless {$pkg => $slot}, $pkg;
   return $self;
} ## end sub new
```

This reduces the "invasion surface" to a minimum, but it's even possible
to completely switch gears and use a completely different object system,
e.g. based on *inside-out* objects, or blessing an array reference and
*still* avoid reimplementing a lot of the stuff provided out of the box,
by means of overriding the `slot` method:

```perl
sub slot ($self) { return $self->{blessed($self)} //= {} }
```

This method just returns the hash (reference) with all the stuff managed
by [App::Easer][] V2, so every accessor relies on it to gather that
hash reference. This is done itself in two steps, with a cheap
implementation of an easy way to get set/get accessors relying on the
following functions:

```perl
sub _rwn ($self, $name, @newval) {
   my $vref = \$self->slot->{$name};
   $$vref = $newval[0] if @newval;
   return $$vref;
}
sub _rw ($s, @n) { $s->_rwn((caller(1))[3] =~ s{.*::}{}rmxs, @n) }
```

Function `_rwn` is the one calling `slot` (which can be overridden) to
get the hash reference back and poke into it. Function `_rw` gets the
name of the attribute to look for from [caller][] and calls back to
`_rwn`, implementing the cheap way to define accessors like this:

```perl
sub allow_residual_options ($self, @r) { $self->_rw(@r) }
sub auto_environment       ($self, @r) { $self->_rw(@r) }
sub call_name              ($self, @r) { $self->_rw(@r) }
...
```

So, for example, sub `call_name` calls sub `_rw`, which uses core
function `caller` to determine the string `call_name` to pass to sub
`_rwn` and get the associated value. I hope this makes sense in words as
it does in code!

If someone is interested into providing a different way of handling
their own objects, it would suffice to override `slot` and provide a
hash reference back (well, consistently the *same* hash reference for
the same instance, anyway!), like for example:

```perl
package BasedOnArray;
use App::Easer::V2 '-command'; # inherits from App::Easer::V2::Command

# let's assume the object is kept as a blessed array reference, whose
# very first item is our "slot" hash reference...
sub new {
    my $package = shift;
    my $slot = $package->SUPER::new(@_)->SUPER::slot;
    my $self = bless [$slot, @_], $package;
    return $self;
}

sub slot { return shift->[0] }
...
```

So yeah, this is an attempt to play it nice with a user's decision to
adopt this or that object system... but I still have to see if it's
going to hold water. For now, anyway, I've taken the most common
approach provided out of the box by the langage.

Stay safe!


[Perl]: https://www.perl.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[CPAN]: https://metacpan.org/
[App::Cmd]: https://metacpan.org/pod/App::Cmd
[Moo]: https://metacpan.org/pod/Moo
[caller]: https://perldoc.perl.org/functions/caller
