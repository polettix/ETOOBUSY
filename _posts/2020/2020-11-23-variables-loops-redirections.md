---
title: Variables, loops, and redirections
type: post
tags: [ shell, coding ]
comment: true
date: 2020-11-23 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Sometimes variables in a shell can bite you when used in loops with
> redirections.

My colleague A. uses the shell to solve actual problems (*as opposed as
using it as an excuse to write blog posts* 🙄) and sometimes comes with
interesting questions.

In the last days, he was biten by the following classical issue:

```shell
generate_data() { printf 'yadda\nyadda\nyadda\n' ; }

count=0
generate_data | while read input ; do
   count=$((count + 1))
   # do something with $input...
done
printf 'count = <%d>\n' "$count"
```

In many shells, the `printf` in the last line will print:

```
count = <0>
```

How come it's not `3`? I.e. how come it was not incremented in the `while`
loop?

# A choice of multiple processes

The key element to understand what's going on is that the output of
`generate_data` is fed into the `while` loop using a *pipe operator* (i.e.
the `|` characters):

```shell
generate_data | while read input ; do
```

In general, this can be expressed as:

```shell
left_command | right_command
```

To implement this, the shell will spawn a different sub-shell, so that one
part of the pipe is executed in the *current* shell, and the other part is
executed in the *other* shell.

At this point, it's up to the actual implementation of the shell to decide
which part is kept in the *current* shell. In [bash][] and [dash][], the
`left_command` command wins, so in our example the `while` loop is executed
inside the *other* sub-shell.

As a consequence, the `count` variable that is initialized before the pipe
of commands is *copied* into the sub-shell of the `while`, but after this
copy there are two `count` variables and they are not connected any more.
When the pipe ends... the `count` variable inside the sub-shell executing
the `while` loop is lost for good.

So... we have to look for alternatives.

# Move `count` closer to the loop

One way to address this issue is to keep control over the `count` variable,
making sure that the one we initialize remains the same as the one we
increment in the loop and then print in output. Curly braces can help us
keep all these things together:

```shell
generate_data | {
   count=0
   while read i ; do
      count=$((count + 1))
      # ...
   done
   printf 'count = <%d>\n' "$count"
}
```

This works fine if we can delimit the *scope* where we need to use the
`count` variable, i.e. if we don't need it later for some other reason.

A variant of this approach would be to put all the instructions inside a
separate shell function; this has the added advantage of letting us be very
descriptive as to what the expected scope of the `count` variable should be,
by means of `local`:

```shell
process_data() {
   local count=0
   while read i ; do
      count="$((count + 1))"
      # ...
   done
   printf 'count = <%d>\n' "$count"
}
generate_data | process_data
```

# Move the loop closer to `count`

If the usage of `count` spans over multiple lines of code, possibly with
other data taken as input, the technique in the previous section might not
be helpful or easy to use.

So... if we can't put the `count` variable *in* the sub-process, we might
manipulate code to extract the `while` *out* of the sub-process, right?

One way to do this is to avoid the pipe completely and find a different way
to feed the `while` input with the output from `generate_data`.
[Here-documents][here-doc] can help us with this:

```shell
count=0
while read i ; do
   count=$((count + 1))
   # ...
done <<END
$(generate_data)
END
printf 'count = <%d>\n' "$count"
```

The idea is simple: redirecting the input of a command does not trigger
running the command in a sub-shell. So this keeps the `while` in the same
scope as the variable `count` that is initialized before it and printed
after it.

The `generate_data`, though, is called in a sub-shell this time: inside the
[here-doc][] there is a call with `$( ... )` which does exactly this. Its
output is expanded in the [here-doc][] and then fed as input to the `while`
loop. Job done!


# Here-strings (bashisms)

If you're using the [bash][] shell, you can trim off some characters off of
the [here-doc][] solution in the previous section by means of a
[here-string][]:

```shell
count=0
while read i ; do
   count=$((count + 1))
   # ...
done <<<"$(generate_data)"
printf 'count = <%d>\n' "$count"
```

It results in shorter and, in my opinion, easier to read code.

But if you really have [bash][], why not use...

# Process subtitution

In decently recent [Linux][] releases (and many more other operative
systems, I guess!) it's possible to leverage [process substitution][], which
is probably a cleaner way to pass data than using [here-documents][here-doc]
or [here-strings][here-string]:

```shell
count=0
while read i ; do
   count=$((count + 1))
   # ...
done < <(generate_data)
printf 'count = <%d>\n' "$count"
```

Note that there is a *space* character between the two `<` characters,
because the first one tells the shell to get the standard input for the
`while` loop from a *file* (i.e. it is a plain, boring redirection operator)
and the second one implements [process substitution][], materializing that
input *file*. Neat!

One *very interesting* characteristic of [process substitution][] is that it
lets us turn *many* sub-commands into files at the same time, and feed all
of them as input to a single command. As an example, this will work as one
might expect:

```shell
diff <(command_1) <(command_2)
```

The `diff` command is fed two *files* that it will be able to *open* and
*read* from.

Curious about these files? Let's take a look at them:

```shell
$ print_args() { printf '1<%s>\n2<%s>\n' "$1" "$2"; }
$ print_args <(date) <(ls / | grep a)
1</dev/fd/63>
2</dev/fd/62>
```

# So many ways to choose from

At this point, I guess I'm out of alternatives. There will surely be a lot
more - like... saving the output in a file and then consuming it afterwards
with standard input redirection - but I guess that the alternatives above
should fit in almost all situtations.

Stay safe and have a good day!


[bash]: https://www.gnu.org/software/bash/
[dash]: http://gondor.apana.org.au/~herbert/dash/
[here-doc]: https://pubs.opengroup.org/onlinepubs/9699919799/
[here-string]: https://tldp.org/LDP/abs/html/x17837.html
[Linux]: https://www.linuxfoundation.org/
[process substitution]: https://tldp.org/LDP/abs/html/process-sub.html
[abs]: https://tldp.org/LDP/abs/html/
