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

sub MAIN {
   my $pmf = Pmf.new(pmf => <A 10 B 20>.hash);
   say $pmf;

   $pmf = Pmf.new(pmf => ('A', 6).hash);
   say $pmf;
   $pmf.increment('A', 4).increment('B', 20);
   $pmf.say;
   $pmf.normalize.say;
   $pmf.probability('A').put;

   $pmf = Pmf.new;
   $pmf.set('A', 10).set('B', 20);
   $pmf.probability('B').put;

   $pmf.multiply('A', 2);
   $pmf.say;
   $pmf.probability('B').put;


   my $cookie = Pmf.new(pmf => ('Bowl 1', 1, 'Bowl 2', 1).hash);
   $cookie.multiply('Bowl 1', 3/4);
   $cookie.multiply('Bowl 2', 1/2);
   say 'probability it came from Bowl 1: ', $cookie.P('Bowl 1');
}
