---
layout: page
title: About this blog...
mathjax: true
---

This is a minimalistic blog scaffolding that is supposed to work out of
the box in [GitHub Pages][ghp]. En-passant, it's also another small blog that
I'm keeping around.

## Features

This relies heavily on [Jekyll][] and the [TextLog][] theme. In
particular, [this page][tl-examples] has examples of what formatting
capabilities are available.

In addition, [MathJax][] can also be enabled so that you can write
$\sum_{i=0}^n i^2 = \frac{(n^2+n)(2n+1)}{6}$ and also:

$$\sum_{i=0}^n i^2 = \frac{(n^2+n)(2n+1)}{6}$$

You can also look at [several formatting hints][mathjax-examples]. To
enable it, add `mathjax: true` in the front matter of the page (look at
the first lines of [about.md][about-md-raw] to see how).

## Get your own

If you want to replicate it:

- create an account on [GitHub][]
- clone [the repository][etoobusy-gh]
- adapt some files:
   - `_config.yml` with the technical details of your blog
   - `about.md` with a lenghtier description of your blog
   - remove stuff in sub-directory `_posts`
- [enable GitHub Pages to publish your site from `master`][ghp-master]
  (use the `master branch` alternative)

Now you can add your posts inside the `_posts` sub-directory (even in
[GitHub][] itself).

[ghp]: https://pages.github.com/
[Jekyll]: https://jekyllrb.com/
[TextLog]: https://github.com/heiswayi/textlog
[tl-examples]: https://heiswayi.github.io/textlog/2017/01/15/example-content/
[MathJax]: https://www.mathjax.org/
[mathjax-examples]: https://math.meta.stackexchange.com/questions/5020/mathjax-basic-tutorial-and-quick-reference
[about-md-raw]: https://raw.githubusercontent.com/polettix/ETOOBUSY/master/about.md
[GitHub]: https://github.com
[etoobusy-gh]: https://github.com/polettix/ETOOBUSY
[ghp-master]: https://help.github.com/en/articles/configuring-a-publishing-source-for-github-pages#enabling-github-pages-to-publish-your-site-from-master-or-gh-pages
