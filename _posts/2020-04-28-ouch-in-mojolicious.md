---
title: Ouch in Mojolicious
type: post
tags: [ perl, mojolicious, module ]
comment: true
date: 2020-04-28 07:00:00 +0200
published: true
---

**TL;DR**

> How I use [Ouch][] with [Mojolicious][], probably in a naïve way.

In a [previous post][Ouch-post] we took a look at [Ouch][], which I feel
like a very *natural* way of dealing with exceptions, including *web-by*
things that I do with [Mojolicious][] from time to time. I usually also
*throw* [Try::Catch][] in them mix, if you're so kind to pass the
terrible pun.

This is how I set up things to handle [Ouch][] exceptions in the
*application* class:

```perl
package MyApp;
use Mojo::Base 'Mojolicious', '-signatures';
use Try::Catch;
use Ouch ':trytiny_var';

# ...
sub startup ($self) {
   # ...

   $self->hook(
      around_dispatch => sub ($next, $controller) {
         try { $next->() }
         catch {
            die $_ if $_->isa('Mojo::Exception');
            $controller->render(
               status => $_->code,
               json   => { message => $_->message },
            );
         };
      }
   );

   # ...
}
```

But there you have it: if it's some *normal exception*
(*COUGH*oximoron*COUGH*) from [Mojolicious][] then it gets passed along,
otherwise we honor [Ouch][]'s interface and set the status code in the
response accordingly. Which makes it extremely easy to do this in a
controller method of a controller class:

```perl

sub get_some_resource ($self) {
   my $id = $self->param('id');
   my $item = $self->model->get($id)
     or ouch 404, 'Not Found';        # returns a 404
   makes_sense($item)
     or ouch 500, 'Sorry, something is wrong with me!';
  return $self->render(json => $item);
}

```

This is really just a prototype at this point. For example: what to do
with *additional `$data`* in the exception from [Ouch][]? I'll have to
look into it, most probably it should result in some astute logging.
What if the exception is not a blessed object and cannot sustain the
burden of the `isa` call? Only time will tell!

[Ouch-post]: {{ '/2020/04/27/ouch/' | prepend: site.baseurl | prepend: site.url }}
[Ouch]: https://metacpan.org/pod/Ouch
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Try::Catch]: https://metacpan.org/pod/Try::Catch
