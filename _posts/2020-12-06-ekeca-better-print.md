---
title: ekeca - better print
type: post
tags: [ security, openssl, shell ]
comment: true
date: 2020-12-06 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Added an enhanded `print` to [ekeca][ekeca-post].

From time to time I have to deal with TLS certificates and this *usually*
gets me to the point where I think *oh, it would be great to do... X*.

Then I have that *harry-potter-ish* moment when the (disguised) professor
Moody reminds Harry that *he has a wand*. Well, I guess I have the shell
wand in this case! Which invariably brings me to this:

![xckd.com/1319]({{ '/assets/images/xkcd-1319.png' | prepend: site.baseurl }})

(from [Automation][xkcd.com/1319]) without thinking about this:

![xkcd.com/1205]({{ '/assets/images/xkcd-1205.png' | prepend: site.baseurl }})

(from [Is It Worth The Time?][xkcd.com/1205]).

This specific time I have a file with two certificates inside, and I want to
print them both. So... I extended the `print` sub-command in ekeca to just
do this:

```shell
cmd_print() {
   local l chunk inside='no' n=0
   while read l ; do
      if [ "$inside" = 'yes' ] ; then
         chunk="$(printf '%s\n%s' "$chunk" "$l")"
         local type="$(printf %s "$l" | _type_of)"
         [ -n "$type" ] || continue
         local cmd
         case "$type" in
            (CERTIFICATE)
               cmd=x509
               ;;
            (CERTIFICATE\ REQUEST)
               cmd=req
               ;;
            (PRIVATE\ KEY)
               cmd=rsa
               ;;
            (*)
               printf >&2 '%s\n' "unhandled type '$type'"
               return 1
               ;;
         esac
         n=$(( n + 1 ))
         [ $n -lt 2 ] || printf '\n'
         printf '# item #%d %s\n' "$n" "$type"
         printf %s "$chunk" | openssl "$cmd" -noout -text
         inside='no'
      elif printf %s "$l" | grep '^-\+BEGIN .*-\+ *$' >/dev/null 2>&1; then
         chunk="$l"
         inside='yes'
      fi
   done <"$1"
}
```

The outer loop takes care to divide the input file's contents in *chunks*,
each containing one *thing* (like a certificate, a certificate signing
request, or a key). When we hit the `END` line of the chunk, we just use the
older code to figure out what the *chunk* represents and call the right
[OpenSSL][] sub-command.

That's it for today!

[ekeca-post]: {{ '/2020/02/08/ekeca' | prepend: site.baseurl }}
[ekeca]: https://github.com/polettix/ekeca
[OpenSSL]: https://www.openssl.org/
[ekeca-line-18]: https://github.com/polettix/ekeca/blob/master/ekeca#L18
[xkcd.com/1319]: https://xkcd.com/1319/
[xkcd.com/1205]: https://xkcd.com/1205/
