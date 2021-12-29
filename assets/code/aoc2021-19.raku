#!/usr/bin/env raku
use v6;

sub MAIN ($filename = $?FILE.subst(/\.raku$/, '.tmp')) {
   my ($highlight, $reset) = "\e[1;97;45m", "\e[0m";
   my ($part1, $part2) = solve($filename);
   put "part1 $highlight$part1$reset";
   put "part2 $highlight$part2$reset";
}

class ListsMatcher { ... };

sub solve ($filename = '19.tmp', $starter = 0) {
   my @probes = get-inputs($filename);

   my @borged = @probes.splice($starter, 1);
   my $alice-id = 0;
   my $n = @probes.elems;
   BERTO:
   while @probes.elems > 0 {
      my $alice = @borged[$alice-id];
      "finding new neighbors from $alice<name>".note;
      my @left;
      for @probes -> $berto {
         if my $new-berto = match-probes($alice, $berto) {
            @borged.push: $new-berto;
            "   found $new-berto<name>, {--$n} to go".note;
         }
         else {
            @left.push: $berto;
         }
      }
      ++$alice-id;
      if $alice-id > @borged.end {
         die 'disconnected probes ' ~ @left»<name>.join(", ");
      }
      @probes = @left;
   }

   my %beacon-at;
   for @borged -> $probe {
      for $probe<coords>.List -> $p {
         my $key = $p.join(',');
         %beacon-at{$key}++;
      }
   }
   my $part1 = %beacon-at.elems;

   my $part2 = (@borged X @borged).map(
      -> ($alice, $berto) {
         my @diff = ($alice<origin> «-» $berto<origin>)».abs.sum
      }
   ).max;

   return $part1, $part2;
}

sub match-probes ($alice, $berto) {
   for 0 .. 2 -> $xd {
      for 0, 1 -> $xdf {
         my $lm = ListsMatcher.new(
            alice => $alice<lists>[0][0],
            berto => $berto<lists>[$xd][$xdf],
            min-items => (12 - $berto<repetitions>[$xd]),
         );
         while my $m = $lm.next-match {
            my @pairings;
            for @$m -> ($va, $vbc) {
               my $vb = $xdf ?? -$vbc !! $vbc;
               for $alice<byc>[0]{$va}.List X $berto<byc>[$xd]{$vb}.List -> ($ap, $bp) {
                  @pairings.push: ($ap, $bp);
               }
            }
            #@pairings.note;
            for @pairings.combinations(12) -> $c {
               my @yzs = check-pairings($c, $xd);
               next unless @yzs.elems > 1;

               # YAY! matching, return transformed $berto wrt $alice
               my $x = $c[0][1][$xd];
               my $xdo = $c[0][0][0] - ($xdf ?? -$x !! $x);
               #($xd, $xdf, $xdo, |@yzs).note;
               return transform($berto, $xd, $xdf, $xdo, |@yzs);
            }
         }
      }
   }
   return;
}

sub transform ($src, $xd, $xdf, $xdo, $yd, $ydf, $ydo, $zd, $zdf, $zdo) {
   my @coords = $src<coords>.map: -> $p {
      my ($x, $y, $z) = $p[$xd, $yd, $zd];
      $x = $xdo + ($xdf ?? -$x !! $x);
      $y = $ydo + ($ydf ?? -$y !! $y);
      $z = $zdo + ($zdf ?? -$z !! $z);
      ($x, $y, $z);
   };
   return generate-probe($src<name>, @coords, ($xdo, $ydo, $zdo));
}

sub check-pairings ($pairs, $xd) {
   my @ds = (0 .. 2).grep: * != $xd;
   OUTER-LOOP:
   for (@ds, @ds.reverse.Array) X (0, 1) X (0, 1) -> (($yd, $zd), $ydf, $zdf) {
      my ($y, $z) = $pairs[0][1][$yd, $zd];
      my $y-offset = $pairs[0][0][1] - ($ydf ?? -$y !! $y);
      my $z-offset = $pairs[0][0][2] - ($zdf ?? -$z !! $z);
      for @$pairs -> ($a, $b) {
         my ($y, $z) = $b[$yd, $zd];
         next OUTER-LOOP if $y-offset != $a[1] - ($ydf ?? -$y !! $y);
         next OUTER-LOOP if $z-offset != $a[2] - ($zdf ?? -$z !! $z);
      }
      return $yd, $ydf, $y-offset, $zd, $zdf, $z-offset;
   }
   return [];
}

sub generate-probe ($name, @coords, $origin = (0, 0, 0)) {
   my @by-coord;
   my @repetitions;
   for @coords -> $p {
      for 0 .. $p.end -> $d {
         @repetitions[$d] //= 0;
         @repetitions[$d]++ if @by-coord[$d]{$p[$d]}:exists;
         @by-coord[$d]{$p[$d]}.push: $p;
      }
   }
   my @sorted = @by-coord.map: {
      my @straight = $_.keys».Int.sort.List;
      my @reversed = @straight.reverse.map: -*;
      [@straight, @reversed];
   };
   return Map.new(
      'name' => $name,
      'origin' => $origin,
      'coords' => @coords,
      'byc' => @by-coord,
      'lists' => @sorted,
      'repetitions' => @repetitions,
   );
}

sub get-inputs ($filename) {
   $filename.IO.slurp.split(/\n (\n+ | $)/)
   .grep({ .chars })
   .map(
      {
         my ($header, @inputs) = .lines;
         my @coords = @inputs.map: { .split(/ ',' /)».Int.Array }
         ($header) = $header.comb: /\d+/;
         generate-probe("$header", @coords);
      }
   );
}

class ListsMatcher {
   has $!alice     is built is required;
   has $!berto     is built is required;
   has $!min-items is built = 12;
   has $!ia-max;
   has $!ib-max;
   has $!ia;
   has $!ib;
   has %!offsets;

   submethod TWEAK (:$!alice, :$!berto) {
      $!ia-max = $!alice.elems - $!min-items;
      $!ib-max = $!berto.elems - $!min-items;
      $!ia = $!ia-max + 1;  # just to decrease it at the beginning!
      $!ib = 0;
   }

   method next-match () {
      return Nil unless defined $!ia; # no more items

      loop {
         # advance for next match
         if    $!ia > 0        { --$!ia }
         elsif $!ib < $!ib-max { ++$!ib; $!ia = $!ia-max }
         else                  { return $!ia = $!ib = Nil }

         my $offset = $!alice[$!ia] - $!berto[$!ib];
         next if %!offsets{$offset}++;
         my ($a, $b) = $!ia, $!ib;
         my @matches;
         while $a <= $!alice.end && $b <= $!berto.end {
            my $va = $!alice[$a];
            my $vb = $!berto[$b];
            my $vbo = $vb + $offset;
            if    $va < $vbo { ++$a }
            elsif $va > $vbo { ++$b }
            else             { @matches.push: ($va, $vb); $a++; $b++ }
         }

         return @matches if @matches.elems >= $!min-items;
      }
   }
}
