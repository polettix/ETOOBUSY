---
title: PAUSE workaround
type: post
tags: [ perl, cpan ]
comment: true
date: 2021-06-14 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I tricked [PAUSE][], without intention.

As you might have read in [EPAN - Exclusive Perl Archive Nook][],
I recently released a module in [CPAN][], which means that I submitted it
through [PAUSE][].

Alas, the first attempt to submit the module was a failure:

```
Status: Permission missing
==========================

     module : CPAN::Modulelist
     version: 0.001
     in file: lib/App/EPAN.pm
     status : Not indexed because permission missing. Current registered
             primary maintainer is BDFOY. Hint: you can always find the
             legitimate maintainer(s) on PAUSE under "View Permissions".
```

It took me a bit to figure what was **clearly** written, i.e. that it was
complaining about `CPAN::Modulelist`, but it eventually got my attention.

Wait... what?!?

It turns out that I indeed have (well... had) [a line declaring `package
CPAN::Modulelist`][line]:

```
...

package CPAN::Modulelist;
# Usage: print Data::Dumper->new([CPAN::Modulelist->data])->Dump or similar
...
```

except that... it was inside a *HEREDOC*:

```
   $self->_save(
      '03modlist.data',                                          # name
      <<'END_OF_03_MODLIST_DATA',
File:        03modlist.data
Description: These are the data that are published in the module
        list, but they may be more recent than the latest posted
        modulelist. Over time we'll make sure that these data
        can be used to print the whole part two of the
        modulelist. Currently this is not the case.
Modcount:    0
Written-By:  PAUSE version 1.005
Date:        Sun, 28 Jul 2013 07:41:15 GMT

package CPAN::Modulelist;
# Usage: print Data::Dumper->new([CPAN::Modulelist->data])->Dump or similar
# cannot 'use strict', because we normally run under Safe
# use strict;
sub data {
   my $result = {};
   my $primary = "modid";
   for (@$CPAN::Modulelist::data){
      my %hash;
      @hash{@$CPAN::Modulelist::cols} = @$_;
      $result->{$hash{$primary}} = \%hash;
   }
   return $result;
}
$CPAN::Modulelist::cols = [ ];
$CPAN::Modulelist::data = [ ];
END_OF_03_MODLIST_DATA
      'modlist',    # configuration key to look output file
      $basedir->file(qw< modules 03modlist.data.gz >)    # default
   );
```

So, it seems that [PAUSE][] does some higher level analysis of the code,
looking for `package Foo::Bar` declarations and raising flags as needed.

My solution has been to break that *string* into two parts, neither of
which has `package CPAN::Modulelist` anywhere to be found by [PAUSE][]:

```
   my $_03modlist_data_1 = <<'END_OF_03_MODLIST_DATA_1';
...
Date:        Sun, 28 Jul 2013 07:41:15 GMT

pac
END_OF_03_MODLIST_DATA_1
   my $_03modlist_data_2 = <<'END_OF_03_MODLIST_DATA_2';
kage CPAN::Modulelist;
# Usage: print Data::Dumper->new([CPAN::Modulelist->data])->Dump or similar
...
END_OF_03_MODLIST_DATA_2
```

just to remove added whitespaces and merge them together when needed:

```perl
   $_03modlist_data_1 =~ s{\s+\z}{}mxs;
   $_03modlist_data_2 =~ s{\A\s+}{}mxs;
   $self->_save(
      '03modlist.data',                                          # name
      "$_03modlist_data_1$_03modlist_data_2",
      'modlist',    # configuration key to look output file
      $basedir->file(qw< modules 03modlist.data.gz >)    # default
   );
```

This was interesting!


[EPAN - Exclusive Perl Archive Nook]: {{ '/2021/06/13/epan' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[PAUSE]: https://pause.perl.org/
[CPAN]: https://metacpan.org/
[line]: https://github.com/polettix/epan/blob/97fb9fb46cd364bc6d0ac5a0f6f59ed95462d5b5/lib/App/EPAN.pm#L172
