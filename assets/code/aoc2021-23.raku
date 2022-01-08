#!/usr/bin/env raku
use v6;

sub MAIN ($filename = $?FILE.subst(/\.raku$/, '.sample')) {
   return solve($filename);
}

sub solve ($filename) {
   my $highlight = "\e[1;97;45m";
   my $reset     = "\e[0m";

   my $inputs = get-inputs($filename);
   my ($start, $elapsed);

   $start = now;
   my $part1 = part1($inputs);
   $elapsed = now - $start;
   put "part1 ($elapsed) $highlight$part1$reset";

   $start = now;
   my $part2 = part2($inputs);
   $elapsed = now - $start;
   put "part2 ($elapsed) $highlight$part2$reset";

   return 0;
}

sub get-inputs ($filename) { $filename.IO.comb(/\w/) }

sub part1 ($inputs) { solve-arrangement($inputs) }

sub part2 ($inputs) {
   my @amphipods = @$inputs;
   my @last = @amphipods.splice(4, 4);
   @amphipods.push: <D C B A D B A C>, @last;
   return solve-arrangement(@amphipods.List.flat);
}

class Dijkstra { ... }

sub solve-arrangement ($inputs) {
   my @amphipods = @$inputs;
   my @goal = ('ABCD' x @amphipods / 4).comb(/./);

   my $start = gen-state(@amphipods);
   my $goal  = gen-state(@goal);
   my $graph = graph-structure(@amphipods.elems);

   my $d = Dijkstra.new(
      distance   => sub ($from, $to) {
         die "wtf?!?\n" if $to<from> ne id-of($from);
         return $to<cost>;
      },
      successors => successors-factory($graph),
      id-of => sub ($s) { id-of($s) },
      start => $start,
      goals => [ $goal, ],
   );

   return $d.distance-to($goal);
}

sub successors-factory ($graph) {
   return sub ($state) {
      my $nodes = $state<nodes>;
      my (@ok, @target);
      for (7 .. $nodes.end).reverse -> $j {
         if @ok[$j + 4] // 1 { @ok[$j] = $nodes[$j] == $j % 4 }
         else                { @ok[$j] = 0 }
         my $class = $j % 4;
         next if defined(@target[$class]) || @ok[$j];
         @target[$class] = $nodes[$j] == 4 ?? $j !! 0; # real target > 0
      }

      my @letter_for = < B C D A >;
      my $positions = $state<positions>;
      my @succs;
      for ^$positions -> $apod {
         my $p = $positions[$apod];
         next if @ok[$p];
         my $class = ($apod + 3) % 4;
         if ($p <= 6) { # in the corridor
            my $t = @target[$class] or next;
            my $cost = cost($graph, $state, $p, $t) or next;
            @succs.push: new-state($state, $apod, $t, $cost);
         }
         else { # in a "room"
            my $t = @target[$class];
            if ($t && (my $cost = cost($graph, $state, $p, $t))) {
               @succs.push: new-state($state, $apod, $t, $cost);
               next;
            }
            # add corridor positions
            for 0 .. 6 -> $t {
               my $cost = cost($graph, $state, $p, $t) or next;
               @succs.push: new-state($state, $apod, $t, $cost);
            }
         }
      }
      return @succs;
   }
}

sub gen-state (@amphipods) {
   my @nodes = 4 xx 7; # start with upper lane

   # place amphipods and expand area
   my @position-of;
   my %slot-of = A => 0, B => 1, C => 2, D => 3;
   for @amphipods -> $amphipod { # A => 3, B => 0, C => 1, D => 2
      my $class = ($amphipod.uc.ord - 'A'.ord + 3) % 4;
      @nodes.push: $class;
      @position-of[%slot-of{$amphipod}] = @nodes.end;
      %slot-of{$amphipod} += 4;
   }

   return {
      nodes     => @nodes,
      positions => @position-of,
      cost      => 0, # not really needed...
      overall   => 0,
   };
}

