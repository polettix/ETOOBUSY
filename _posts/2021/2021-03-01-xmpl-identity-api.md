---
title: 'xmpl - the identity API'
type: post
tags: [ perl, mojolicious, coding ]
series: xmpl
comment: true
date: 2021-03-01 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> The *identity API* in [xmpl][].

Considering that several instances of [xmpl][] might be chained
together, it's useful to have an API to figure out who is who. This is
where the endpoint `/identity` comes from:

```perl
get '/identity' => sub ($c) { $c->render(json => {id => identity()}) };
put '/identity' => sub ($c) {
    identity($c->req->text // '');
    $c->rendered(204);
};
```

The API provides both a facility to *get* the identity, as well as one
to *set* it to a string, This input string will be trimmed and kept if
it contains at least one non-space character.

The actual workhorse is the `identity()` function, which works somehow
like a method in disguise in that it exposes a double interface, i.e. a
*getter* and a *setter* in one single function. The value is kept in a
`state` variable:

```perl
sub identity ($new_value = undef) {
   state $id = default_identity();
   $id = trim_or_default($new_value, \&default_identity)
       if defined $new_value;
   return $id;
}
```

In pure getter/setter spirit, the value of state variable `$id` is set
to a `$new_value` only if this is defined. Moreover, the function also
makes sure to remove leading and trailing spaces, as well as ensuring
that the final result contains some non-spacing character (i.e. it's not
empty).

The `default_identity` can be set externally through environment
variable `IDENTITY`:

```perl
sub default_identity {
   state $id = trim_or_default($ENV{IDENTITY}, \&random_identity);
}
```

Again, the code makes sure to fallback to a default if there's no
meaningful `IDENTITY` set in the environment, by means of
`random_identity`:

```perl
sub random_identity {
   return trim_or_default(
      eval { require Sys::Hostname; Sys::Hostname::hostname() },
      sub { sha1_sum(Time::HiRes::time() . '-' . rand()) },
   );
}
```

As a first attempt, this fallback identity is not random at all,
attempting to take the hostname. As a further fallback, a random code is
generated from the time and a random draw. This should eventually do.

The `trim_or_default` function is a masterpiece of overengineering:

```perl
sub trim_or_default ($string, $default) {
   ($string //= '') =~ s{\A\s+|\s+\z}{}gmxs;
   return $string if length $string;
   $default = $default->() if ref($default) eq 'CODE';
   return trim_or_default($default, Time::HiRes::time());
}
```

The input string might be `undef` but it's OK. The trimming happens,
then if the string is not empty it is returned. Otherwise...

- ... if the *default* value is a code reference, it is executed. This
  allows delaying the execution of the associated code only at the
  moment when it's strictly necessary;
- ... afterwards, the outcome might use some trimming itself. But wait!
  `trim_or_default` does exactly this... hence the recursive call!

I guess it's enough boredom for today, have a good one!


[xmpl]: https://gitlab.com/polettix/xmpl
