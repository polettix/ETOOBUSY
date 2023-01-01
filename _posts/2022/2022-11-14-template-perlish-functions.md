---
title: 'Template::Perlish: added functions injection'
type: post
tags: [ perl, template ]
comment: true
date: 2022-11-14 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Streamlining [Adding functions in Template::Perlish][].

*Less than* six months ago I wrote [Adding functions in
Template::Perlish][], describing a possible way to... well, adding
functions in [Template::Perlish][], a module that reinvents the good old
template expansion wheel.

Since then, of course, I had a bug in the head to make it as easy as
possible. Because, you know, I've been needing this for some time.

There's been a bit of refactoring of the sections where *other*
functions are injected since a long time, eventually resulting in a very
compact change (*in the right place*):

```perl
# custom functions to be injected
if (defined(my $custom = $self->{functions})) {
   push @code, map {
      "   local *$_ = \$self->{functions}{$_};\n"
   } keys %$custom;
}
```

That's it: it's possible to pass a `functions` reference to a hash of
name/sub pairs, and this will be *temporarily* injected in the
template's visibility as directly-callable functions. This also works in
`render()`, the one-stop-shop for expanding templates.

Here's an example:

```perl
use Template::Perlish 'render';

my $template = <<END_OF_TEMPLATE;
- variable<[% foo %]>
- missing<[% galook %]>
- function<[%= baz() %]>
- missing-function<[%= eval { missing() } or 'missing!' %]>
END_OF_TEMPLATE

my $processed = render(
   $template,
   {foo => 'bar'},    # variables
   {                  # options
      functions => {  # THE NEW STUFF!
         baz => sub { return 42 },
      },
   },
);
```

Output:

```
- variable<bar>
- missing<>
- function<42>
- missing-function<missing!>
```

As already pointed out in the docs, this module will not prevent anyone
from shooting into their foots. I mean, it literally supports execution
of arbitrary [Perl][] code. Hence, use it only after carefully
understanding the risk.

Stay safe!

[Perl]: https://www.perl.org/
[Adding functions in Template::Perlish]: {{ '/2022/05/20/template-perlish-adding-functions/' | prepend: site.baseurl }}
[Template::Perlish]: https://metacpan.org/pod/Template::Perlish
