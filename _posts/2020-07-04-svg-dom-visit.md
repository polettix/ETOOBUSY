---
title: SVG DOM tree visit
type: post
tags: [ algorithm, tree, visit, svg ]
comment: true
date: 2020-07-04 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A simple function to visit a tree via DOM in [SVG][].

For a little side project I'm looking into [SVG][]. It provides an
interface ([SVG::DOM][]) to visit the whole tree built from reading the
input XML file, which is OK.

Initially, I only needed a list of the (two) paths that I expect to find
in the specific SVG files I'm interested into (in particular, those in
[game-icons][]). Something like this:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
   <path d="M0 0h512v512H0z"/>
   <path fill="#fff" d="M100 100h312v312H100z"/>
</svg>
```

It's really as simple as it seems: a black background square, with a
smaller white square on top.

I thought of using method `getElements`, like this:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use SVG::Parser;
use Path::Tiny;

my $parser = SVG::Parser->new(-nocredits => 1);
for my $filename (@ARGV) {
   my $file   = path($filename);
   say $file->basename;

   my $image  = $parser->parse($file->slurp_raw);
   my @paths = $image->getElements('path');
   say "$_ -> $paths[$_]->{d}" for 0 .. $#paths;
} ## end for my $filename (@ARGV)
```

Alas, this is not *exactly* what I was after:

```shell
$ perl svg-struct-no test.svg 
test.svg
0 -> M100 100h312v312H100z
1 -> M0 0h512v512H0z
```

It seems that it's reversing the two `path`s, although I can't find any
mention of this in the docs. Which, by the way, led me to [open an
issue][], but in the meantime I know I cannot rely on `getElements` if I
want the `path`s in order.

So... let's code a visit on the parsed tree:

```perl
 1 #!/usr/bin/env perl
 2 use 5.024;
 3 use warnings;
 4 use experimental qw< postderef signatures >;
 5 no warnings qw< experimental::postderef experimental::signatures >;
 6 
 7 use SVG::Parser;
 8 use Path::Tiny;
 9 
10 my $parser = SVG::Parser->new(-nocredits => 1);
11 for my $filename (@ARGV) {
12    my $file   = path($filename);
13    say $file->basename;
14 
15    my $image  = $parser->parse($file->slurp_raw);
16    my @paths = get_paths_in_order($image);
17    say "$_ -> $paths[$_]->{d}" for 0 .. $#paths;
18 } ## end for my $filename (@ARGV)
19 
20 sub get_paths_in_order ($image) {
21    my @paths;
22    visit($image,
23       sub ($el) { push @paths, $el if lc($el->getElementName) eq 'path' });
24    return @paths;
25 } ## end sub get_paths_in_order ($image)
26 
27 sub visit ($el, $pre_cb = undef, $post_cb = undef) {
28    $pre_cb->($el) if $pre_cb;
29    my $child = $el->getFirstChild();
30    while ($child) {
31       visit($child, $pre_cb, $post_cb);
32       $child = $child->getNextSibling();
33    }
34    $post_cb->($el) if $post_cb;
35    return;
36 } ## end sub visit
```

Lines up to 18 are the same as before, with the exception of line 16
where we're calling `get_paths_in_order()` instead of `getElements()`.

The real *workhorse* is `visit()` (lines 27 to 36), which acts
recursively as long as an element has children. It's coded generically,
i.e. it allows to perform operations both *before* (line 28) recursing
into the children of a node, both *after* (line 34).

In our case we only need to use the operation *before*, so in the
external call (lines 22 and 23) we just provide the first callback, to
accumulate the `path` nodes.

[Perl]: https://www.perl.org/
[SVG]: https://metacpan.org/pod/SVG
[SVG::Parser]: https://metacpan.org/pod/SVG::Parser
[SVG::DOM]: https://metacpan.org/pod/SVG::DOM
[CPAN]: https://metacpan.org/
[GitHub]: https://www.github.com/
[Indirect Object Syntax]: https://perldoc.perl.org/perlobj.html#Indirect-Object-Syntax
[perl5320-delta]: https://perldoc.perl.org/5.32.0/perl5320delta.html
[feature]: https://metacpan.org/pod/feature
[indirect]: https://metacpan.org/pod/feature#The-'indirect'-feature
[MANWAR]: http://www.manwar.org/
[pull request]: https://github.com/manwar/SVG/pull/12
[game-icons]: https://game-icons.net/
[open an issue]: https://github.com/manwar/SVG/issues/13
