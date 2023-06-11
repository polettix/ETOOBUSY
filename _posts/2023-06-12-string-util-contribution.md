---
title: 'Literal string 0 is false in Perl'
type: post
tags: [ perl, module ]
comment: true
date: 2023-06-12 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A [pull request][] for [String::Util][].

I recently [posted about `String::Util`][supost], a nice idea for collecting
common functions that were partially made available through the [builtin][]
module.

Well, namespace. Well, way to access functions *built in* the interpreter.
*Whatever*.

> Thanks to Mutant Rob for reminding me about `builtin::trim` by the way!

As I was skimming through the docs of the module, I wondered how
`startswith`, `endswith` and `contains` were implemented. Surely there was
[index][] involved, right? [Sure it was][]:

```perl
sub contains {
	my ($str, $substr) = @_;

	if (!defined($str)) {
		return undef;
	}

	if (!$substr) {
		$substr = $str;
		$str    = $_;
	}

	my $ret = index($str, $substr, 0) != -1;

	return $ret;
}
```

Uh-oh.

I still have multiple scars from *this* particular bite, so I have a sort of
reflex when I see this:

```perl
if (!$substr) {
```

As everything with a soul, [Perl][] has its own ways of being useful which
can sometimes get in the way. Like, for example, not having a proper boolean
underlying type, and resorting to figuring it out in a *do what I mean* way:

Let's recap what [Perl][] thinks is *false*:

- Empty lists (also when expanding an array/hash).
- Empty strings.
- `undef` (this was easy)
- `0` (as a number)
- `'0'` (the string)

I was not there, but I guess that the fift one got some suspicious looks
back in the time, much like the [Parallel postulate][]... *yes... this makes
sense... but it's a bit close to the border...*.

I take it as a consequence of the seamless switch between
integers/numbers/strings that makes [Perl][] so friendly; sometimes, though,
it might mess things up, like in this case:

```perl
say 'yes' if endswith('total is 0', '0');
```

or, I daresay, the following case too:

```perl
say 'yes' if endswith('total is whatever', '');
```

So... instead of just writing about it here, it was time for a [pull
request][]! I hope it gets considered, evaluated, and eventually accepted
(as-is or with modifications, I might have deviated from the style in the
rest of the module...)

Until then... Stay safe!



[Perl]: https://www.perl.org/
[String::Util]: https://metacpan.org/pod/String::Util
[pull request]: https://github.com/scottchiefbaker/String-Util/pull/7
[index]: https://perldoc.perl.org/functions/index
[Sure it was]: https://github.com/scottchiefbaker/String-Util/blob/b68dbca6397ed5ac086bc0a7ea7a1f88004e5549/lib/String/Util.pm#L615
[Parallel postulate]: https://en.wikipedia.org/wiki/Parallel_postulate
[supost]: {{ '/2023/06/06/string-util/' | prepend: site.baseurl }}
[builtin]: https://metacpan.org/pod/builtin
