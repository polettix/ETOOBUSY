---
title: 'A possible SYNOPSIS for a MyJSONs module'
type: post
tags: [ perl, coding, module ]
comment: true
date: 2022-11-02 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Jotting down how to interact with an hypothetical module for
> [MyJSONs][].

In post [Software Tools for Hobby-Scale Projects][] I played a bit with
the web service [MyJSONs][] and it seems to work. At least, as of today.

More often than not these service appear and disappear. This specific
one was probably born out of MyJSON (without the final *s*), which is no
more. Anyway, we can have some fun in the meantime, right?

So I started playing with the idea of a module. How would I like to use
it? Let's see...

First, it would be handy to have a functional interface, like this:

```perl
use WebService::MyJSONs qw< myjsons_put myjsons_get >;

# create a new item, get item's code back
my $code = myjsons_put({ foo => 'bar' });

# retrieve data for $code
my $retrieved_data = myjsons_get($code);

# update data for $code
myjsons_put($code, { foo => 'bar', baz => 42 });
```

Function `myjsons_put` doubles down on creation of a new slot or update
of the slot, depending on the number of parameters (one or two,
respectively). The interface above treats `$data` as... data, so it
takes care to convert it to/from JSON as needed.

This brings us to the next need: using JSON directly. This is where a
JSON-specific API can come handy:

```perl
use WebService::MyJSONs qw< myjsons_put_json myjsons_get_json >;

my $code = myjsons_put_json('{"foo":"bar"}');
my $json = myjsons_get_json($code);
myjsons_put_json($code, '{"foo":"bar", "baz": "yay!"}');
```

Again, the "put" method `myjsons_put_json` doubles down on creation and
update.

Now, of course, we might be interested into an object-oriented
interface. Did I hear *over-engineering*?!?

The basic API works on the assumption that an object will keep the code
of the remote JSON fragment as soon as it can, possibly upon invoking
the `new` constructor.

```perl
use WebService::MyJSONs;

my $mj1 = WebService::MyJSONs->new;

# initialize with a $code
$code = '5ef6366';
my $mj2 = WebService::MyJSONs->new(code => $code);

# set endpoint explicitly (e.g. a different one)
my $url = 'https://www.myjsons.com';
my $mj3 = WebService::MyJSONs->new(endpoint => $url);
```

The plain API has `get`/`get_json`/`put`/`put_json` just like the
functional counterpart. Objects that do *not* have a cached code inside
will invoke the creation of a new remote item and then cache the code
returned by the web service.

In the next example, `$mj` starts without a code inside, so the first
`put` takes care to create a new remote item and cache its code inside
the object, while the second `put` is an update to that remote item.

```perl
my $mj = WebService::MyJSONs->new;
$mj->put({ foo => 'bar', hex => [ 0 .. 9, 'a' .. 'f' ] });
say $mj->code;
my $retrieved_data = $mj->get;
$mj->put({ foo => 'bar', hex => [ 0 .. 9, 'A' .. 'F' ] });
```

There's of course the counterpart when playing directly with JSON
strings:

```perl
my $mj = WebService::MyJSONs->new;
$mj->put_json('{"foo":"bar"}');
my $json = $mj->get_json;
$mj->put_json('{"foo":"barbaz"}');
```

Now things start becoming a little more *over-engineered* at this point.

The first bit is that the *code* inside an object is just the default.
Both the `get*` and the `put*` functions also accept another (initial)
parameter with a different code, which will be used instead *for the
specific call* (i.e. the cached code will not be changed):

```perl
my $mj = WebService::MyJSONs->new($somecode);
my $data = $mj->get($code);
my $json = $mj->get($json);
$mj->put($code, $data);
$mj->put_json($code, $json);
```

Well, there are a few nitty-gritty details, e.g. if we use `undef` onto
an object without a cached code, it will indeed be initialized.
Whatever.

The second piece of *over-engineering* is that the `put`/`put_json` pair
can double-down to *also* instantiate an object, as they always return
the instance. Hence, it's possible to call them as class methods
instead, and get an initialized object back. Depending on the presence
of the code or not, this will be a remote creation or an update:

```perl
my $mj_a = WebService::MyJSONs->put($data);
my $mj_b = WebService::MyJSONs->put($code, $data);
my $mj_c = WebService::MyJSONs->put_json($json);
my $mj_d = WebService::MyJSONs->put_json($code, $json);
```

At this point, it would just be unjust if the corresponding
`get`/`get_json` would only be instance methods. So... this works too:

```perl
my $data = WebService::MyJSONs->get($code);
my $json = WebService::MyJSONs->get_json($code);
```

So I guess that this is the SYNOPSIS of the module!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[MyJSONs]: https://www.myjsons.com
[Software Tools for Hobby-Scale Projects]: {{ '/2022/10/31/hobby-scale-projects/' | prepend: site.baseurl }}
