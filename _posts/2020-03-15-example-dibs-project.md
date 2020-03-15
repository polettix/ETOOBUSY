---
title: Example dibs project: Hello Web World
type: post
tags: [ dibs, docker, gitlab ]
comment: true
date: 2020-03-15 01:12:16 +0100
preview: true
---

**TL;DR**

> There's an [example repository][hello-web-world] that doubles down as a
> [dibs][] example *and* a simple *hello-world*ish [Docker][] image,
> providing a web page.

I wanted to produce a simple container image with a webserver and a page
inside. Being fond of [Alpine Linux][], I decided to use it and install
[nginx][]. Soon, I reached to [dibs][] for automating the image production
process.

I decided to adopt the *developer mode* for this project:

```
.
├── .git
│   ...   
├── dibs
│   ├── dibs.yml
│   └── pack
│       └── create.sh
├── html
│   ├── check.png
│   ├── index.html
│   └── style.css
├── LICENSE
├── nginx.conf
└── README.md
```

i.e. the main directory is used to keep the code (which MUST be tracked with
[git][]), and [dibs][]'s stuff is kept inside its own sub-directory.

The most complicated part from the configuration file is probably the
version management, which allows generating different tags flexibly (e.g. in
the setup below, it allows generating both `1.0` and `1.0.0`, as well as
`latest` and a tag that is based on the timestamp):

```yaml
---
name: &name polettix/hello-web-world

variables:
   - &base_image 'alpine:3.9'
   - &repository 'registry.gitlab.com'
   - &target_image_name ['join', '/', *repository, *name]
   - &version_major  '1'
   - &version_minor  '0'
   - &version_patch  '0'
   - &version_majmin ['join', '.', *version_major, *version_minor]
   - &version        ['join', '.', *version_major, *version_minor, *version_patch]
   - unexpanded:
      tags: &version_tags ['*', 'latest', *version_majmin, *version]

actions:
   default:
      - from: *base_image
      - name: do everything
        user: root
        pack: 'project:create.sh'
        commit:
           entrypoint: []
           cmd:        ['nginx', '-g', 'daemon off;']
           user:       root
      - name: save image
        image_name: *target_image_name
        tags: *version_tags
```

If you want to clone this example, you might be interested into changing the
`name` at the very beginning, to reflect your [GitLab][] username.

This is a small example but shows one of the reasons why I still find
[dibs][] useful: offload all the execution part to an external script that
can be properly *edited*. This is the sense of line `pack:
'project:create.sh'`, which instructs `dibs` to go look for a `create.sh`
program inside sub-directory `pack` (i.e. find a script that is provided
within the *dibs project*) and execute it inside the container. This script
is straightforward:

```shell
#!/bin/sh
exec 1>&2  # send everything to log

srcdir="$(cat DIBS_DIR_SRC)"

apk update
apk add --no-cache nginx

rm -f /etc/nginx/conf.d/*
cp "$srcdir"/nginx.conf /etc/nginx
rm -rf /usr/share/nginx/html
mkdir -p /usr/share/nginx
tar cC "$srcdir" html | tar xC /usr/share/nginx
```

and it could have been included directly in the `dibs.yml` file if I wanted
to keep things compact (which, in this case, might have been understandable
anyway):

```
# ...
actions:
   default:
      - from: *base_image
      - name: do everything
        user: root
        pack:
           run: |
              #!/bin/sh
              exec 1>&2  # send everything to log

              srcdir="$(cat DIBS_DIR_SRC)"

              apk update
              apk add --no-cache nginx

              rm -f /etc/nginx/conf.d/*
              cp "$srcdir"/nginx.conf /etc/nginx
              rm -rf /usr/share/nginx/html
              mkdir -p /usr/share/nginx
              tar cC "$srcdir" html | tar xC /usr/share/nginx

        commit:
           entrypoint: []
           cmd:        ['nginx', '-g', 'daemon off;']
           user:       root
      - name: save image
        image_name: *target_image_name
        tags: *version_tags
```

Hence, [dibs][] does not force a style on you... just tries to support you
creating your own and evolve it in time as things might get more or less
complicated.

Cheers!

[hello-web-world]: https://gitlab.com/polettix/hello-web-world
[dibs]: http://blog.polettix.it/hi-from-dibs/
[Docker]: https://www.docker.com/
[Alpine Linux]: https://www.alpinelinux.org/
[nginx]: https://www.nginx.com/
[git]: https://www.git-scm.com/
