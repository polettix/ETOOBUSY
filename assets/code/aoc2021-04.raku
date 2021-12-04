#!/usr/bin/env raku
use v6;

sub MAIN ($filename = $?FILE.subst(/\.raku$/, '.tmp')) {
   my $inputs = get-inputs($filename);
   my ($part1, $part2) = solve($inputs);

   my $highlight = "\e[1;97;45m";
   my $reset     = "\e[0m";
   put "part1 $highlight$part1$reset";
   put "part2 $highlight$part2$reset";
}

class Board {
   has %!cell-for;
   has @!cell-at;
   has %!count-for;
   has $!score = Nil;

   multi method BUILD (Str:D :$desc) {
      my $ri = 0;
      for $desc.split(/\r?\n/) -> $line {
         %!count-for<rows>[$ri] = 0;
         my $ci = 0;
         for $line.split(/\s+/) -> $cell {
            %!count-for<cols>[$ci] //= 0;
            next unless $cell ~~ /\d/;
            @!cell-at[$ri][$ci] = %!cell-for{$cell} = [$ri, $ci, 0, $cell];
            ++$ci;
         }
         ++$ri;
      }
   }
   method sweep-by-cols (&cb) {
      my $n-rows = @!cell-at.end;
      my $n-cols = @!cell-at[0].end;
      for 0 .. $n-cols -> $ci {
         for 0 .. $n-rows -> $ri {
            &cb(@!cell-at[$ri][$ci]);
         }
      }
   }
   method sweep-by-rows (&cb) {
      my $n-rows = @!cell-at.end;
      my $n-cols = @!cell-at[0].end;
      for 0 .. $n-rows -> $ri {
         for 0 .. $n-cols -> $ci {
            &cb(@!cell-at[$ri][$ci]);
         }
      }
   }
   method dump () {
      @!cell-at.say;
      %!cell-for.say;
      %!count-for.say;
   }
   method print () {
      my $last;
      my @line;
      self.sweep-by-rows: -> $cell {
         if ($last && $last[0] < $cell[0]) {
            @line.join(' ').put;
            @line = ();
         }
         @line.push: '%2d%s'.sprintf($cell[3], $cell[2] ?? '*' !! ' ');
         $last = $cell;
      };
      @line.join(' ').put;
   }
   method mark ($value) {
      return unless %!cell-for{$value}:exists;
      my $cell = %!cell-for{$value};
      $cell[2] = 1;
      %!count-for<rows>[$cell[0]]++;
      %!count-for<cols>[$cell[1]]++;
      if ! defined $!score {
         if (@!cell-at.elems == %!count-for<cols>[$cell[1]])
               || (@!cell-at[0].elems == %!count-for<rows>[$cell[0]]) {
            $!score = 0;
            self.sweep-by-rows: -> $cell {
               $!score += $cell[3] unless $cell[2];
            }
            $!score *= $value;
         }
      }
      return self;
   }
   method reset () {
      for %!count-for.values -> $seq {
         for @$seq -> $item is rw {
            $item = 0;
         }
      }
      for %!cell-for.values -> $cell {
         $cell[2] = 0;
      }
      $!score = Nil;
   }
   method won () { return defined $!score }
   method score () { return $!score }
}

sub get-inputs ($filename) {
   my ($numbers, @boards) = $filename.IO.slurp.split: / (\r?\n) ** 2..* /;
   my @numbers = $numbers.split: /\s*\,\s*/;
   @boards = @boards.map: { Board.new(desc => $^a) };
   return [@numbers, @boards];
}

sub solve ($inputs) {
   return (part1($inputs), part2($inputs));
}

sub part1 ($inputs) {
   my @numbers = $inputs[0].List;
   my @boards = $inputs[1].List;
   for @numbers Z 0 .. * -> ($number, $round) {
      for @boards -> $board {
         if $board.mark($number).won {
            my $score = $board.score;
            .reset for @boards;
            return $score;
         }
      }
   }
   return 'part1'
}

sub part2 ($inputs) {
   my @numbers = $inputs[0].List;
   my @boards = $inputs[1].List;
   for @numbers Z 0 .. * -> ($number, $round) {
      my (@won, @remain);
      for @boards -> $board {
         if $board.mark($number).won {
            @won.push: $board;
         }
         else {
            @remain.push: $board;
         }
      }
      if (@remain.elems == 0) { # last & won
         return @boards[0].score;
      }
      @boards = @remain;
   }
   return 'part2'
}
