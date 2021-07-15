package MojoX::Mechanize;
use 5.024000;
use warnings;
use experimental qw< signatures >;
{ our $VERSION = '0.001' }

use Mojo::UserAgent;
use Mojo::Base -base;
no warnings qw< experimental::signatures >;
has ua => sub { Mojo::UserAgent->new(max_redirects => 5) };
has _history => sub { [] };
has _stack_depth => -1;

sub _request ($self, $tx, @args) {
   my $ua = $self->ua;
   $tx = $ua->build_tx(uc($tx), @args) unless ref $tx;
   $tx = $self->ua->start($tx);
   unshift $self->_history->@*, $tx;
   $self->_trim_history;
   return $tx->res;
} ## end sub _request

sub _trim_history ($self) {
   if ((my $sd = $self->_stack_depth // 0) >= 0) {
      my $history = $self->_history;
      pop $history->@* while $history->@* > $sd + 1;
   }
   return $self;
} ## end sub _trim_history ($self)

sub stack_depth ($self, @n) {
   if (@n) {
      $self->_stack_depth(shift(@n) // -1);
      $self->_trim_history;
   }
   return $self->_stack_depth;
} ## end sub stack_depth

sub get ($self, @args) { $self->_request(get => @args) }
sub post ($self, @args) { $self->_request(post => @args) }
sub put ($self, @args) { $self->_request(put => @args) }

sub reload ($self) {
   return unless $self->_history->@* > 0;
   return $self->_request(shift $self->_history->@*);
}

sub back ($self) {
   return unless $self->_history->@* > 1;
   shift $self->_history->@*;
   return 1;
}

sub clear_history ($self) {
   $self->_history->@* = ();
   return $self;
}

sub history_count ($self) { scalar $self->_history->@* }

sub history ($self, $n) {
   my $max = $self->history_count - 1;
   die "insufficient history, no element for $n\n" if $n > $max;
   return $self->_history->[$n];
}

sub res ($self) {
   my $history = $self->_history;
   return unless $history->@*;
   return $history->[0]->res;
}
sub response ($self) { return $self->res }

sub _req ($self) {
   my $history = $self->_history;
   return unless $history->@*;
   return $history->[0]->req;
}

sub _tnt ($self, $this, @that) {
   $this = $self->$this() or return;
   $this = $this->$_() for @that;
   return $this;
}

sub success ($self) { $self->_tnt(res  => 'is_success') }
sub url ($self)     { $self->_tnt(_req => 'url') }
sub status ($self)  { $self->_tnt(res  => 'code') }
sub ct ($self)      { $self->_tnt(res  => qw< headers content_type >) }
sub content_type ($self) { $self->_tnt(res => qw< headers content_type >) }

sub base ($self) {
   if (my $res = $self->res) {
      my ($base) = $res->dom->find('base')->map('href')->each;
      return $base if defined $base;
      $base = $res->headers->header('Base');
      return $base if defined $base;
   } ## end if (my $res = $self->res)
   return $self->url;
} ## end sub base ($self)

sub body ($self) { $self->res->body }

sub links ($self) { $self->find_all_links }

sub find_link ($self, %criteria) {
   my $n = delete($criteria{n}) // 1;
   return unless $n =~ m{\A [1-9]\d* \z}mxs;
   my @links = $self->find_all_links(%criteria);
   return if $n > @links;
   return $links[$n - 1];
} ## end sub find_link

sub find_all_links ($self, %criteria) {
   my $res  = $self->res // return;
   my $base = $self->base;
   state $af = {
      a      => 'href',
      area   => 'href',
      link   => 'href',
      frame  => 'src',
      iframe => 'src',
      meta   => 'content',
   };
   my $checker_for = {text => sub ($x, $s) { $x->text eq $s },
      text_regex => sub ($x, $r) {
         $x->text =~ m{$r};
      }, url => sub ($x, $s) { $x->attr($af->{$x->tag}) eq $s },
      url_regex => sub ($x, $r) {
         $x->attr($af->{$x->tag}) =~ m{$r};
      }, name => sub ($x, $s) { $x->attr('name') // '' eq $s },
      name_regex => sub ($x, $r) {
         $x->attr('name') // '' =~ m{$r};
      }, rel => sub ($x, $s) { $x->attr('rel') // '' eq $s },
      rel_regex => sub ($x, $r) {
         $x->attr('rel') // '' =~ m{$r};
      }, id => sub ($x, $s) { $x->attr('id') // '' eq $s },
      id_regex => sub ($x, $r) {
         $x->attr('id') // '' =~ m{$r};
      }, class => sub ($x, $s) { $x->attr('class') // '' eq $s },
      class_regex => sub ($x, $r) {
         $x->attr('class') // '' =~ m{$r};
      },
      url_abs => sub ($x, $s) {
         my $url = Mojo::URL->new($x->attr($af->{$x->tag}));
         $url = $url->base($base)->to_abs unless $url->is_abs;
         $url eq $s;
      },
      url_abs_regex => sub ($x, $r) {
         my $url = Mojo::URL->new($x->attr($af->{$x->tag}));
         $url = $url->base($base)->to_abs unless $url->is_abs;
         $url =~ m{$r};
      }, tag => sub ($x, $s) { $x->tag eq $s },
      tag_regex => sub ($x, $r) {
         $x->tag =~ m{$r};
      },};
   my $targets = join ',',
     map { $_ . "[$af->{$_}]" } sort { $a cmp $b } keys $af->%*;
   my @links = map {
      my $url = Mojo::URL->new($_->attr($af->{$_->tag}));
      $url->is_abs ? $url : $url->base($base);
   } grep {
      my $go = 1;
      for my $name (keys %criteria) {
         my $condition = $criteria{$name} // next;
         $go = $checker_for->{$name}->($_, $condition) or last;
      }
      $go;
   } $res->dom->find($targets)->each;
   return wantarray ? @links : \@links;
} ## end sub find_all_links

sub follow_link ($self, %criteria) {
   my $url = $self->find_link(%criteria) or die "no link to follow\n";
   my $ref = $self->url->clone;
   $ref->userinfo(undef);
   $ref->fragment(undef);
   $self->get($url->to_abs->to_string, {Referer => "$ref"});
} ## end sub follow_link

exit sub {
   $|++;

   my $ua = MojoX::Mechanize->new;
   $ua->get('https://polettix.it');
   $ua->get('https://github.polettix.it/ETOOBUSY/');
   say $ua->url;
   $ua->back;
   say $ua->url;
   $ua->back;
   say $ua->url;

   say '-' x 20;

   $ua->get('https://polettix.it/xmech');
   say $ua->success;
   say $ua->url;

   say '-' x 20;
   say $_ for $ua->find_all_links(url_abs_regex => qr{xmech});

   say $ua->find_link(url_abs_regex => qr{xmech}, n => 2)->to_abs;

   say "\nfollowing link to sibling";
   $ua->follow_link(url_regex => qr{sibling});
   say $ua->url;
   say $ua->body;
  }
  ->(@ARGV) unless caller;

1;
