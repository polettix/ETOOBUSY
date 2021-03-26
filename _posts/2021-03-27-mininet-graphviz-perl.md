---
title: Mininet topology visualization with Graphviz from Perl
type: post
tags: [ mininet, perl, graphviz ]
comment: true
date: 2021-03-27 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A more perlish version of [Mininet topology visualization with
> Graphviz][].


In previous post [Mininet topology visualization with Graphviz][] we took a
look at a [Perl][] program to generate a graph description useful to be fed
into the `dot` program.

It turns out that we can control the full generation process from [Perl][]:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use GraphViz2;

say {*STDERR} "paste your data please, then CTRL-D:" if -t;

my $g = GraphViz2->new(global => {directed => 1});
while (<>) {
   my ($A, $B) = m{
      \A
         (.*?)-eth\d+  # first part
         \s* <-> \s*   # "link" indicator
         (.*?)-eth\d+  # second part
   }mxs;
   $g->add_edge(from => $A, to => $B, arrowhead => 'none');
}
$g->run(format => 'png', output_file => 'provapl.png');
```

I thought it would have been more difficult... but [GraphViz2][] is quite
neat and it's easy to learn, yay!

[Mininet topology visualization with Graphviz]: {{ '/2021/03/23/mininet-graphviz-topology/' | prepend: site.baseurl }}
[GraphViz2]: https://metacpan.org/pod/GraphViz2
[Perl]: https://www.perl.org/
