---
title: Unmatched is indeed not the same as Excluded
type: post
tags: [ perl ]
comment: true
date: 2020-02-20 00:44:53 +0100
published: true
---

**TL;DR**

> [vti][] (Вячеслав Тихановский) eventually accepted the [pull request][]
> for distinguishing "unmatched" and "excluded" in [Text::Gitignore][].

Which puts an end to the saga that started in this [post about
Text::Gitignore][], was elevated to a stand-alone topic in [Unmatched is not
Excluded][] and eventually landed on a pull request as described in
[Unmatched is not Excluded - Pull Request is out].

The simplest solution in the pull request eventually got through: use of two
different variants of [Perl][] *false* - `undef` and something *false but
defined* - much like what happens with `wantarray`. This makes me happy
because it's backwards compatible, to the point and not over-engineered.

[vti]: https://github.com/vti
[pull request]: https://github.com/vti/text-gitignore/pull/5
[Text::Gitignore]: https://metacpan.org/pod/Text::Gitignore
[post about Text::Gitignore]: {{ '/2020/02/16/text-gitignore' | prepend: site.baseurl | prepend: site.url }}
[Unmatched is not Excluded]: {{ '/2020/02/17/multiple-falses-help' | prepend: site.baseurl | prepend: site.url }}
[Unmatched is not Excluded - Pull Request is out]: {{ '/2020/02/18/multiple-falses-pr' | prepend: site.baseurl | prepend: site.url }}
[Perl]: https://www.perl.org/
