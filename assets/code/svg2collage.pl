#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

use SVG::Parser;
use Path::Tiny;
use JSON::PP ();

say encode_json(get_fragments(shift // 'prova-template.svg'));

sub get_fragments ($filename) {
   my $parser = SVG::Parser->new(-nocredits => 1);
   my $svg    = $parser->parse(path($filename)->slurp_raw);

   # the following ones are closed-over variables for visiting the
   # SVG::DOM.
   my @conversions;          # support data for conversion from px
   my @text_stack = ({});    # empty base frame
   my @fragments;            # generated fragments, a.k.a. retval

   # this calls the recursive function that visits the whole XML tree
   # of the SVG::DOM. Two callbacks are passed, one called upon entering
   # the function, one called immediately before exiting. Both are
   # optional.
   visit(
      $svg,
      sub ($el) {
         my $tag = fc($el->getElementName);
         if ($tag eq fc('svg')) {
            push @conversions, parse_conversion($el);
         }
         elsif ($tag eq fc('text') || $tag eq fc('tspan')) {
            push @text_stack,
              parse_textish($el, $conversions[-1], $text_stack[-1]);
            push @fragments, may_generate_fragment($text_stack[-1]);
         }
         else { }    # ignore...
      },
      sub ($el) {
         my $tag = fc($el->getElementName);
         if ($tag eq fc('text') || $tag eq fc('tspan')) {
            pop @text_stack;
         }
      },
   );

   # return an array reference holding the list of generated fragments
   return \@fragments;
} ## end sub get_fragments

# Visit the whole SVG::DOM tree, recursively.
sub visit ($el, $pre_cb = undef, $post_cb = undef) {
   $pre_cb->($el) if $pre_cb;
   my $child = $el->getFirstChild();
   while ($child) {
      __SUB__->($child, $pre_cb, $post_cb);
      $child = $child->getNextSibling();
   }
   $post_cb->($el) if $post_cb;
   return;
} ## end sub visit

# variation on https://etoobusy.polettix.it/2022/11/29/json-pppp/
sub encode_json ($data) {
   state $enc = JSON::PP->new->pretty->ascii->canonical;
   return $enc->encode($data);
}

# parse an SVG element to find out the conversion parameters
# https://etoobusy.polettix.it/2023/05/07/svg-viewbox-px/
sub parse_conversion ($el) {
   state $inch_to = {    # conversion table
      mm => 25.4,
      cm => 2.54,
      dm => 0.254,
      m  => 0.0254,
      in => 1,
      pt => 72
   };

   my ($x, $y, $S_W, $S_H) = split m{\s+}mxs,
     ($el->getAttribute('viewBox') =~ s{\A\s+|\s+\z}{}rgmxs);
   my ($W_U, $U) = $el->getAttribute('width') =~ m{
      \A\s*
         (.*?)
         ([a-zA-Z]+)
      \s*\z
   }mxs;
   my $C_U    = $inch_to->{$U} // die "cannot converto inches to $U\n";
   my $factor = (72 * $W_U) / ($C_U * $S_W);
   return {
      X_offset => $x,
      X_span   => $S_W,
      Y_offset => $y,
      Y_span   => $S_H,
      factor   => $factor,
   };
} ## end sub parse_conversion

# Start from any ancestor provided by $upper_frame, taking it as defaults.
# Collect x, y, style and cdata from the current elements, where present.
sub parse_textish ($el, $cv, $upper_frame) {
   my $frame = {$upper_frame->%*};    # shallow copy will do

   # x attribute just needs to be converted from px
   if (defined(my $x = $el->getAttribute('x'))) {
      $frame->{x} = sprintf '%.2f', $x * $cv->{factor};
   }

   # y attribute needs to take into account that PDF's viewport has the
   # origin set on the lower-left corner, not upper-left like SVG.
   if (defined(my $y = $el->getAttribute('y'))) {
      $frame->{y} = sprintf '%.2f', ($cv->{Y_span} - $y) * $cv->{factor};
   }

   # the style attribute can be a trove of useful information
   if (defined(my $style = $el->getAttribute('style'))) {
      if (defined(my $font_size = $style->{'font-size'})) {
         $font_size =~ s{px\z}{}mxs or die "font-size...";
         $frame->{font_size} = sprintf '%.2f', $font_size * $cv->{factor};
      }
      if (defined(my $ta = $style->{'text-align'})) {
         $frame->{align} = $ta;
      }
      if (defined(my $ff = $style->{'font-family'})) {
         $frame->{font_family} = $ff;
      }
   } ## end if (defined(my $style ...))

   # cut to integers if it makes sense
   s{\.00\z}{}mxs for $frame->@{qw< x y font_size >};

   # CDATA might or might not be present, whatever is good
   $frame->{cdata} = $el->getCDATA;

   return $frame;
} ## end sub parse_textish

# a fragment will be generated only when cdata is defined
sub may_generate_fragment ($frame) {
   defined(my $cdata = $frame->{cdata}) or return;
   $cdata =~ s{\A\s+|\s+\z}{}gmxs;    # trim spaces
   return {
      op              => 'add-text',
      'text-template' => $cdata,
      font            => $frame->{font_family},
      'font-size'     => $frame->{font_size},
      x               => $frame->{x},
      y               => $frame->{y},
      align           => ($frame->{align} // 'start'),
   };
} ## end sub may_generate_fragment