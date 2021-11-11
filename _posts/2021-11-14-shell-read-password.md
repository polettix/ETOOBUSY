---
title: Read a password from the shell
type: post
tags: [ shell, security ]
comment: true
date: 2021-11-14 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Reading a password is easy from the shell, although I'm not sure how
> secure it is.

The basic solution with [bash][] would be to use the `-s` option, e.g.:

```shell
read -s password
```

The option turns down echoing on the terminal. I'm still not entirely
sure about the security of having it in memory though.

Alas, option `-s` is missing In [POSIX-compliant shells][]. There's a
solution, though, explained in [this answer][]:

```shell
read_password() {
  REPLY="$(
    # always read from the tty even when redirected:
    exec < /dev/tty || exit # || exit only needed for bash

    # save current tty settings:
    tty_settings=$(stty -g) || exit

    # schedule restore of the settings on exit of that subshell
    # or on receiving SIGINT or SIGTERM:
    trap 'stty "$tty_settings"' EXIT INT TERM

    # disable terminal local echo
    stty -echo || exit

    # prompt on tty
    printf "Password: " > /dev/tty

    # read password as one line, record exit status
    IFS= read -r password; ret=$?

    # display a newline to visually acknowledge the entered password
    echo > /dev/tty

    # return the password for $REPLY
    printf '%s\n' "$password"
    exit "$ret"
  )"
}
```

Thanks, [Stéphane Chazelas][]!

[bash]: https://www.gnu.org/software/bash/
[this answer]: https://unix.stackexchange.com/questions/222974/ask-for-a-password-in-posix-compliant-shell
[Stéphane Chazelas]: https://unix.stackexchange.com/users/22565/st%c3%a9phane-chazelas
[POSIX-compliant shells]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/read.html
