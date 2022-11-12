---
title: 'Trying Object::Pad'
type: post
tags: [ perl, cor ]
comment: true
date: 2021-08-10 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I gave [Object::Pad][] a try.

I'm intrigued by the ongoing initiative to [Bring Modern OO to the Core
of Perl][Corinna], so I decided to give [Object::Pad][] a try.

My first (stripped down) example class was this:

```perl
use Object::Pad;

class TestClass {
   has $this :param :reader = 'that';
   method greet { say 'Hello, World!' }
   method announce ($msg) { say $msg }
}
```

and I hit an error! This error (line numbers will make sense shortly):

```
syntax error at lib/TestClass.pm line 9, near "method announce ("
Global symbol "$msg" requires explicit package name (did you forget to declare "my $msg"?) at lib/TestClass.pm line 9.
syntax error at lib/TestClass.pm line 9, at EOF
Parse error at lib/TestClass.pm line 9.
Expected } at lib/TestClass.pm line 9.
```

So I was... *What The Hell?!?*

Let's zoom out a bit to the whole program...


```perl
package TestClass;
use v5.24;
use warnings;
use Object::Pad;

class TestClass {
   has $this :param :reader = 'that';
   method greet { say 'Hello, World!' }
   method announce ($msg) { say $msg }
}

exit sub {
   TestClass->new->announce('Hey all!');
}->(@ARGV) unless caller;

1;
```

There it is... *the culprit*! I'm using [Perl][] in version `5.24`,
which is not supported for the signatures syntax for `method`,
[according to the author][bug].

So... either I update my `perl`, or I stick with the old-fashioned way
of taking parameters, i.e. use `@_`:

```perl
package TestClass;
use v5.24;
use warnings;
use Object::Pad;

class TestClass {
   has $this :param :reader = 'that';
   method greet { say 'Hello, World!' }
   method announce { say $_[0] }
}

exit sub {
   TestClass->new->announce('Hey all!');
}->(@ARGV) unless caller;

1;
```

Now *this* works and does not complain:

```
$ perl TestClass.pm 
Hey all!
```

What luck... I hit my first bug from the very beginning 😂

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Object::Pad]: https://metacpan.org/pod/Object::Pad
[Corinna]: https://github.com/Ovid/Cor
[bug]: https://rt.cpan.org/Public/Bug/Display.html?id=138578
