---
title: Ack and ag - beyond grep
type: post
tags: [ grep, ack, ag, toolbox ]
comment: true
date: 2019-09-29 17:24:14 +0200
---

Everybody loves [grep][], but sometimes we need to go beyond just looking
for a string inside a file.

## POSIX `grep` Can Have Many Options

Plain ol' [POSIX grep][grep] can be pretty boring to use, especially if
you're looking for a string in a source code tree. It doesn't even
support recursion in sub-directory, which would be the very bare minimum
for this activity (unless one is willing to use [find][], of course). It
also has a lot of restrictions, but it's useful to know it's there.

## GNU `grep` Is A De-Facto Standard

With [GNU grep][gnu-grep] we are already taking a step ahead, because it
provides not one but two different alternatives for doing recursion in a
tree of files. From the help:

{% highlight text %}
  -d, --directories            how to handle directories;
                               ACTION is 'read', 'recurse', or 'skip'
  -r, --recursive              like --directories=recurse
  -R, --dereference-recursive  likewise, but follow all symlinks
{% endhighlight %}

It also helps that it provides a lot of additional features, like e.g.
also look at some context around the match (options `-B` for lines
*before*, option `-A` for lines *after*), use [Perl][] compatible
regular expressions (option `-P`) and only print out the stuff that is
actually matched (option `-o`).

Alas, if you have a big project in a language that compiles source code
into some kind of target (e.g. C, C++, or Java), [GNU grep][gnu-grep]
will happily search through them all, potentially consuming a lot of
time looking for a string in binary files that you would otherwise skip.
So, it's time to go beyond that, too.

## Enter `ack`

[Ack][ack] was created by [Andy Lester][petdance] to go past a few of
[grep][]'s shortcomings, including also [GNU grep][gnu-grep]. In
particular, looking only in the right files was a driving principle, but
the author listed the [Top 10 reasons to use ack for source
code][ack-top-ten], which can illuminate on the other 9 reasons.

I usually don't need anything fancy, just looking for a pattern like
this:

{% highlight bash %}
$ ack '(?mxs: \A\s* sub \s+ (?: foo | bar) \b)'
{% endhighlight %}

[Ack][ack] is written in [Perl][], which makes it very portable around
and also explains why the regular expressions are expected to be
compatible with [Perl][].

[Ack][ack] can be installed by [downloading a single file][ack-install] and
setting as executable. As such, it's a wonderful candidate for the
[#toolbox][].

## Beyond `ack`

If you judge a software from the amount of its emulators, I would say
that [ack][] is a huge success. Many people found it useful, although
lacking in some sense or other, hence decided to rewrite it with some
different goals in mind. You can find a few of the alternatives
[here][ack-alternatives].

Among them we find [ag, the Silver Searcher][ag], which the author
describes as *5-10x faster than Ack* in typical usage. The command line
options are mostly compatible with [ack][]'s, although they diverged a
bit in time.

For just simple searches of a pattern you can just trade `ag` for `ack`,
although I'm not 100% sure that it supports the full gamut of options
and syntax you would expect in a [Perl][] regex; for this reason I'll
stick to a more portable example:

{% highlight bash %}
$ ag '^\s*sub\s+(foo|bar)\b'
{% endhighlight %}

One interesting aspect of [ag][] is that it's possible to compile it as
a static binary, which makes it extremely portable and a good component
of a [#toolbox][]. As an example, you can find a [binary rendition of
ag][binary-ag], compiled for x84\_64, so it's definitely possible.


[grep]: https://pubs.opengroup.org/onlinepubs/007904875/utilities/grep.html
[find]: https://pubs.opengroup.org/onlinepubs/009695399/utilities/find.html
[gnu-grep]: https://www.gnu.org/software/grep/
[Perl]: http://www.perl.org/
[ack]: https://beyondgrep.com/
[petdance]: http://petdance.com/
[ack-top-ten]: https://beyondgrep.com/why-ack/
[ack-install]: https://beyondgrep.com/install/
[#toolbox]: {{ '/tagged/#toolbox' | prepend: site.baseurl | prepend: site.url }}
[ack-alternatives]: https://beyondgrep.com/more-tools/
[ag]: https://geoff.greer.fm/ag/
[binary-ag]: https://github.com/andrew-d/static-binaries/blob/master/binaries/linux/x86_64/ag
