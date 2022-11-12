---
title: Fatpacking fatpack
type: post
tags: [ fatpacker, perl ]
comment: true
date: 2021-04-06 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [fatpack][local] is a *fatpacked* version of [fatpack][].

Every now and then, [fatpack][] comes handy to cram all pure-[Perl][]
modules inside the same program that uses them.

This usually involves installing [App::FatPacker][] and using [fatpack][]
from that installation. Of course I was not the first to think that a
*fatpacked* version might be useful (e.g. see [Fatpacked fatpack script][]).

It turns out that the program is somehow *resistant* to the process - let's
take a look.

# An annoying `print`

The first annoying thing that yields an error during the packing process of
[fatpack][] is that, by default, it prints this string:

```
Try `perldoc fatpack` for how to use me
```

Fact is that this is printed on *standard output*, which is the same channel
where one of the packing steps send the list of modules to be included (more
or less). Long story short, [fatpack] tries to include a module whose
literal name is ``Try `perldoc fatpack` for how to use me`` - with an error.

My solution to this is to change channel for this message and print it on
*standard error*.

```diff
--- a/lib/App/FatPacker.pm
+++ b/lib/App/FatPacker.pm
@@ -64,7 +64,7 @@ sub run_script {
 }
 
 sub script_command_help {
-  print "Try `perldoc fatpack` for how to use me\n";
+  print {*STDERR} "Try `perldoc fatpack` for how to use me\n";
 }
 
 sub script_command_pack {
 ```

I wonder if this spoils the fun for anyone (i.e. if anyone relies on that
specific message to appear in *standard output* for any reason).

# Where is `App::FatPacker::Trace`?

Removing the `print` removes the complaints while packing [fatpack][], but
the resulting program is still not useable.

In this case, the problem is that the tracing step needs to call the target
program and inject module `App::FatPacker::Trace` to figure out all the
modules that should be included in the pack.

Fact is that, with the packed [fatpack][], the `App::FatPacker::Trace`
module is nowhere to be found during this call. This module is inside the
packed [fatpack][]! For this reason, we get something like this:

```
$ fatpackd pack example.pl > example-fp.pl
Can't locate App/FatPacker/Trace.pm in @INC (you may need to install the
App::FatPacker::Trace module) (@INC contains:...
```

My solution to this is to detect whether we're running a packed version of
[fatpack][], and save the module in a temporary directory that is then
included in `PERL5LIB`:

```diff
--- a/lib/App/FatPacker.pm
+++ b/lib/App/FatPacker.pm
@@ -111,9 +111,41 @@ sub script_command_trace {
   );
 }
 
+
+sub _fatpacked_save_Trace_for_INC {
+  my ($self, $instance) = @_;
+  require File::Temp;
+  my $dir = File::Temp::tempdir(CLEANUP => 1);
+
+  require File::Spec;
+  my ($v, $ds) = File::Spec->splitpath($dir, 'no-file-please');
+  my @ds = File::Spec->splitdir($ds);
+
+  require File::Path;
+  $ds = File::Spec->catdir(@ds, 'App');
+  File::Path::make_path(File::Spec->catpath($v, $ds, 'FatPacker'));
+
+  $ds = File::Spec->catdir(@ds, 'App', 'FatPacker');
+  my $trace_file = File::Spec->catpath($v, $ds, 'Trace.pm');
+
+  open my $fh, '>:raw', $trace_file or die "open('$trace_file'): $!\n";
+  print {$fh} $instance->{'App/FatPacker/Trace.pm'};
+  close $fh;
+
+  return $dir;
+}
+
 sub trace {
   my ($self, %opts) = @_;
 
+  # save App::FatPacker::Trace to the filesystem and adjust PERL5LIB
+  # if using a fatpacked fatpacker.
+  local $ENV{PERL5LIB} = $ENV{PERL5LIB} || '';
+  if (my ($instance) = grep {ref($_) =~ m{^FatPacked}mxs} @INC) {
+    my $lib_dir = $self->_fatpacked_save_Trace_for_INC($instance);
+    $ENV{PERL5LIB} = join ':', $lib_dir, ($ENV{PERL5LIB} || ());
+  }
+
   my $output = $opts{output};
   my $trace_opts = join ',', $output||'>&STDOUT', @{$opts{use}||[]};
```

The `_fatpacked_save_Trace_for_INC` function does the heavylifting (create
the right temporary directory, save `Trace.pm`) and the main `trace`
function is modified to cope with the needed changes to `PERL5LIB` if they
are needed.

# Seems to work!

A little test with a sample program showed me that its output is the same as
the one coming from the *normal* installation - yay!

Here is the *fatpacked* program: [fatpack][local]. **The [COPYRIGHT][] and
[LICENSE][] remain the same as [App::FatPacker][]!**

Next step will be to get in touch with the people that take care of it...
and hope they will find the idea useful 🤗

[fatpack]: https://metacpan.org/pod/distribution/App-FatPacker/bin/fatpack
[Perl]: https://www.perl.org/
[Fatpacked fatpack script]: https://rt.cpan.org/Public/Bug/Display.html?id=130034
[App::FatPacker]: https://metacpan.org/pod/App::FatPacker
[local]: {{ '/assets/code/fatpack' | prepend: site.baseurl }}
[COPYRIGHT]: https://metacpan.org/pod/App::FatPacker#COPYRIGHT
[LICENSE]: https://metacpan.org/pod/App::FatPacker#LICENSE
