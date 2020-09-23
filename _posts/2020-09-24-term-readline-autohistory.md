---
title: Disabling autohistory in Term::ReadLine
type: post
tags: [ perl, readline ]
comment: true
date: 2020-09-24 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> It's possible to disable the *autohistory* feature in
> [Term::ReadLine][] backends and take control of how to populate
> history.

From time to time I use [Term::ReadLine][] to provide a nicer interface
to the user. I'm not exactly fond of these CLIs, but they can be useful.

# Installing

[Term::ReadLine][] is in [Perl][] core so you don't have to install it.

BUT.

Remember to install a decent backend. By default you get a *stub*
implementation that does not really support much, like basic history
management. Without it, I find it on par to a simple [readline][].

At the very minimum you might install is [Term::ReadLine::Perl][]; if
possible, you might want to look at [Term::ReadLine::Perl5][] or even
[Term::ReadLine::Gnu][].

It might be that you will need to install [Term::ReadKey][]. It's not
entirely clear to me where this is indeed *necessary*; in my small test
in a Linux box I just got a warning that I was able to silence without
losing the functionalities I was after.

Enough with installing.


# History Control

One thing that you usually get out of the box is *autohistory*: whatever
is typed gets automatically added to the history, avoiding repetitions.
This is a decent default, but fails miserably when you don't want to
save some commands (e.g. with passwords).

I have to thank [LanX][] on [Perl Monks][] for [this post][], where this
concern is addressed and solved! This is a sample code based on that
example:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use Term::ReadLine;

my $term = Term::ReadLine->new('Hello, World!');
my $out = $term->OUT || \*STDOUT;
say {$out} 'using ', $term->ReadLine;

# This disables autohistory
$term->MinLine();

my $last_added = '';
while (defined (my $input = $term->readline('input> '))) {
   say {$out} "you told <$input> (use up arrow to recall past inputs)";
   next if $input eq $last_added;
   $input =~ s{\A password .*}{password }mxs;
   $term->addhistory($input);
   $last_added = $input;
}
```

When you run it, you will notice that when you write e.g. `password
53cr31` you then get `password ` in the history.

Thanks [LanX][]!



[Term::ReadLine]: https://metacpan.org/pod/Term::ReadLine
[readline]: https://perldoc.perl.org/functions/readline.html
[Term::ReadLine::Perl]: https://metacpan.org/release/Term-ReadLine-Perl
[Term::ReadLine::Perl5]: https://metacpan.org/pod/Term::ReadLine::Perl5
[Term::ReadLine::Gnu]: https://metacpan.org/pod/Term::ReadLine::Gnu
[LanX]: https://www.perlmonks.org/?node_id=708738
[Perl Monks]: https://www.perlmonks.org/
[this post]: https://www.perlmonks.org/?node_id=1007444
[Perl]: https://www.perl.org/
[Term::ReadKey]: https://metacpan.org/pod/Term::ReadKey
