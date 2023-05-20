---
title: 'Data::Resolver alternatives yield... alternatives'
type: post
tags: [ perl ]
comment: true
date: 2023-05-20 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Fixing a design decision in [Data::Resolver][].

[Data::Resolver][] provides both a unified interface to *resolve* keys to
data (available as file, filehandle, or in-memory), as well as a few
concrete implementations to do this on the filesystem and with TAR files.

It also supports a kind of *meta-source* that allows wrapping a few
alternatives; this comes handy if multiple files and/or directories have to
be searched during the resolution process. Like when a configuration file
might be in your home directory, or in `/etc`, or in some
application-specific place...

The generic interface supports pivoting to *sub-resolvers*. These are
basically objects that support the same resolution process as anything else,
only they provide a sub-view out of an outer element.

> The joys of writing. As I wrote the above paragraph, I thought that this
> might be implemented in a very generic way. We'll see.

My initial implementation would extract a sub-resolver from alternatives by
just finding the first sub-item that would provide an answer. This, though,
sort of defies the goal of representing multiple alternatives, *especially*
when we're not dealing with resolving one single key, but getting
sub-resolvers. So [here we go][]:

```perl
sub get_sub_resolver ($self, $key) {
   my @subs =
      map  { $_->get_sub_resolver($key) }
      grep { $_->has_sub_resolver($key) }
      $self->alternatives->@*;
   $self->not_found($key) unless @subs;
   return ref($self)->new(alternatives => \@subs);
}
```

I guess this is part of the design process and how much time one can
allocate. The 20/20 hindsight can be depressing at times, though.

Stay safe!

[here we go]: https://codeberg.org/polettix/Data-Resolver/src/commit/b5b2ba642fb6690d53829ac8a52af0f595a25bc0/lib/Data/Resolver/Alternatives.pm#L30
[Perl]: https://www.perl.org/
[Data::Resolver]: https://metacpan.org/pod/Data::Resolver
