---
title: '=finish at the __END__'
type: post
tags: [ rakulang ]
comment: true
date: 2021-08-29 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Use `=finish` in [Raku][], instead of [Perl][]'s `__END__`.

Sometimes it takes a long journey to learn something that was right
there, where it makes sense.

I often use `__END__` in my [Perl][] programs to quickly cut out stuff
from one point of the file up to the end. So I tried to put it in a
[Raku][] program and **saw** this:

```
$ raku prova03.raku
===SORRY!=== Error while compiling /home/poletti/devel/rakudo/prova03.raku
Unsupported use of __END__ as end of code.  Blah blah blah
blah blah blah blah.
at /home/poletti/devel/rakudo/prova03.raku:6
------> __END__⏏<EOL>
```

Argh, a difference from the past. OK, let's ask the mighty internet.

Which, unfortunately, does not really help. I mean, there are questions
about how to replace `__DATA__` for putting... *data*, but nothing
really about using `__END__` they way I do.

More searching led me [to this][], though:

```
token term:sym<p5end> {
    << __END__ >>
    <.obs('__END__ as end of code',
      'the =finish pod marker and $=finish to read')>
}
```

So **this** is the solution: `=finish`!

> I wonder why I they don't write it somewhere...
>
> Wait a minute, that thing seems some feedback/help that is written
> when it's needed. I wonder if it's written when an error occurs! It
> would be so useful!
>
> Let's take a second look...

```
$ raku prova03.raku 2>&1
===SORRY!=== Error while compiling /home/poletti/devel/rakudo/prova03.raku
Unsupported use of __END__ as end of code.  In Raku please use: the
=finish pod marker and $=finish to read.
at /home/poletti/devel/rakudo/prova03.raku:6
------> __END__⏏<EOL>
```

🤦‍♂️

**Today I Learned**: don't skim [Raku][] error messages, *read them*!

And with this, I hope you too will read those error messages and avoid
falling in the same trap. Until the next time... stay safe!

[Raku]: https://www.raku.org
[Perl]: https://www.perl.org
[to this]: https://github.com/rakudo/rakudo/blob/master/src/Perl6/Grammar.nqp#L1511
