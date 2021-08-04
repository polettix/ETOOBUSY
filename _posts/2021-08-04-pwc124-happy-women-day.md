---
title: PWC124 - Happy Women Day
type: post
tags: [ the weekly challenge ]
comment: true
date: 2021-08-04 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> Here we are with [TASK #1][] from [The Weekly Challenge][]
> [#124][]. Enjoy!

# The challenge

> Write a script to print the Venus Symbol, international gender symbol
> for women. Please feel free to use any character.
>
>        ^^^^^
>       ^     ^
>      ^       ^
>     ^         ^
>     ^         ^
>     ^         ^
>     ^         ^
>     ^         ^
>      ^       ^
>       ^     ^
>        ^^^^^
>          ^
>          ^
>          ^
>        ^^^^^
>          ^
>          ^

# The questions

This is the most open challenge I saw so far here, so I guess that
asking questions is neglecting the underlying challenge to be
*creative*.

As a meta-question, I thought that Women's Day was on March 8th, did I
miss anything?

# The solution

I'll only comment on the [Perl][] solution here, because... I'm a little
late with my post 🙄

Long story short, here's the code:

```perl
eval eval '"'.


             ('`'|'/').('['^
          '+').('`'|'%').('`'|
        '.').'\\'.'$'.('`'|'&').
       ','."'".'<'."'"."\,".'\\'.
     '$'.('^'^('`'|'.'))."\;".'\\'.
    '$'.('['^'#').'='.'<'.'\\'.'$'.(
   '`'|'&').'>'.('`'|'&').('`'|'/').(
  '['^')').('{'^        '[').('^'^('`'
  |'/')).','.              ('^'^(('`')|
 ',')).';'.(                '['^"\+").(
'['^"\)").(                  '`'|"\)").(
'`'|'.').(                    '['^'/').(
'{'^'[').(                    '['^"\(").
'\\'."\{".                    '\\'.'\\'.
('{'^'(').                    '\\'."\}".
'\\'."\{".                    "\#".'\\'.
'}'.("\`"|                    "'").('['^
')').("\{"^                   '[').('['^
',').("\`"|                  '(').('`'|
 ')').(('`')|               ',').("\`"|
  '%').'<'.''.             '\\'."\$".(
   '`'|'&').('>').     ';'.('['^'+').(
   '['^')').('`'|')').('`'|'.').('['^
    '/').'\\'.'"'.'\\'.'\\'.('`'|'.'
      ).'\\'.'"'.('!'^'+').'"';$:=
       '.'^'~';$~='@'|'(';$^=')'^
         '[';$/='`'|'.';$,='('^
            '}';$\='`'|"\!";
               $:=')'^'}'
               ;$~=('*')|
               '`';$^='+'
               ^('_');$/=
               '&'|'@';$,
               ='['&"\~";
               $\=','^'|'
               ;$:=('.')^
     '~';$~='@'|'(';$^=')'^"\[";$/=
     '`'|'.';$,='('^'}';$\='`'|'!';
     $:=')'^'}';$~='*'|'`';$^="\+"^
     '_';$/='&'|'@';$,='['&"\~";$\=
     ','^'|';$:='.'^'~';$~='@'|'(';
     $^=')'^'[';$/='`'|'.';$,="\("^
               '}';$\='`'
               |('!');$:=
               ')'^'}';$~
               ='*'|"\`";
               $^='+'^'_'
               ;$/=('&');
```

This comes from using [Inkscape][] to generate the symbol, [Gimp][] to
resize it and give some touches, [imagetoascii][] to convert the image
into a shape, and [Acme::EyeDrops][] to generate the final mess above.

The input program is this:

```perl
open$f,'<',$0;$x=<$f>for 1,2;print s{\S}{#}gr while<$f>;print"\n"
```

that does this:

```perl
# Open "this" program as a file
open $f, '<', $0;

# Remove the first two lines, i.e. the one with eval...
$x = <$f> for 1, 2;

# Read the rest, transforming lines on the fly to turn non-spacing
# characters into `#`
print s{\S}{#}gr while<$f>;

# Pring a final newline, for better clarity
print"\n"
```

Well... just not to leave the [Raku][] side out, let's cheat a bit:

```raku
#!/usr/bin/env raku
use v6;
put "♀"
```

And *this* is all, folks!

[The Weekly Challenge]: https://theweeklychallenge.org/
[#124]: https://theweeklychallenge.org/blog/perl-weekly-challenge-124/
[TASK #1]: https://theweeklychallenge.org/blog/perl-weekly-challenge-124/#TASK1
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Acme::EyeDrops]: https://metacpan.org/pod/Acme::EyeDrops
[Inkscape]: https://inkscape.org/
[Gimp]: https://www.gimp.org/
[imagetoascii]: https://cloudapps.herokuapp.com/imagetoascii/
