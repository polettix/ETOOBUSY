use v6;

class Pmf {
   has %.pmf;

   method TWEAK (:%!pmf) {}

   method gist () {
      return gather {
         take '---';
         for %!pmf.keys.sort -> $key {
            take "  «$key» {%!pmf{$key}}";
         }
      }.join("\n");
   }

   method total () { return [+] %!pmf.values }

   method normalize (Numeric:D $sum = 1) {
      my $total = self.total or return;
      my $factor = $sum / $total;
      %!pmf.values »*=» $factor;
      self;
   }

   method set ($key, $value) { %!pmf{$key} = $value; self }

   method increment ($key, $amount) {
      %!pmf{$key} += $amount;
      return self;
   }
   method multiply ($key, $factor) {
      %!pmf{$key} *= $factor;
      return self;
   }

   method probability ($key) { self.P($key) }
   method P ($key) {
      die "no key '$key' in PMF" unless %!pmf{$key}:exists;
      return %!pmf{$key} / self.total;
   }
}

class Suite is Pmf {
   has &!likelihood is required;
   submethod BUILD (:lh(:&!likelihood)) { }

   method update ($data) {
      for self.pmf.keys -> $hypothesis {
         my $lh = &!likelihood($data, $hypothesis);
         self.multiply($hypothesis, $lh);
      }
      return self.normalize;
   }
}

sub MAIN {
   my $s = Suite.new(
      likelihood => -> $d, $h { 1 },
      pmf => <A 10 B 20>.hash);
   $s.say;
   $s.update(<A 1>.hash);

   my %mix-for = (
      'Bowl 1' => { vanilla => 3/4, chocolate => 1/4 },
      'Bowl 2' => { vanilla => 2/4, chocolate => 2/4 },
   );
   my $cookie = Suite.new(
      pmf => hash('Bowl 1', 1, 'Bowl 2', 1),
      lh  => -> $D, $H { %mix-for{$H}{$D} },
   );
   $cookie.say;
   $cookie.update('vanilla');
   $cookie.say;
   $cookie.P('Bowl 1').put;

   # in naming doors, we assume that door A is what the player chooses
   # and that door B is the one opened by Monty Hall
   my $mhall = Suite.new(
      pmf => hash(A => 1, B => 1, C => 1),
      lh => -> $D, $H { {A => 1/2, B => 0, C => 1}.AT-KEY($H) },
   );
   $mhall.update('B'); # as said... Monty opens door B
   put "$_ -> {$mhall.P($_)}" for <A B C>;


   # Hypothesis A is that Bag #1 is from 1994 and Bag #2 is from 1996
   # Hypothesis B is that Bag #1 is from 1996 and Bag #2 is from 1994
   my $mnm = Suite.new(
      pmf => hash(hash(A => 1, B => 1)),
      lh  => sub ($D, $H) {
         state %mix-for = (
            1994 => hash(
               brown => 30,
               yellow => 20,
               red => 20,
               green => 10,
               orange => 10,
               tan => 10,
            ),
            1996 => hash(
               blue => 24,
               green => 20,
               orange => 16,
               yellow => 14,
               red => 13,
               brown => 13,
            ),
         );
         state %hypothesis-for = (
            A => { bag1 => 1994, bag2 => 1996 },
            B => { bag1 => 1996, bag2 => 1994 },
         );
         my ($from-bag1, $from-bag2) = @$D;
         return %mix-for{%hypothesis-for{$H}<bag1>}{$from-bag1}
            * %mix-for{%hypothesis-for{$H}<bag2>}{$from-bag2};
      }
   );
   $mnm.say;
   $mnm.update(<yellow green>).say;

   my $dice = Suite.new(
      pmf => hash(4 => 1, 6 => 1, 8 => 1, 12 => 1, 20 => 1),
      lh => sub ($D, $H) { $D <= $H ?? (1 / +$H) !! 0 },
   );
   $dice.update(6).say;
}
