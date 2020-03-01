#!/bin/sh

script=$1
prefix=$2
N="${3:-100}"

# some "freeze time" before and after the animation frames. This sets the
# default value, can be overridden from the outside by setting BUFFER
: ${BUFFER:=24}

# number of frames, add a BUFFER before and another after the animation
frames=$((BUFFER + N + BUFFER))

# 0-padding for the filenames
nchars="$(printf '%s' "$frames" | wc -c)"

# this format will be used with printf and then with ffmpeg
fmt="$prefix%0${nchars}d.png"

for i in $(seq 1 $frames) ; do
   filename="$(printf "$fmt" "$i")"

   # n varies between 0 and N, clamp to these values otherwise
   n=$((i - BUFFER))
   if   [ $n -lt 0 ]  ; then n=0
   elif [ $n -gt $N ] ; then n=$N
   fi

   # call the $script with the relevant parameters
   gnuplot \
      -e "filename='$filename'" \
      -e "n=$n" \
      -e "N=$N" \
      "$script"
done

# get all frames together!
ffmpeg -y -framerate 24 -i "$fmt" output.mp4
