---
title: Fantasy Name Generator - a parser
type: post
tags: [ perl, parsing ]
comment: true
date: 2020-11-03 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> A parser for the grammar in [Fantasy Name Generator - a grammar][].

We will of course leverage on the [Parsing toolkit in cglib][] 🤓

```
 1 sub nayme_parse ($expression) {
 2    my $realgroup;
 3    my $group = sub { goto $realgroup };
 4    my $literal = pf_match_and_filter(
 5       pf_regexp(qr{([^|()<>]+)}),
 6       sub ($match) { return $match->[0] },
 7    );
 8    my $literal_set = pf_alternatives($literal, $group);
 9    my $literal_exp =
10      pf_match_and_filter(pf_repeated($literal_set, 0, -1), \&flatten_exp,);
11    my $literal_list = pf_match_and_filter(pf_list($literal_exp, '|'),
12       \&flatten_literal_list);
13    my $literal_group = pf_match_and_filter(
14       pf_sequence('(', $literal_list, ')'),
15       sub ($match) { $match->[1] },
16    );
17 
18    my $template = pf_match_and_filter(
19       pf_regexp(qr{([-BcCdDimMsvV']+)}),
20       sub ($match) {
21          [map { {template => $_} } split m{}mxs, $match->[0]]
22       },
23    );
24    my $template_set = pf_alternatives($template, $group);
25    my $template_exp =
26      pf_match_and_filter(pf_repeated($template_set, 0, -1), \&flatten_exp,
27      );
28    my $template_list = pf_list($template_exp, '|');
29    my $template_group = pf_match_and_filter(
30       pf_sequence('<', $template_list, '>'),
31       sub ($match) { return $match->[1] },
32    );
33 
34    $realgroup = pf_match_and_filter(
35       pf_alternatives($template_group, $literal_group),
36       sub ($match) {
37          return $match->@* > 1
38            ? {alternatives => $match}
39            : $match->[0];
40       },
41    );
42    my $name = pf_alternatives($template_list, $realgroup);
43 
44    my $ast = $name->(\$expression);
45    my $pos = pos($expression) || 0;
46    die 'fail to match: [' . substr($expression, $pos) . "]\n"
47      if $pos < length($expression);
48    return $ast->[0];
49 } ## end sub nayme_parse ($expression)
```

Lines 2-3 are a trick to allow for *mutual recursiveness* in how the parsing
elements can call each other. We pre-declare the parsing variable that will
hold the parser for grammar element `group` as `$realgroup`. This will
eventually be a reference to a `sub`, but we're not ready yet (we will not be
until line 34, actually). So we will wrap it in an *actual* reference to a sub
`$group` (line 3), whose only goal will be to call `$realgroup`.

I don't know if this can be done in a simpler way, but at least this is a way!

The first batch of parsing references (lines 4 through 16) implement the
*literal* part. There is some wrapping and simplification of the returned
values, mainly aimed at producing a simpler output without too many levels.

The second batch (lines 18 through 32) implement the *template* part. The
original grammar was taking care to get one single template character at a
time, but the pattern matcher is currently using the `/g` modifier and is
anyway getting all of them. So we are collecting them at once, and then split
them into individual parts (line 21).

At line 34 everything is available to finally define the `group` part into
`$realgroup`, which will eventually enable `$group` to work correctly.

Lines 44 through 48 implement the actual parsing of the inputs. After the
parsing (line 44), we make sure that nothing was left (lines 45 through 47) and
eventually return the parsing result.

The simplification is performed using a couple of helper functions:

```perl

sub flatten_literal_list ($match) {
   my @retval = map {
      if (ref $_ eq 'ARRAY') {
         my @portion;
         for my $item ($_->@*) {
            if (ref($item) || (@portion == 0) || ref($portion[-1])) {
               push @portion, $item;
            }
            elsif (@portion > 0) {
               $portion[-1] .= $item;
            }
         } ## end for my $item ($_->@*)
         @portion > 1 ? \@portion : $portion[0];
      } ## end if (ref $_ eq 'ARRAY')
      else {
         $_;
      }
   } $match->@*;
   return @retval ? \@retval : '';
} ## end sub flatten_literal_list ($match)

sub flatten_exp ($match) {
   my @retval = map { ref $_ eq 'ARRAY' ? $_->@* : $_ } $match->@*;
   return @retval ? \@retval : '';
}
```

These functions make sure to *flatten* some arrays and avoid too much unneeded
nesting.

Let's see it at work on a a few expressions with this simple wrapper:

```perl
use Data::Dumper; $Data::Dumper::Indent = 1;
say Dumper nayme_parse(shift);
exit 0;
```

Here we go:

```
$ ./nayme 'B<what|ever>c'
$VAR1 = [
  {
    'template' => 'B'
  },
  {
    'alternatives' => [
      'what',
      'ever'
    ]
  },
  {
    'template' => 'c'
  }
];

$ ./nayme '<<<<<<<s>>>>>>>';
$VAR1 = [
  {
    'template' => 's'
  }
];
```

The second example takes a few milliseconds to run (it was taking minutes to
the parser based on [Parse::RecDescent][]). Also... I like the simplified form
*a lot* 😄.

[Fantasy Name Generator - a grammar]: {{ '/2020/11/02/fng-grammar/' | prepend: site.baseurl }} 
[Parsing toolkit in cglib]: {{ '/2020/07/11/parsing-toolkit/' | prepend: site.baseurl }} 
[Parse::RecDescent]: https://metacpan.org/pod/Parse::RecDescent
