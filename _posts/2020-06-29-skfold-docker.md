---
title: skfold - a Docker image
type: post
tags: [ skfold, dibs, docker ]
series: skfold
comment: true
date: 2020-06-29 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Now [skfold][] is also available as a [Docker][] image.

In [issue 465][] of [Perl Weekly][], [Gabor Szabo][] nicely points out:

> The question though how can you make skafold easily distributable?
> Asking the users to install Perl and on top of that install skafold
> would probably limit the reach of the project.

This is totally right.

My answer is three-fold:

1. I do not care too much about it. As most of the things I do, I'm not
really into *promoting* it too much - heck, I did even automate the
notification process on *social media*, which is as lame as you can
think.

2. [Perl][] is an amazing tool, easily available in all platform where
one is likely to do actual development on (usually, your laptop).
Chances are it's already there for a reason or another; if not, it's
usually very, very easy to install it, because most Linux distributions
have it as a package, Mac OS X has it, and Windows is easily addressed
(e.g. through [Strawberry Perl][]). If it's still a show-stopper for
someone... I guess we fall back on point 1 above 😜

3. I'm also offering a [Docker][]-based alternative!

# Getting the Docker image

The [skfold Docker image][] is hosted in the [skfold][] repository in
[GitHub][]. You can easily grab it:

```shell
export SFK_IMAGE='docker.pkg.github.com/polettix/skfold/skf:latest'
docker pull "$SKF_IMAGE"
```

although you will have to be logged in [GitHub][]'s [Docker][] registry
to do this.

Other *tags* for the image are `0.1` and `0.1.0` (there's also a
date-specific tag that is only useful for tracking).

# Using the image: the shell wrapper

The image is a wrapper around [skfold][], with a couple of added
command-line options to ease its usage.

One is `--wrapper`:

```shell
$ docker run --rm "$SKF_IMAGE" --wrapper

*** WARNING: not remapping user <urist> to user id 0

skf() {
   : ${SKF_IMAGE:="docker.pkg.github.com/polettix/skfold/skf:latest"}
   docker run --rm \
      -v "$PWD:/mnt" \
      -v "$HOME/.skfold/defaults.json:/app/.skfold/defaults.json:ro" \
      "$SKF_IMAGE" "$@"
}
```

Ignore the warning... it' OK at this stage (it's also printed on the
standard error, so you can avoid printing it pretty easily).

The result on standard output is a simple shell wrapper function that
you can customize to your heart's content to ease calling the program
without dieing from typing.

By default:

- it bind-mounts the current working directory as `/mnt` inside the
  container, which is also where the program will work. Although the
  image is executed as `root`, permissions are dropped (via [suexec][])
  early on, so that operations are run with the same user as the owner
  of the mounted directory;

- it also assumes that you have your `defaults.json` file in the right
  directory, but probably not all modules - for this reason, it only
  bind-mounts file `~/.skfold/defaults.json`. You can of course modify
  this line to mount your own `~/.skfold` directory instead (see further
  on for an example).

If that is fine with you, you can `eval` the wrapper and get the wrapper
function.

```shell
$ eval "$(docker run --rm "$SKF_IMAGE" --wrapper)"

*** WARNING: not remapping user <urist> to user id 0

```

Or put it in your shell inizialization file (e.g. `~/.bashrc`
if you use [bash][]).


# Using the image: the tarball

The [skfold Docker image][] contains the modules distributed in
[skfold][] by default. If you want to extract them, e.g. to customize
and/or add others, you can easily do this with option `--tarball`, whick
outputs a tar file on the standard output:

```shell
$ docker run --rm "$SKF_IMAGE" --tarball | tar xC ~
```

This will create/overwrite `~/.skfold`, so use with caution!

When you have your full-blown `~/.skfold` directory, your wrapper shell
function is probably better expressed as follows:

```shell
skf() {
   : ${SKF_IMAGE:="docker.pkg.github.com/polettix/skfold/skf:latest"}
   docker run --rm \
      -v "$PWD:/mnt" \
      -v "$HOME/.skfold:/app/.skfold:ro" \
      "$SKF_IMAGE" "$@"
}
```

# A note on the warning...

Remember the warning we got before?

```
$ docker run --rm "$SKF_IMAGE"

*** WARNING: not remapping user <urist> to user id 0

...
```

This is [suexec][] complaining because we are not bind-mounting anything
on `/mnt` and it belongs to `root` inside the container (which has user
identifier `0`). As we were saying before, it can be ignored.

After you do the bind-mounting, though, this error message will
disappear. Unless you're `root`, of course 🤓. This also happens when
you install the wrapper, because it takes care to do the bind-mounting.


# Using the image: all the rest

Any other parameers combination is actually passed to the [skfold][]
executable inside the image, so nothing new here:

```shell
$ skf
# skf version 0.1.0 - more info with
# skf --usage|--help|--man
# Available modules:
perl-distro
dibs

$ skf --usage
Usage:
       skf [--usage] [--help] [--man] [--version]

       skf --help-on <module>
       skf -h        <module>

       skf [-b|--base <dir>]
           [-l|--loglevel <level>]
           [-q|--quiet]
           <target> <module> [<module options...>]
```

For technical reasons, the `--man` option will not invoke the pager out
of the bat... it's a small price to pay 😇

# Conclusions

So there you have it: if you feel like not installing [Perl][], you will
surely have [Docker][] around!

*And, again, I would not understand this prejudice against
[Perl][]...*

[skfold]: https://github.com/polettix/skfold
[Perl]: https://www.perl.org/
[dibs]: http://blog.polettix.it/hi-from-dibs/
[Perl Weekly]: https://perlweekly.com/
[issue 465]: https://perlweekly.com/archive/465.html
[Gabor Szabo]: https://szabgab.com/
[Strawberry Perl]: http://strawberryperl.com/
[Docker]: https://www.docker.com/
[skfold Docker image]: https://github.com/polettix/skfold/packages?package_type=Docker
[GitHub]: https://github.com/
[suexec]: https://github.com/polettix/dibspack-basic/#wrapexecsuexec
[bash]: https://www.gnu.org/software/bash/
