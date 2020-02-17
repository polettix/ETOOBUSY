---
title: Text::GitIgnore: multiple false values help
type: post
tags: [ perl ]
comment: true
date: 2020-02-17 08:03:21 +0100
preview: true
---

**TL;DR**

> In the post about [Text::GitIgnore][] we left with a possible issue on the
> provided matcher, here we discuss a possible way forward.

So I decided to work on a patch.

## A lot of *false* things

Initially, I wanted to leverage the fact that [Perl][] has at least four
ways of returning a *false* value:

```shell
$ perl -E '(say $_ ? "true" : "false") for undef, "", 0, "0", 1'
false
false
false
false
true
```

So it would be possible to tweak the function to return a different *false*
value depending on the specific condition, like the empty string when there
is not an explicit match, and the number `0` when the path is excluded
because of a negated pattern line.

This would be straighforward by the way:

```shell
$ git diff
diff --git a/lib/Text/Gitignore.pm b/lib/Text/Gitignore.pm
index fe61033..b4fcb51 100644
--- a/lib/Text/Gitignore.pm
+++ b/lib/Text/Gitignore.pm
@@ -80,7 +80,7 @@ sub build_gitignore_matcher {
     return sub {
         my $path = shift;
 
-        my $match = 0;
+        my $match = '';
 
         foreach my $pattern (@patterns_re) {
             my $re = $pattern->{re};
@@ -93,7 +93,7 @@ sub build_gitignore_matcher {
                 }
             }
             else {
-                $match = !!( $path =~ m/$re/ );
+                $match = 1 if $path =~ m/$re/;
 
                 if ( $match && !@negatives ) {
                     return $match;
```

But... I don't know. I don't even know if it's going to break anything,
although I strongly suspect it doesn't because the current function
*already* can return either a `0` or an empty string (by means of the line
`$match = !!( $path =~ m/$re/ );`).

Fact is that this overloading seems hacky.

## Pass the values?

The other idea I'm toying with now involves letting the user pass values to
be returned in the three cases, inside an options anonymous hash passed as
the second input parameter:

```perl
sub build_gitignore_matcher {
    my ($patterns, $args) = @_;

    if (defined $args) {
        if (ref($args) ne 'HASH') {
            my $msg = "pass multiple patterns as an array reference";
            if (eval "use Carp 'croak';") {
                croak $msg;
            }
            else {
                die "$msg\n";
            }
        }
    }
    else {
        $args = {};
    }

    # ...
```

This also allows addressing an annoyance on `build_gitignore_matcher`: if
you pass the lines *without* enclosing them in an anonymous array, only the
first will be considered but no error will come out...

By the way, I don't know if the best thing here would be to recommend
loading module `Carp` anyway.

Later, the idea is to leverage three variables holding the different truth
values, defaulting to the current ones:

```perl
    # ...

    my $TRUE = exists($args->{true}) ? $args->{true} : 1;
    my $FALSE_UNMATCHED = exists($args->{false_from_no_match})
      ? $args->{false_from_no_match} : 0;
    my $FALSE_NEGATED = exists($args->{false_from_negated})
      ? $args->{false_from_negated} : 0;

    # ...
```

Last, the idea is to leave the basic logic around `$match` *untouched* and
use another variable `$retval` to track the value to be returned:

```perl
    return sub {
        my $path = shift;

        my $match = 0;
        my $retval = $FALSE_UNMATCHED;

        foreach my $pattern (@patterns_re) {
            my $re = $pattern->{re};

            next if $match && !$pattern->{negative};

            if ( $pattern->{negative} ) {
                if ( $path =~ m/$re/ ) {
                    $match = 0;
                    $retval = $FALSE_NEGATED;
                }
            }
            else {
                if ( $path =~ m/$re/ ) {
                    $match = 1;
                    $retval = $TRUE;
                }

                if ( $match && !@negatives ) {
                    return $retval;
                }
            }
        }

        return $retval;
    };
```

In this way:

- by default, the behaviour is exactly as before. Well, not entirely: the
  only false value returned would be `0` and never the empty string;

- the consumer of this function can set its own return values, even to
  all-true strings like `matched`, `unmatched`, `excluded`.

This seems better, although a little too flexible than needed maybe?

Comments welcome!

[Text::Gitignore]: https://metacpan.org/pod/Text::Gitignore
[CPAN]: https://metacpan.org/
[Perl]: https://www.perl.org/
