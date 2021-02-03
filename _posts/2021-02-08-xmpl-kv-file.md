---
title: xmpl - on-file key/value store
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-02-08 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> We will take a closer look at the implementation for the on-file
> key/value store in [xmpl][]. This post is [part of a series][series].

In previous post [xmpl - in-memory key/value store][] we started looking
at the implementation for the key/value store classes, in particular the
in-memory one.

Today we're looking at the file-backed alternative, which will benefit
from the facilities provided by [Mojolicious][], namely [Mojo::File][]
to ease handling of files in the local filesystem, and [Mojo::JSON][] to
deal with the encoding:

```perl
use Mojo::File;
use Mojo::JSON qw< decode_json encode_json >;
```

This implementation is done as a *wrapper* around the class we describe
in the other post. In short, this object will keep a reference to an
instance of the in-memory data store, as well as a reference to a
[Mojo::File][] object that points to the target file for persistence.

```perl
sub file ($s) { return $s->{file} }
sub instance ($s) { return $s->{instance} }
sub new ($package, %args) {
   my $file = Mojo::File->new($args{filepath});

   # ensure file exists
   $file->dirname->make_path;
   $file->touch;

   # load file data
   my $json_text = $file->slurp =~ s{\A\s+|\s+\z}{}grmxs;
   my $kvpairs = decode_json($json_text || '{}');

   my $instance = KVStore::InMemory->new($kvpairs);
   my $self = bless {instance => $instance, file => $file}, $package;
   eval { $self->save };
   return $self;
}
```

The constructor is a bit complicated because it takes care to ensure
that the target file exists, as well as loading it to guarantee the
persistence across separate runs of the software.

Read-only methods are simply delegated down to the in-memory instance:

```perl
sub as_hash ($self) { return $self->instance->as_hash }
sub get ($self, $key) { return $self->instance->get($key) }
sub has ($self, $key) { return $self->instance->has($key) }
```

State-changing methods, on the other hand, also imply saving the changes
down to the file, by means of the `save` method:

```perl
sub remove ($s, $k) { $s->instance->remove($k); return $s->save }
sub save ($s) { $s->file->spurt(encode_json($s->as_hash)); return $s }
sub set ($s, $k, $v) { $s->instance->set($k, $v); return $s->save }
```

Again, this implementation is not bulletproof and surely nothing you
should rely upon for your important transactions. And again I think this
is perfectly acceptable for this kind of application.

The `is_healthy` method is actually implemented as a test on the
underlying filesystem/storage. As long as we can `save` without errors,
we consider ourselves fine; otherwise... it's time to flag that things
are not that healthy:

```perl
sub is_healthy ($s) { eval {$s->save; 1} }
```

If you want to look at the complete code for the class... [head to
it][]! Otherwise... stay safe!

[xmpl - an example web application]: {{ '/2020/02/05/xmpl/' | prepend: site.baseurl }}
[xmpl]: https://gitlab.com/polettix/xmpl
[code]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl
[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Kubernetes]: https://kubernetes.io/
[README.md]: https://gitlab.com/polettix/xmpl/-/blob/master/README.md
[xmpl - the key/value API]: {{ '/2021/02/06/xmpl-kv.api.md' | prepend: site.baseurl }}
[xmpl - in-memory key/value store]: {{ '/2021/02/07/xmpl-kv-memory.md' | prepend: site.baseurl }}
[Mojo::File]: https://metacpan.org/pod/Mojo::File
[head to it]: https://gitlab.com/polettix/xmpl/-/blob/v0.1.0/xmpl#L17
[series]: {{ '/series#xmpl' | prepend: site.baseurl }}
