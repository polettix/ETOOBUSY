sub gcd {     # https://en.wikipedia.org/wiki/Euclidean_algorithm
   my ($A, $B) = @_;
   ($A, $B) = ($B % $A, $A) while $A;
   return $B;
}

sub egcd {    # https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
   my ($X, $x, $Y, $y, $A, $B, $q) = (1, 0, 0, 1, @_);
   while ($A) {
      ($A, $B, $q) = ($B % $A, $A, int($B / $A));
      ($x, $X, $y, $Y) = ($X, $x - $q * $X, $Y, $y - $q * $Y);
   }
   return ($B, $x, $y);
}
