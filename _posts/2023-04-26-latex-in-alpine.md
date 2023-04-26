---
title: LaTeX in Alpine Linux
type: post
tags: [ latex, alpine, linux ]
comment: true
date: 2023-04-26 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> My first moves with [LaTeX][] in Linux.

A few notes, future me!

With Alpine Linux in Docker:

```
docker run --rm -itv "$PWD:/mnt" alpine:3.16
```

Let's get started: I need to use a specific TrueType font, so it seems that
`xelatex` is needed. I hope to find out what this is at some time!

```
apk update
apk add texlive-xetex
```

Installing the font(s) means copying the files in a specific directory and
indexing them. We'll do a test using [LeagueSpartan][], an open font:

```
mkdir -p /usr/local/share/fonts
wget https://github.com/theleagueof/league-spartan/releases/download/2.220/LeagueSpartan-2.220.zip
unzip LeagueSpartan-2.220.zip
cp LeagueSpartan-2.220/static/TTF/* /usr/local/share/fonts/
fc-cache -fv
```

I'll also need to place some pieces of text in specific positions using
package [textpos][]:

```
cd /mnt
wget https://mirrors.ctan.org/macros/latex/contrib/textpos.zip
unzip textpos.zip
cd textpos
tex textpos.ins
cp textpos.sty ..
cd ..
```

At this point we can run an example, [adapted from here][example]:

```
\documentclass{article}
    % General document formatting
    \usepackage[margin=0.7in]{geometry}
    \usepackage[parfill]{parskip}
    \usepackage[utf8]{inputenc}

    % Related to math
    \usepackage{amsmath,amssymb,amsfonts,amsthm}

    \usepackage{fontspec}
    \setmainfont{LeagueSpartan-Regular}

    \usepackage[absolute,overlay]{textpos}

\begin{document}

Name, date, Exercise X

\section*{Part a}

Put your answer to part a here

\section*{Part b}

etc

\begin{textblock*}{10cm}(15cm,16cm) % {block width} (coords) 
   Your text here
\end{textblock*}

\end{document}
```

Now:

```
xelatex example.tex
```

and enjoy the generated PDF file.

Hope this helps!

[LaTeX]: https://www.latex-project.org/
[textpos]: https://ctan.org/pkg/textpos
[example]: https://gist.github.com/Michael0x2a/e46e12a66b7dc604db5e
[LeagueSpartan]: https://www.theleagueofmoveabletype.com/league-spartan