sub new-state ($state, $amphipod, $to, $cost) {
   my @positions = $state<positions>.List.Array;
   my $from = @positions[$amphipod];
   @positions[$amphipod] = $to;
   my @nodes = $state<nodes>.List.Array;
   @nodes[$from, $to] = @nodes[$to, $from];
   my $s = {
      cost      => $cost,
      from      => id-of($state),
      nodes     => @nodes,
      overall   => $state<overall> + $cost,
      positions => @positions,
   };
   id-of($s); # caches the id in %s
   return $s;
}

sub render ($state) {
   my @nodes = $state<nodes>.List;
   my @render;

   my @line = @nodes.splice(0, 2);
   @line.push: '.', @nodes.shift for 1 .. 4;
   @line.push: @nodes.shift;
   @render.push: @line.join('');

   my $first = '-';
   while @nodes {
      my @line = $first;
      @line.push: '|', @nodes.shift for 1 .. 4;
      @line.push: '|';
      @line.push: $first if $first ne ' ';
      @render.push: @line.join('');
      $first = ' ';
   }

   tr/01234/BCDA./ for @render;
   my $id = $state<id> // '«id undefined yet»';
   @render.unshift: '', "$state<cost> $state<overall>", $id, '_' x 11;
   return @render.join("\n");
}

sub cost ($graph, $state, $from is copy, $to) {
   state %factor-for = 3 => 1, 0 => 10, 1 => 100, 2 => 1000;
   my $retval = $graph[$from][$to]<cost> * %factor-for{$state<nodes>[$from]};
   while $from != $to {
      $from = $graph[$from][$to]<next>;
      return if $state<nodes>[$from] ne 4;
   }
   return $retval;
}

