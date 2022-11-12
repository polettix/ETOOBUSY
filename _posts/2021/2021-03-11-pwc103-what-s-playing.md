---
title: "PWC103 - What's playing?"
type: post
tags: [ perl weekly challenge ]
comment: true
date: 2021-03-11 07:00:00 +0100
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from the [Perl Weekly Challenge][] [#103][].
> Enjoy!

# The challenge

> Working from home, you decided that on occasion you wanted some background
> noise while working. You threw together a network streamer to continuously
> loop through the files and launched it in a tmux (or screen) session,
> giving it a directory tree of files to play. During the day, you connected
> an audio player to the stream, listening through the workday, closing it
> when done.
>
> For weeks you connect to the stream daily, slowly noticing a gradual drift
> of the media. After several weeks, you take vacation. When you return, you
> are pleasantly surprised to find the streamer still running. Before
> connecting, however, if you consider the puzzle of determining which track
> is playing.
> 
> After looking at a few modules to read info regarding the media, a quick
> bit of coding gave you a file list. The file list is in a simple CSV
> format, each line containing two fields: the first the number of
> milliseconds in length, the latter the media’s title (this example is of
> several episodes available from the MercuryTheatre.info):
> 
>     1709363,"Les Miserables Episode 1: The Bishop (broadcast date: 1937-07-23)"
>     1723781,"Les Miserables Episode 2: Javert (broadcast date: 1937-07-30)"
>     1723781,"Les Miserables Episode 3: The Trial (broadcast date: 1937-08-06)"
>     1678356,"Les Miserables Episode 4: Cosette (broadcast date: 1937-08-13)"
>     1646043,"Les Miserables Episode 5: The Grave (broadcast date: 1937-08-20)"
>     1714640,"Les Miserables Episode 6: The Barricade (broadcast date: 1937-08-27)"
>     1714640,"Les Miserables Episode 7: Conclusion (broadcast date: 1937-09-03)"
> 
> For this script, you can assume to be provided the following information:
> 
> - the value of `$^T` (`$BASETIME`) of the streamer script,
> - the value of `time()`, and
> - a CSV file containing the media to play consisting of the length in
>   milliseconds and an identifier for the media (title, filename, or
>   other).
> 
> Write a program to output which file is currently playing. For purposes of
> this script, you may assume gapless playback, and format the output as you
> see fit.
> 
> Optional: Also display the current position in the media as a time-like
> value.

# The questions

There are quite a few, some of them being:

- how much offset should we consider for the setup of the program? I mean,
  there has to be a gap between `$^T` and when the first track starts
  playing, right?
- is the input file encoded in any particular way? E.g. UTF-8?
- are we *sure* about the duration of the tracks? It seems suspicious that
  two consecutive pairs share the same exact length up to the millisecond...
- is it OK to print the title "as-is", i.e. without doing an actual read of
  the CSV data (which would get rid of the quotation marks)?
    - We will assume that the answer is yes, based on the example.

# The solution

Fact is I don't like my solution. It's long, possibly boring, and possibly
wrong (it gives out the correct title but with the wrong offset...). Anyway.

```perl
sub what_s_playing ($start, $now, $file) {
   my $tracks = load_tracks_list($file);
   my $offset = 1000 * ($now - $start);
   my $current_title;
   OUTER:
   while ('necessary') {
      my $period = 0;
      for my $track ($tracks->@*) {
         my $duration = $track->{duration};
         if ($offset <= $duration) {
            $current_title = $track->{title};
            last OUTER;
         }
         $offset -= $duration;
         $period += $duration;
      }
      $offset %= $period;
   }

   my $ms = $offset % 1000;
   $offset = int($offset / 1000);
   my $s = $offset % 60;
   $offset = int($offset / 60);
   my $m = $offset % 60;
   $offset = int($offset / 60);
   my $current_position =
      sprintf '%02d:%02d:%02d.%03d', $offset, $m, $s, $ms;

   return {position => $current_position, title => $current_title};
}
```

The `$offset` keeps track of the time passed since last "event". It is
initialized with the value for the event "start of everything" and time is
chopped as we consider tracks.

The `OUTER` loop is supposed to run either 1 or 2 times, depending on
whether we are at the very first pass in the list (i.e. we didn't play all
tracks at least once yet) or not (i.e. we are during a repetition). We scan
the tracklist in order, subtracting the track duration on the way. We also
calculate `$period` along the way, so we know how much a complete run of all
tracks takes and we can then shortcut the calculation with this trick:

```perl
$offset %= $period;
```

This also guarantees that the *next* run through the tracks will eventually
find what we are looking for.

The sub `load_tracks_list` does... what you think, returning an array of
hashes, each with keys `duration` and `title`.

As anticipated, running on the example inputs provides an *almost* correct
answer:

```
"Les Miserables Episode 1: The Bishop (broadcast date: 1937-07-23)"
00:10:24.160
```

I thought initially that the original author might have disregarded the
milliseconds in the calculation, which might account why I appear to be
behind that result, so I put a way to cut out milliseconds if environment
variable `CUT_MILLISECONDS` is set, to no avail.

Before you ask... yes, I also tried to do a round instead of simply cutting
milliseconds.

This is the whole program, should you be interested into debugging it!

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use autodie;
use File::Spec::Functions qw< splitpath catpath >;

sub what_s_playing ($start, $now, $file) {
   my $tracks = load_tracks_list($file);
   my $offset = 1000 * ($now - $start);
   my $current_title;
   OUTER:
   while ('necessary') {
      my $period = 0;
      for my $track ($tracks->@*) {
         my $duration = $track->{duration};
         if ($offset <= $duration) {
            $current_title = $track->{title};
            last OUTER;
         }
         $offset -= $duration;
         $period += $duration;
      }
      $offset %= $period;
   }

   my $ms = $offset % 1000;
   $offset = int($offset / 1000);
   my $s = $offset % 60;
   $offset = int($offset / 60);
   my $m = $offset % 60;
   $offset = int($offset / 60);
   my $current_position =
      sprintf '%02d:%02d:%02d.%03d', $offset, $m, $s, $ms;

   return {position => $current_position, title => $current_title};
}

sub load_tracks_list ($file) {
   open my $fh, '<', $file;
   my @lines = map {
      chomp;
      my ($duration, $title) = split m{,}mxs, $_, 2;
      $duration =~ s{\A\s+|\s+\z}{}gmxs;
      substr $duration, -3, 3, '000' if $ENV{CUT_MILLISECONDS};
      {duration => $duration, title => $title};
   } <$fh>;
   return \@lines;
}

sub default_args {
   my ($v, $ds, $f) = splitpath(__FILE__);
   my $file = catpath($v, $ds, 'filelist.csv');
   return (1606134123, 1614591276, $file);
}

my @args = @ARGV ? @ARGV : default_args();
my $wp = what_s_playing(@args);
say $wp->{title};
say $wp->{position};
```

Stay safe and... vary your playlist!

[Perl Weekly Challenge]: https://perlweeklychallenge.org/
[#103]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-103/
[TASK #2]: https://perlweeklychallenge.org/blog/perl-weekly-challenge-103/#TASK2
[Perl]: https://www.perl.org/
