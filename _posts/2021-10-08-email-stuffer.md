---
title: 'Email::Stuffer'
type: post
tags: [ perl, email ]
comment: true
date: 2021-10-08 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Email::Stuffer][] is a useful module.

I recently needed to build and email and had to navigate through a
plethora of email modules in the [CPAN][].

I eventually landed on [Email::Stuffer][], which seems to get the job
done with a quite easy interface:

```perl
use Email::Stuffer;

my $email = Email::Stuffer
    ->from('me@example.com')
    ->to('you@example.com')
    ->subject('What ever!')
    ->text_body(<<'END');
Hello, World!

Good to see you... have a nice day!

Me.
END

$email->attach('Some added stuff',
    content_type => 'text/plain',
    disposition  => 'attachment',
    filename     => 'file-name.txt',
);

print {*STDOUT} $email->as_string;
```

There is another method for attaching stuff to the email - namely
`attach_file`.

Unfortunately it insists on getting a *real* file, not just something
that would be good for [open][]. This means that one has to explicitly
select the right method depending on whether there's some stuff inside a
scalar or inside a file (see [A file fetcher idea][] for why I would
ever need this).

So... here's how it would happen:

```perl
my $stuff = scalar_ref_or_filename();
my %args = (...);
if (ref $stuff eq 'SCALAR') { $email->attach($$stuff, %args)     }
else                        { $email->attach_file($stuff, %args) }
```

The docs say it's just good for *simple* emails... but I guess my needs
are simple these days!

Cheers folks, stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Email::Stuffer]: https://metacpan.org/pod/Email::Stuffer
[CPAN]: https://metacpan.org/
[open]: https://perldoc.perl.org/functions/open
[A file fetcher idea]: {{ '/2021/10/03/fetcher-idea/' | prepend: site.baseurl }}
