---
title: Read YAML front-matter with teepee
type: post
tags: [ perl, template ]
comment: true
date: 2022-05-07 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I updated [teepee][] to cope with YAML front-matter in Markdown
> documents.

In a few places - including this very blog site - Markdown documents are
pre-pended with a so-called *YAML front-matter*, which is a small
fragment of YAML configuration specific for that file.

As an example, this blog post has this at the beginning of the Markdown
source document:

```
---
title: Read YAML front-matter with teepee
type: post
tags: [ perl, template ]
comment: true
date: 2022-05-07 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I updated [teepee][] to cope with YAML front-matter in Markdown
> documents.

In a few places - including this very blog site - Markdown documents are
pre-pended with a so-called *YAML front-matter*, which is a small
fragment of YAML configuration specific for that file.

As an example, this blog post has this at the beginning of the Markdown
source document:
```

I recently wanted to use [teepee][] to get data from that
*front-matter*, but the parser failed miserably because YAML documents
can be chained, so by default the parser happily moves on parsing beyond
the closing `---` line. Ouch.

Anyway, I'm in full control of [teepee][], so it was easy to add options
`--yaml-1` and `--yaml-s1` to read only the *first* fragment of YAML
data from a file and from a string respectively.

> Technically speaking, you can be in control of [teepee][] too, because
> it's released under the [Artistic License 2.0][] and you can
> fork/contribute to it!

Now this works:

```
$ teepee --version
teepee 0.8.0

$ teepee --yaml-1 2022-05-07-teepee-yaml-frontmatter.md -FYAML
---
comment: 'true'
date: '2022-06-07 07:00:00 +0200'
mathjax: 'false'
published: 'true'
tags: '[ perl, template ]'
title: 'Read YAML front-matter with teepee'
type: post
```

Stay safe folks!

[Perl]: https://www.perl.org/
[teepee]: {{ '/2021/03/16/teepee/' | prepend: site.baseurl }}
[Artistic License 2.0]: http://www.perlfoundation.org/artistic_license_2_0
