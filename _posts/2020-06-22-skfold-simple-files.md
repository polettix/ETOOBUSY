---
title: skfold - getting started with simple files
type: post
tags: [ skfold, perl, coding ]
comment: true
date: 2020-06-22 07:00:00
mathjax: false
published: true
---

**TL;DR**

> How to use [skfold][] for templetizing a few files

My last little project [skfold][] aims at scratching an itch I had since
some time, i.e. having some *general* way to *mint* something new. Some
time ago I gave this a try, but overengineered it and eventually forgot
how to use. Two errors in a single project, way to go!

This time I'm keeping it as simple as possible, as well as documenting
it. Hopefully my future me will appreciate. Hi Flavio!

We will assume that [skfold][] has been properly installed... maybe we
will get back to this in the future.

# Getting started

By default, [skfold][] looks for stuff in `~/.skfold/`, so let's get
that started:

```shell
SKFOLD_HOME="$HOME/.skfold"
mkdir -p "$SKFOLD_HOME/modules"
cat > "$SKFOLD_HOME/defaults.json" <<END
{
   "": {
      "abstract": "[Put something meaningful here!]",
      "author":   "Foo B. Baz",
      "email":    "foo.b.baz@example.com",
      "year":     "[%= (localtime)[5] + 1900 %]"
   }
}
END
```

If you're wondering, that's not an error: the object inside the JSON
file has (as of now) one single entry, with an empty key. These are the
*overall* defaults, i.e. defaults that will apply to whatever specific
[skfold][] module you will have. This is useful for setting stuff that
are more related to... you.

# Adding a module

In our example, we will create a module whose goal is to generate a new
directory for a `foobar`-type project, and populate it with a few files.

Modules are sub-directories inside the [skfold][] home directory, let's
create a simple example `foobar`:

```shell
SKFOLD_HOME="$HOME/.skfold"
MODULE_HOME="$SKFOLD_HOME/modules/foobar"
mkdir "$MODULE_HOME"
cd "$MODULE_HOME"
```

Here, we need to do two things:

- create the templates;
- create a configuration file for driving templates expansion.

## Creating templates

Templates are put in a `templates` sub-directory, so let's create it
first:

```shell
mkdir templates
```

Now, a template can be any file that uses the [Template::Perlish][]
syntax. Examples:

```shell
cat >templates/README.md <<END
[% abstract %]

# COPYRIGHT & LICENSE

The contents of this repository are licensed according to the Apache
License 2.0 (see file `LICENSE` in the project's root directory):

>  Copyright [% year %] by [% author %] ([% email %]).
>
>  Licensed under the Apache License, Version 2.0 (the "License");
>  you may not use this file except in compliance with the License.
>  You may obtain a copy of the License at
>
>      http://www.apache.org/licenses/LICENSE-2.0
>
>  Unless required by applicable law or agreed to in writing, software
>  distributed under the License is distributed on an "AS IS" BASIS,
>  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
>  See the License for the specific language governing permissions and
>  limitations under the License.
END

curl -Lo templates/LICENSE http://www.apache.org/licenses/LICENSE-2.0

cat >templates/gitignore <<END
*.swp
/tmp/
END
```

As you can see, some files indeed contain [Template::Perlish][]
placeholders (`README.md`), while others don't. Also, a file that is
normally hidden (`.gitignore`) appears without the initial `.`. so that
it's easier to know that it's there and work on it. It will fall in
place, eventually!

## Configuration file

The configuration file for the module goes into
`$MODULE_HOME/config.json`, and it's something like this:

```json
{
   "options": [
      {
         "mandatory": true,
         "getopt": "abstract|A=s"
      },
      {
         "mandatory": true,
         "getopt": "author|a=s"
      },
      {
         "mandatory": true,
         "getopt": "email|e=s"
      },
      {
         "mandatory": false,
         "getopt": "version|v=s",
         "default": "0.1"
      },
      {
         "mandatory": true,
         "getopt": "year|y=i"
      }
   ],
   "files": [
      {
         "source": "LICENSE",
         "destination": "LICENSE"
      },
      {
         "source": "README.md",
         "destination": "README.md"
      },
      {
         "source": "gitignore",
         "destination": ".gitignore"
      }
   ]
}
```

There are two main sections:

- `options` are command-line options that can be provided when invoking
  `skf` (i.e. [skfold][]'s executable). In our setup, it is *mandatory*
  to provide values for `abstract`, `author`, `email`, and `year`,
  although *all* of them have a *default* value accordig to our overall
  configuration in `$SKFOLD_HOME/defaults.json`, so no big deal;

- `files` sets the mapping from *source* files inside the `templates`
  sub-directory, and the *destination* files in the target directory. As
  you can see, here we transform the *visible* file `gitignore` into an
  *hidden* file `.gitignore`.

# Let's give it a try!

It's now time to call `skf`:

```shell
$ bin/skf -l INFO /tmp/prova foobar
[2020/06/21 18:38:51] [INFO ] applying module configuration adaptations
[2020/06/21 18:38:51] [INFO ] created target dir '/tmp/prova'
[2020/06/21 18:38:51] [INFO ] generating targets:
[2020/06/21 18:38:51] [INFO ] - LICENSE
[2020/06/21 18:38:51] [INFO ] - README.md
[2020/06/21 18:38:51] [INFO ] - .gitignore
[2020/06/21 18:38:51] [INFO ] applying post-operations
[2020/06/21 18:38:51] [INFO ] done
```

We are providing command-line option `-l INFO` to set it to verbose
execution and see what goes on. The other two options are the *target*
(i.e. the directory that we want to get started) and the *module* (i.e.
what we just created above).

All options are taken from the default values, so there is no missing
value. We can take a look at the `/tmp/prova/README.md` file to see that
it was correctly expaned:

```text
[Put something meaningful here!]

# COPYRIGHT & LICENSE

The contents of this repository are licensed according to the Apache
License 2.0 (see file  in the project's root directory):

>  Copyright 2020 by Foo B. Baz (foo.b.baz@example.com).
>
>  Licensed under the Apache License, Version 2.0 (the "License");
>  you may not use this file except in compliance with the License.
>  You may obtain a copy of the License at
>
>      http://www.apache.org/licenses/LICENSE-2.0
>
>  Unless required by applicable law or agreed to in writing, software
>  distributed under the License is distributed on an "AS IS" BASIS,
>  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
>  See the License for the specific language governing permissions and
>  limitations under the License.
```

Let's re-create putting something meaningful for the *abstract*:

```shell
$ bin/skf -l INFO tmp/prova foobar --abstract 'A sample foobar project'
[2020/06/21 18:42:33] [INFO ] applying module configuration adaptations
[2020/06/21 18:42:33] [FATAL] target directory '/tmp/prova' already exists
```

Ouch! It will refuse to overwrite stuff, so let's get rid of it
beforehand, then retry:

```shell
$ rm -rf /tmp/prova
$ bin/skf -l INFO /tmp/prova foobar --abstract 'A sample foobar project'
[2020/06/21 18:43:35] [INFO ] applying module configuration adaptations
[2020/06/21 18:43:35] [INFO ] created target dir '/tmp/prova'
[2020/06/21 18:43:35] [INFO ] generating targets:
[2020/06/21 18:43:35] [INFO ] - LICENSE
[2020/06/21 18:43:35] [INFO ] - README.md
[2020/06/21 18:43:35] [INFO ] - .gitignore
[2020/06/21 18:43:35] [INFO ] applying post-operations
[2020/06/21 18:43:35] [INFO ] done
$ cat /tmp/prova/README.md
A sample foobar project

# COPYRIGHT & LICENSE

The contents of this repository are licensed according to the Apache
License 2.0 (see file  in the project's root directory):

>  Copyright 2020 by Foo B. Baz (foo.b.baz@example.com).
>
>  Licensed under the Apache License, Version 2.0 (the "License");
>  you may not use this file except in compliance with the License.
>  You may obtain a copy of the License at
>
>      http://www.apache.org/licenses/LICENSE-2.0
>
>  Unless required by applicable law or agreed to in writing, software
>  distributed under the License is distributed on an "AS IS" BASIS,
>  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
>  See the License for the specific language governing permissions and
>  limitations under the License.
```

As expected, we got the right abstract as provided from the command
line, instead of the default one.

Seems to be working!

# Conclusions

This is enough for now. In future posts, we will see:

- what we can do if we want to generate many files from a single
  template (e.g. pre-populate a directory tree for [Perl][] modules
  inside a distribution)
- how to address one-off files, possibly on the standard output
  directly.

Stay tuned!

[skfold]: https://github.com/polettix/skfold
[Perl]: https://www.perl.org/
[Template::Perlish]: https://metacpan.org/pod/Template::Perlish#Templates