sub id-of ($state) { $state<id> //= $state<nodes>.join(',') }

class PriorityQueue {
   has @!items;
   has %!pos-of;
   has %!item-of;
   has &!before;
   has &!id-of;

   submethod BUILD (
      :&!before = {$^a < $^b},
      :&!id-of  = {~$^a},
      :@items
   ) {
      @!items = '-';
      self.enqueue($_) for @items;
   }

   method contains ($obj --> Bool) { self.contains-id(&!id-of($obj)) }
   method contains-id ($id --> Bool) { %!item-of{$id}:exists }
   method dequeue { self!remove-kth(1) }
   method elems { @!items.end }
   # method enqueue ($obj) <-- see below
   method is-empty { @!items.elems == 1 }
   method item-of ($id) { %!item-of{$id}:exists ?? %!item-of{$id} !! Any }
   method remove ($obj) { self.remove-id(&!id-of($obj)) }
   method remove-id ($id) { self!remove-kth(%!pos-of{$id}) }
   method size  { @!items.end }
   method top { @!items.end ?? @!items[1] !! Any }
   method top-id { @!items.end ?? &!id-of(@!items[1]) !! Any }

   method enqueue ($obj) {
      my $id = &!id-of($obj);
      %!item-of{$id} = $obj; # keep track of this item
      @!items[my $k = %!pos-of{$id} ||= @!items.end + 1] = $obj;
      self!adjust($k);
      return $id;
   }
   method !adjust ($k is copy) { # assumption: $k <= @!items.end
      $k = self!swap(($k / 2).Int, $k)
         while ($k > 1) && &!before(@!items[$k], @!items[$k / 2]);
      while (my $j = $k * 2) <= @!items.end {
         ++$j if ($j < @!items.end) && &!before(@!items[$j+1], @!items[$j]);
         last if &!before(@!items[$k], @!items[$j]); # parent is OK
         $k = self!swap($j, $k);
      }
      return self;
   }
   method !remove-kth (Int:D $k where 0 < $k <= @!items.end) {
      self!swap($k, @!items.end);
      my $r = @!items.pop;
      self!adjust($k) if $k <= @!items.end; # no adjust for last element
      my $id = &!id-of($r);
      %!item-of{$id}:delete;
      %!pos-of{$id}:delete;
      return $r;
   }
   method !swap ($i, $j) {
      my ($I, $J) = @!items[$i, $j] = @!items[$j, $i];
      %!pos-of{&!id-of($I)} = $i;
      %!pos-of{&!id-of($J)} = $j;
      return $i;
   }
}

class Dijkstra {
   has %!thread-to is built; # thread to a destination
   has $!start     is built;     # starting node
   has &!id-of     is built;     # turn a node into an identifier

   method new (:&distance!, :&successors!, :$start!, :@goals,
         :$more-goals is copy, :&id-of = -> $n { $n.Str }) {
      my %is-goal = @goals.map: { &id-of($_) => 1 };
      $more-goals //= (sub ($id) { %is-goal{$id}:delete; %is-goal.elems })
         if %is-goal.elems;
      my $id = &id-of($start);
      my $queue = PriorityQueue.new(
         before => sub ($a, $b) { $a<d> < $b<d> },
         id-of  => sub ($n) { $n<id> },
         items  => [{v => $start, id => $id, d => 0},],
      );
      my %thr-to = $id => {d => 0, p => Nil, pid => $id};
      while ! $queue.is-empty {
         my ($ug, $uid, $ud) = $queue.dequeue<v id d>;
         for &successors($ug) -> $vg {
            my ($vid, $alt) = &id-of($vg), $ud + &distance($ug, $vg);
            next if ($queue.contains-id($vid)
               ?? ($alt >= (%thr-to{$vid}<d> //= $alt + 1))
               !! (%thr-to{$vid}:exists));
            $queue.enqueue({v => $vg, id => $vid, d => $alt});
            %thr-to{$vid} = {d => $alt, p => $ug, pid => $uid};
         }
      }
      self.bless(thread-to => %thr-to, :&id-of, :$start);
   }

   method path-to ($v is copy) {
      my $vid = &!id-of($v);
      my $thr = %!thread-to{$vid} or return;
      my @retval;
      while defined $v {
         @retval.unshift: $v;
         ($v, $vid) = $thr<p pid>;
         $thr = %!thread-to{$vid};
      }
      return @retval;
   }
   method distance-to ($v) { (%!thread-to{&!id-of($v)} // {})<d> }
}

sub graph-structure ($n-amphipods) {
   my @neighbors = <
      0  1  1
      1  2  2
      2  3  2
      3  4  2
      4  5  2
      5  6  1
      1  7  2
      2  7  2
      2  8  2
      3  8  2
      3  9  2
      4  9  2
      4  10 2
      5  10 2
      7  11 1
      8  12 1
      9  13 1
      10 14 1
      11 15 1
      12 16 1
      13 17 1
      14 18 1
      15 19 1
      16 20 1
      17 21 1
      18 22 1
   >;
   my $max-position = 6 + $n-amphipods;

   my @path-from-to;
   for @neighbors -> $x, $y, $d {
      next if $x > $max-position || $y > $max-position;
      @path-from-to[$x][$y] = {cost => $d, next => $y};
      @path-from-to[$y][$x] = {cost => $d, next => $x};
   }

   # pre-computing all "Dijkstra"s together, before we modify
   # @path-to-from (which would otherwise make appear nodes as neighbors)
   my @dijkstras = (^@path-from-to).map({
      Dijkstra.new(
         distance   => sub ($from, $to) { @path-from-to[$from][$to]<cost> },
         id-of      => sub ($n) { $n },
         successors => sub ($n) {
            (^@path-from-to[$n]).grep: { defined @path-from-to[$n][$_] };
         },
         start      => $_,
      );
   });

   for ^@path-from-to -> $from {
      my $pt = @path-from-to[$from];
      for ^@path-from-to -> $to {
         next if $from == $to;
         next if defined $pt[$to];
         $pt[$to] = {
            cost => @dijkstras[$from].distance-to($to),
            next => @dijkstras[$from].path-to($to)[1],
         };
      }
   }

   return @path-from-to;
}

sub graph-dot ($graph) {
   my @graph = 'digraph {',;
   for ^@$graph -> $i {
      my $row = $graph[$i];
      for ^@$row -> $j {
         next if $i == $j;
         next if $row[$j]<next> != $j;
         @graph.push: qq{   $i -> $j [label="$row[$j]<cost>"]};
      }
   }
   @graph.push: '}';
   return @graph.join("\n");
}
