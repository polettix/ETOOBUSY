---
title: 'App::Easer enhancement'
type: post
tags: [ perl ]
comment: true
date: 2021-08-16 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Making [App::Easer][] a little more consistent.

While using [App::Easer][], I noticed an inconsistency:

```
my $app = {
    commands => {
        key_for_foo => {
            supports => ['foo'],
            ...
        },
        key_for_bar => {
            supports => ['bar'],
            ...
        },
        MAIN => {
            children => [qw< key_for_foo key_for_bar >],
            'default-child' => 'foo',
            ...
        }
    },
    ...
};
```

In shorts, array `children` takes a list of the keys as they appear in
the `commands` hash, *but* `default-child` takes the name of one child
as it is seen outside. In the specific case, `children` contains
`key_for_bar` (which is the key in `commands`), while `default-children`
has `bar` (which is the supported name outside).

This is an inconsistency (over which I tripped, of course!), because
`default-child` should be in line with what is inside `children`. Which
leads us to the trial release I just sent to [CPAN][]: [App::Easer v0.3
TRIAL][trial]. Now `default-child` takes `key_for_bar` just like
`children`.

I hope it will be useful... to future me 😉

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[App::Easer]: https://metacpan.org/pod/App::Easer
[CPAN]: https://metacpan.org/
[trial]: https://metacpan.org/release/POLETTIX/App-Easer-0.003-TRIAL
