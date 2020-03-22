---
title: Shell script help
type: post
tags: [ shell, coding, perl ]
comment: true
date: 2020-03-20 08:46:24 +0100
published: true
---

**TL;DR**

> A small technique to add help text to a shell script.

In yesterday's post [A shell approach][] we introduced a simple technique to
make a shell script double down as a library of shell functions, as well as
an entry point to consume those functions as *sub-commands*.

At this point, it becomes imperative to also introduce some form of
documentation that can be easily consumed to get help about these functions.
Comments alone, while useful when using the script as a library, become
difficult for end users of sub-commands.

I use something similar to these two functions here:

```shell
commands() { #<command>
#<help> usage: commands
#<help> print a list of available commands.
   {
   	printf '%s available (sub-)commands:\n' "$0"
      sed -ne '/#<command> *$/s/\([a-zA-Z0-9_]*\).*/- \1/p' "$0"
		printf 'Run the help command for help on each of the commands above\n'
   } >&2
}

help() { #<command>
#<help> usage: help
#<help> print help for all available commands
   {
      printf '\nUsage: %s <command> [<arg> [...]]\n\n' "$0"
      printf 'Available (sub-)commands:\n'
      sed -ne '
         /#<command> *$/s/\([a-zA-Z0-9_]*\).*/\n- \1/p
         s/^#<help> /    /p
         s/^#<help>//p
      ' "$0"
   } >&2
}
```

They rely upon putting *specially formatted/tagged comments* that provide
hints about which functions are also sub-commands (the `#<command>` marker)
and what constitues a comment that should be shown as help (the `#<help>`
marker). So, it is supposed to be paired to something like the comments for
those two functions, or the following ones:

```shell
foo() { #<command>
#<help> usage: foo <frob> [<taz> [...]]
#<help> apply the foo function to frob, optionally taking into account one
#<help> or more taz-es.
   local frob="$1"
   shift
   printf '%s\n' "foo($frob) with <$*>"
}

# This comment is ignored by the help function
bar() { #<command>
#<help> usage: bar <n> <m>
#<help> compute bar on n and m and print the result out.
   local n="$1"
   local m="$2"
   printf '%s\n' "$((n + m))"
}
```

When coding in [Perl][], I usually avoid interspersing documentation and
code like this, but I guess that it's fine in this case, and easier to
manage.

Here is a run of [the full example][]:

```shell
$ ./20200320-example.sh 
./20200320-example.sh available (sub-)commands:
- commands
- help
- foo
- bar
Run the help command for help on each of the commands above
$ 
$ ./20200320-example.sh commands
./20200320-example.sh available (sub-)commands:
- commands
- help
- foo
- bar
Run the help command for help on each of the commands above
$ 
$ ./20200320-example.sh help

Usage: ./20200320-example.sh <command> [<arg> [...]]

Available (sub-)commands:

- commands
    usage: commands
    print a list of available commands.

- help
    usage: help
    print help for all available commands

- foo
    usage: foo <frob> [<taz> [...]]
    apply the foo function to frob, optionally taking into account one
    or more taz-es.

- bar
    usage: bar <n> <m>
    compute bar on n and m and print the result out.

$ 
$ ./20200320-example.sh foo gafurgh gal ook
foo(gafurgh) with <gal ook>
$ 
$ ./20200320-example.sh bar 33 9
42
$ 
```

Thoughts? Questions? Use the comments box below!

[Perl]: https://www.perl.org/
[A shell approach]: {{ '/2020/03/19/a-shell-approach/' | prepend: site.baseurl | prepend: site.url }}
[the full example]: {{ '/assets/code/20200320-example.sh' | prepend: site.baseurl | prepend: site.url }}
