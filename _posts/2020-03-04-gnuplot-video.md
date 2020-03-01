---
title: Gnuplot Video
type: post
tags: [ gnuplot, graphics, coding ]
comment: true
date: 2020-03-04 08:00:00 +0100
published: false
---

**TL;DR**

> Let's generate a video with frames coming from [Gnuplot][]!

In previous post [Gnuplot Parametric Mix][] we discussed a way to
generate a mix between two functions, by providing a *ratio* for mixing
them. Here, we leverage that to generate many frames.

```
 1 #!/bin/sh
 2 
 3 script=$1
 4 prefix=$2
 5 N="${3:-100}"
 6 
 7 # some "freeze time" before and after the animation frames. This sets the
 8 # default value, can be overridden from the outside by setting BUFFER
 9 : ${BUFFER:=24}
10 
11 # number of frames, add a BUFFER before and another after the animation
12 frames=$((BUFFER + N + BUFFER))
13 
14 # 0-padding for the filenames
15 nchars="$(printf '%s' "$frames" | wc -c)"
16 
17 # this format will be used with printf and then with ffmpeg
18 fmt="$prefix%0${nchars}d.png"
19 
20 for i in $(seq 1 $frames) ; do
21    filename="$(printf "$fmt" "$i")"
22 
23    # n varies between 0 and N, clamp to these values otherwise
24    n=$((i - BUFFER))
25    if   [ $n -lt 0 ]  ; then n=0
26    elif [ $n -gt $N ] ; then n=$N
27    fi
28 
29    # call the $script with the relevant parameters
30    gnuplot \
31       -e "filename='$filename'" \
32       -e "n=$n" \
33       -e "N=$N" \
34       "$script"
35 done
36 
37 # get all frames together!
38 ffmpeg -y -framerate 24 -i "$fmt" output.mp4
```

Lines 3 through 5 deal with inputs from the command line: the script to
execute repeatedly (e.g. what discussed in [Gnuplot Parametric Mix][]),
a prefix for all PNG images, and the number of "central" frames (which
will determine the length of the animation).

Line 9 sets a default value for environment variable `BUFFER`: this is
an integer value that aims at introducing a frozen pre-animation and a
frozen post-animiation to the video, so that the starting and ending
points are more easily visible. You can set this variable externally to
a different value. The default corresponds to 24 frames, i.e. 1 second
when generating a video with 24 frames per second.

The actual number of frames is calculated in line 12: it's the number of
"animated" frames (`N`) plus two buffers, one for each side of the
video as discussed above.

Lines 15 and 18 aim at generating a *format string* that is good for
both `printf` and `ffmpeg`. In particular, `nchars` calculates the
length for the sequence number of different frames, so that they always
have the same length (easing `ffmpeg`'s life).

The main loop in lines 20 through 35 takes care to generate all frames.
In particular, `i` keeps track of the frame number.

The filename is generated based on `i`, leveraging the generated format
`fmt` on line 21. As an example, if `prefix` is the string `example-`,
it will be something like `example-001.png`.

In the loop, the variable `n` represents the *numerator*, with the logic
to have a frozen buffer at both ends. This means that values of `n`
outside the range from `0` to `N` are clamped to these extremes. This
happens in lines 24 to 27.

Line 30 (continued on the following ones via `\\`) invokes [Gnuplot][]
setting the right parameters, which generates a different file for each
iteration.

After all frames are available as PNG images, they are condensed
together in a video using [ffmpeg][] (line 38). The framerate is set to
a fixed value of 24, but of course it can be changed.

Curious of what comes out of this? Take a look at the video below (or
[download it][local video]):

<video controls>
  <source src="{{ '/assets/other/20200304-gnuplot-video.mp4' | prepend: site.baseurl | prepend: site.url }}" type="video/mp4">
Your browser does not support the video tag.
</video> 

[Local version]: {{ '/assets/code/20200304-sequencer.sh' | prepend: site.baseurl | prepend: site.url }}
[local video]: {{ '/assets/other/20200304-gnuplot-video.mp4' | prepend: site.baseurl | prepend: site.url }}
[Gnuplot]: http://gnuplot.info/
[Gnuplot Parametric Mix]: {{ '/2020/03/03/gnuplot-parametric-mix' | prepend: site.baseurl | prepend: site.url }}
[ffmpeg]: https://ffmpeg.org/
