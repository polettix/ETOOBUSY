---
title: Jekyll in Docker
type: post
tags: [ jekyll, docker, dibs, gitlab ]
comment: true
date: 2020-03-16 07:00:00 +0100
preview: true
published: false
---

**TL;DR**

> If [Preview for Jekyll blog on GitHub Pages][blog-jekyll-ghp] was a neat
> hack, but you feel like something less... "open", testing out new posts
> locally is probably the only way. Here's how, in pure [Try with Docker][]
> spirit.

So, if you want to look at the posts *locally* before pushing them, you need
[Jekyll][] but - if you're like me - you don't want to install it.
[Docker][] to the rescue!

Well, yes... there is the [jekyll][] image in the [Docker Hub][], but I've
not been able to make it work for this blog. I take full responsibility for
this, of course.

This is why I decided to roll my own - you can find it in [GitLab][] as
[dokyll][]. If you have read something in this blog, you can safely bet that
it's a [dibs][] project.

The installation process follows the one from [jekyll][] prettly closely.
Calling it still has some... *rough* edges, but it's workable:

```shell
$ docker run --rm registry.gitlab.com/polettix/dokyll
cannot associate id '0' to 'jekyll' in '/etc/passwd'
```

This is [suexec][] complaining - it's a long story, the bottom line is that
you SHOULD pass the current directory for bind-mounting over `/mnt`, and you
will get some help:

```shell
$ docker run --rm -v "$PWD:/mnt" registry.gitlab.com/polettix/dokyll
Build the bundle cache:

    mkdir -p _bundle
    docker run --rm \
       -v "$PWD:/mnt" \
       -v "$PWD/_bundle:/usr/local/bundle" \
       registry.gitlab.com/polettix/dokyll \
       bundle install


Build the site, continuously:

    MULTICONFIG=''
    # MULTICONFIG='--config _config.yml,_local_config.yml'
    docker run --rm \
       -v "$PWD:/mnt" \
       -v "$PWD/_bundle:/usr/local/bundle" \
       registry.gitlab.com/polettix/dokyll \
       bundle exec jekyll build $MULTICONFIG --watch


Serve the site (only):

    MULTICONFIG=''
    # MULTICONFIG='--config _config.yml,_local_config.yml'
    docker run --rm \
       -p 4000:4000 \
       -v "$PWD:/mnt" \
       -v "$PWD/_bundle:/usr/local/bundle" \
       registry.gitlab.com/polettix/dokyll \
       bundle exec jekyll serve $MULTICONFIG \
       --no-watch --skip-initial-build --host=0.0.0.0
```

It's really just copy-paste, but...

- I keep a `_bundle` cache of compiled extensions, so the first command
  allows me to get that started with `bundle install`;

- using the trick [explained here][], I keep the site regenerating over and
  over with `bundle exec jekyll build ...`, and serve it without generating
  it with `bundle exec jekyll serve ...`. That's a super-neat trick that is
  a MUST when running [Jekyll][] from a [Docker][] container.




[blog-jekyll-ghp]: {{ '/2020/01/13/jekyll-ghp-preview' | prepend: site.baseurl | prepend: site.url }}
[Try with Docker]: {{ '/2020/01/21/try-with-docker' | prepend: site.baseurl | prepend: site.url }}
[Jekyll]: https://jekyllrb.com/
[Docker]: https://www.docker.com/
[Docker Hub]: https://hub.docker.com/
[jekyll]: https://hub.docker.com/r/jekyll/jekyll
[GitLab]: https://gitlab.com/
[dokyll]: https://gitlab.com/polettix/dokyll
[dibs]: http://blog.polettix.it/hi-from-dibs/
[suexec]: https://github.com/polettix/dibspack-basic/#wrapexecsuexec
[explained here]: https://github.com/jekyll/jekyll/issues/5743#issuecomment-351799034
