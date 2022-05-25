---
title: PWC166 - K-Directory Diff
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-05-25 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#166][].
> Enjoy!

# The challenge

> Given a few (**three** or more) directories (non-recursively), display
> a **side-by-side difference** of **files that are missing** from at
> least one of the directories. Do not display files that exist in every
> directory.
>
> Since the task is non-recursive, if you encounter a subdirectory,
> append a `/`, but otherwise treat it the same as a regular file.
>
> **Example**
>
> Given the following directory structure:
>
>     dir_a:
>     Arial.ttf  Comic_Sans.ttf  Georgia.ttf  Helvetica.ttf  Impact.otf  Verdana.ttf  Old_Fonts/
>     
>     dir_b:
>     Arial.ttf  Comic_Sans.ttf  Courier_New.ttf  Helvetica.ttf  Impact.otf  Tahoma.ttf  Verdana.ttf
>     
>     dir_c:
>     Arial.ttf  Courier_New.ttf  Helvetica.ttf  Impact.otf  Monaco.ttf  Verdana.ttf
>
> The output should look similar to the following:
>
>     dir_a          | dir_b           | dir_c
>     -------------- | --------------- | ---------------
>     Comic_Sans.ttf | Comic_Sans.ttf  |
>                    | Courier_New.ttf | Courier_New.ttf
>     Georgia.ttf    |                 |
>                    |                 | Monaco.ttf
>     Old_Fonts/     |                 |
>                    | Tahoma.ttf      |

# The questions

Did Respectable Ryan J. Thompson miss that memo where I declared my
complete laziness?

# The solution

I'll skip checks etc. because this challenge has **a lot** of stuff
going on. So much that I'll split the post in two, focusing on the
[Perl][] solution first.

> Yes, I was late!

This challenge needs a plan:

- Collect the lists of items inside the provided directories (no error
  handling done!).
- Compare the lists to find all items that *do not* appear in all lists,
  filling the gaps where it's needed.
- Render the whole thing *similar to the following*.


Getting the contents of a directory is *extremely* easy using
[Path::Tiny][], which we're not doing anyway here. Call me a CORE
masochist 😅:

```perl
sub list_from ($dir) {
   opendir my $dh, $dir or die "opendir('$dir'): $!\n";
   my ($v, $dirs) = splitpath($dir, 'no-file');
   return map {
      my $path = catpath($v, $dirs, $_);
      -d $path ? "$_/" : $_;
   } readdir($dh);
}
```

I admit to have felt some nostalgy looking at this code leveraging such
venerable functions!

OK, now the CORE of the algorithm for comparisons. We'll use the
following bits (not very efficient but whatever, it's still linear with
the total number of elements in all lists):

- the *set union* of all lists;
- the *set intersection* of all lists;
- a *set* for each list.

We're [Perl][]ing here, so *set* means *hash*.

```perl
sub select_incompletes (@lists) {
   my (@retval, %union, %intersection);
   @intersection{$lists[0]->@*} = ();
   for my $list (@lists) {
      @union{$list->@*} = ();
      %intersection = map { $_ => 1 }
         grep { exists $intersection{$_} } $list->@*;
      $list = { map { $_ => $_ } $list->@* };
      push @retval, [];
   }
```

The astute read spot that we're also pre-warming our retval with an
empty list for each input list. Good, good sight.

Now what?

We iterate over all items in the *union*, skipping all items that also
appear in the *intersection*. In this way, we're sure to consider any
file appeared in any directory, while at the same time sticking to the
rules that stuff appearing everywhere should be tossed away:

```perl
   for my $item (sort { $a cmp $b } keys %union) {
      next if exists $intersection{$item};
```

Now we iterate over all lists, taking "something" from it:

- if it contained the specific file/item, we take it;
- otherwise, we take an empty string.

```perl
      for my $i (0 .. $#lists) {
         push $retval[$i]->@*, $lists[$i]{$item} // '';
      }
   }
   return @retval;
}
```

After doing this for all items in the union, our `@retval` will contain
the *K-Directory Diff* that we're after.

Well, the data at least. Now the dam**COUGH**funny part comes, with the
rendering according to the example. We want to auto-size the columns
based on the width of the maximum file name, so there's a first pass to
find the width of each column:

```perl
sub render_columns (@columns) {
   my @widths = map {
      my $width = 0;
      for my $item ($_->@*) {
         my $w = length $item;
         $width = $w if $width < $w;
      }
      $width;
   } @columns;
```

Widths are used in two places. First, we compute a `sprintf`-compatible
format string joining together chunks shaped as `%-NNs`, where `NN` is
the width:

```perl
   my $format = join ' | ', map {; "%-${_}s" } @widths;
```

Next, we can compute the *separator* line that divides the header line
from the following one:

```perl
   my $separator = sprintf $format, map { '-' x $_ } @widths;
```

Did I mention that the first item in each column is assumed to be the
title of the column? No? Well, now I did. We can use our `$format` to
turn each *row* (slice across all columns) into a line:

```perl
   my ($head, @retval) = map {
      my $i = $_;
      sprintf $format, map { $_->[$i] } @columns
   } 0 .. $columns[0]->$#*;
```

The first line is directly put into its own named scalar variable
`$head`, while the table data go into `@retval`. This makes it easy for
us to assemble the whole table at the end:

```perl
   return join "\n", $head, $separator, @retval;
}
```


For anybody interested, here's the whole thing.

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';
no warnings 'experimental::signatures';
use File::Spec::Functions qw< splitpath catpath >;

k_directory_diff(qw< dir_a dir_b dir_c >);

sub k_directory_diff (@dirs) {
   my @lists = select_incompletes(map { [list_from($_)] } @dirs);
   unshift $lists[$_]->@*, $dirs[$_] for 0 .. $#dirs;
   say render_columns(@lists);
}

sub list_from ($dir) {
   opendir my $dh, $dir or die "opendir('$dir'): $!\n";
   my ($v, $dirs) = splitpath($dir, 'no-file');
   return map {
      my $path = catpath($v, $dirs, $_);
      -d $path ? "$_/" : $_;
   } readdir($dh);
}

sub select_incompletes (@lists) {
   my (@retval, %union, %intersection);
   @intersection{$lists[0]->@*} = ();
   for my $list (@lists) {
      @union{$list->@*} = ();
      %intersection = map { $_ => 1 }
         grep { exists $intersection{$_} } $list->@*;
      $list = { map { $_ => $_ } $list->@* };
      push @retval, [];
   }
   for my $item (sort { $a cmp $b } keys %union) {
      next if exists $intersection{$item};
      for my $i (0 .. $#lists) {
         push $retval[$i]->@*, $lists[$i]{$item} // '';
      }
   }
   return @retval;
}

sub render_columns (@columns) {
   my @widths = map {
      my $width = 0;
      for my $item ($_->@*) {
         my $w = length $item;
         $width = $w if $width < $w;
      }
      $width;
   } @columns;
   my $format = join ' | ', map {; "%-${_}s" } @widths;
   my $separator = sprintf $format, map { '-' x $_ } @widths;
   my ($head, @retval) = map {
      my $i = $_;
      sprintf $format, map { $_->[$i] } @columns
   } 0 .. $columns[0]->$#*;
   return join "\n", $head, $separator, @retval;
}
```

[The Weekly Challenge]: https://theweeklychallenge.org/
[#166]: https://theweeklychallenge.org/blog/perl-weekly-challenge-166/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-166/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Path::Tiny]: https://metacpan.org/pod/Path::Tiny
