---
title: 'Data::Resolver tricky test'
type: post
tags: [ perl ]
comment: true
date: 2023-05-24 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I hope a new test for [Data::Resolver][] will be successful.

In [Data::Resolver refactoring][] I digressed about re-implementing some
interface functions in terms of the new underlying class
`Data::Resolver::Asset`.

One thing that came out during the implementation was that the `file()`
implementation - where you might want to get hold of a *file* - might
actually have one additional requirement about *persistence* after exiting
the process.

Up to some time ago, we would only get back a temporary file that would
disappear after the process goes away. This is some kind of minimum viable
product, because the recipient of this file might always produce a copy and
get a persistent representation.

On the other hand, it was something useful so I decided to go for it.

To test it, the best think I could figure out is to `fork()` to a child
process that calls the `file()` method, then check in the parent process
whether the deletion (or lack thereof) is successful. It's a long time I
don't play with `fork()`, so I hope I got it right:

```perl
sub forked_data_to_file ($data, $keep) {
   pipe my $rfh, my $wfh or die "pipe(): $!";
   my $pid = fork() // die "fork(): $!";
   if ($pid) { # parent process
      close $wfh;
      my ($filename) = <$rfh>;
      close $rfh;
      wait;
      return $filename;
   }
   else {
      close $rfh;
      my $path = data_to_file($data, $keep);
      print {$wfh} $path;
      close $wfh;
      exit 0;
   }
}
```

Before spawning the child process, we create a pair of connected sockets,
one for reading and one for writing. This will allow the child process to do
the `file()` magic and pass the name of the generated file back to the
parent.

I'm a bit worried about releasing this test, especially regarding Windows
where I know that `fork()` is not a prime-class citizen.

Additionally, I'm not even sure I'm getting the `close()` and `wait()` order
right. Or if I'm missing anything. A few tests on my VM seem to be fine,
but... they're a few tests on my VM.

I'll eventually bite the bullet and do a trial release, anyway.

Stay safe!

[Perl]: https://www.perl.org/
[Data::Resolver refactoring]: {{ '/2023/05/22/data-resolver-refactoring/' | prepend: site.baseurl }}
[Data::Resolver]: https://metacpan.org/pod/Data::Resolver
