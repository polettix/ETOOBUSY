#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use Scalar::Util qw< refaddr >;

my $original = {
    some_array => [ 1, 1, 2, 3, 5, 8 ],
    nested_array => [ ['a'..'l'], ['m'..'z']],
    hash_too => {
        foo => 'bar',
        baz => { hello => 'World!' }
    },
};

{
   my $copy = $original;
   compare_references('plain copy', $original, $copy);
}

{
   my $copy = {$original->%*};
   compare_references('shallow copy', $original, $copy);
}

{
   my $copy = {$original->%*};
   compare_references('shallow copy, first level inside',
      $original->{some_array}, $copy->{some_array});
}

{
   use Storable 'dclone';
   my $copy = dclone($original);
   compare_references('deep copy', $original, $copy);
   compare_references('deep copy, first level inside',
      $original->{some_array}, $copy->{some_array});
   compare_references('deep copy, second level inside',
      $original->{nested_array}[0], $copy->{nested_array}[0]);
}

sub compare_references ($msg, $orig, $copy) {
   say $msg;
   my ($oa, $ca) = (refaddr($orig), refaddr($copy));
   say "  orig: <$oa>";
   say "  copy: <$ca>", ($oa == $ca ? ' (same)' : ' different');
}
