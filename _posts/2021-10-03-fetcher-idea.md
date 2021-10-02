---
title: A file fetcher idea
type: post
tags: [ perl, coding ]
comment: true
date: 2021-10-03 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> An idea to generalize access to data that is either on file or in a
> compressed archive.

A friend and I are addressing a small programming task and it's still
not entirely clear where some data will come from. I mean, they might be
in a plain file in the filesystem, or in a ZIP file.

The simplest thing would be to extract the ZIP file in the filesystem
and go back to square one, this time with a plain file in the
filesystem. But I was not like doing this, because I wanted the
compressed stuff to stay compresses for as much as we can.

So I came out with this:

```perl
sub file_fetcher (%config) {
   return sub ($type, $filename = undef) {
      return $config{$type} if defined $config{$type};
      state $zh = do {
         die "no zip file\n" unless -r $config{zip};
         my $tmp = Archive::Zip->new;
         die "cannot read zip file '$config{zip}'\n"
            if $tmp->read("$config{zip}") != AZ_OK;
         $tmp;
      };
      my $rx = !defined $filename ? qr{(?imxs: . \Q$type\E \z)}
         : !ref $filename ? qr{(?mxs: \A \Q$filename\E \z)}
         :                  $filename;
      for my $member ($zh->members) {
         my $member_name = $member->{fileName} =~ s{\A.*[\\/]}{}rmxs;
         next unless $member_name =~ m{$rx};
         my $stuff = $member->contents;
         return \$stuff;
      }
      die "cannot retrieve requested file\n";
   };
}
```

The `file_fetcher` is a factory function that returns a sub reference
that can be later used to retrieve the file's contents. It takes a
`%config` hash where there should be pairs with keys associated to the
specific type of file we want to read, and the value is the path to that
file in the filesystem. One of them is `zip`, pointing to the ZIP
archive with the other files.

The returned sub takes a file `$type` and an optional `$filename` to do
its magic.

If there is indeed that `$type` in the general `%config` hash, then it
is used. This allows using files that are inside the filesystem, passed
directly in the hash.

Otherwise, the ZIP file is searched. Here I'm probably being a bit
*crude* - all file names of members of the ZIP file are stripped of
everything and we're keeping the base name only (in Unix, most
probably).

The specification of what to find depends on the optional `$filename`
parameter and, again, `$type`. The gist of it is that presence of a
`$filename` triggers its use, otherwise the `$type` is used as a
fallback to find the file by extension.

To use it we can do:

```perl
my %config = (
    zip => '/path/to/zip',  # contains bar.txt
    foo => '/some/galook.foo'.
);
my $fetcher = file_fetcher(%config);
my $foo = $fetcher->('foo');            # from filesystem
my $bar = $fetcher->(bar => 'bar.txt'); # from the ZIP archive
```

What do we get back? Something that *can be `open`ed`, i.e. either a
file name or a reference to a scalar. Which, by the way, can also be
used straight away.

I'm still not sure it's the right way to do it... but at least we are
covered independently of whether the specific files appears in the
filesystem or in an archive.

Thoughts? In the meantime... stay safe!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
