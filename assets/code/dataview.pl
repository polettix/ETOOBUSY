#!/usr/bin/env perl
use v5.36;
use autodie;

MyViewer->new->run;

package MyViewer;
use v5.36;
use Curses::UI;
use Curses qw< KEY_ENTER KEY_UP KEY_DOWN KEY_HOME >;
use JSON::PP qw< decode_json >;
use YAML::Dump 'Dump';
use List::Util 'reduce';
use Capture::Tiny 'capture';

sub cui ($self) { return $self->{cui} }
sub new ($package, %args) { return bless(\%args, $package)->init }
sub run ($self) { $self->cui->mainloop }

sub init ($self) {
   my $cui = $self->{cui} = Curses::UI->new(
      -clear_on_exit => 1,
      -mouse_support => 0,
      -debug         => $ENV{DEBUG},
   );
   $cui->set_binding(sub { exit 0 }, "\cC", "\cQ", "\cX");

   # Order matters for overlapping windows a bit
   $self->init_selectors_win->init_command_entry->init_data_viewer;

   $self->set_view("Run a command to get some data...");

   $self->focus_entry;
   return $self;
} ## end sub init ($self)

sub init_selectors_win ($self) {
   $self->cui->add(
      selectors_win => 'Window',
      -height       => 1,
      -y            => 2,
      -border       => 1,
      -userdata     => {},
   );
   return $self;
} ## end sub init_selectors_win ($self)

sub init_command_entry ($self) {
   my $entry = $self->cui->add(
      command_win => 'Window',
      -height     => 1,
      -border     => 1,
      -y          => 0,
      -onfocus    => sub { $self->clean_entry },
      -userdata   => {},
   )->add(entry => 'TextEntry', -width => -1);
   $entry->set_binding(sub { $self->focus_selectors }, "\x1b");
   $entry->set_binding(sub { $self->run_command },     KEY_ENTER);
   $entry->set_binding(sub { $self->history(-1) },     KEY_DOWN);
   $entry->set_binding(sub { $self->history(1) },      KEY_UP);
   return $self;
} ## end sub init_command_entry ($self)

sub init_data_viewer ($self) {
   my $viewer = $self->cui->add(data_win => 'Window', -y => 5)->add(
      viewer        => 'TextViewer',
      -text         => 'XXX',
      -showoverflow => 1
   );
   $viewer->set_binding(sub { $self->focus_selectors }, KEY_ENTER, "\x1b");
   $viewer->set_binding(sub { $self->focus_entry }, ":");
   return $self;
} ## end sub init_data_viewer ($self)

sub history ($self, $delta) {
   my $entry = $self->command_entry;
   my $ud = $entry->userdata;
   my $position = $ud->{position} + $delta;
   return if $position < 0 || $position > $ud->{provisional}->$#*;
   $ud->{provisional}->[$ud->{position}] = $entry->get;
   $entry->text($ud->{provisional}->[$ud->{position} = $position]);
   return $self;
} ## end sub history

sub clean_entry ($self) {
   my $entry = $self->command_entry;
   my $ud = $entry->userdata;
   $entry->text('');
   $ud->{provisional} = ['', ($ud->{history} //= [])->@*];
   $ud->{position} = 0;
   return $self;
} ## end sub clean_entry ($self)

sub run_command ($self) {
   my $command = $self->command_entry->get;
   exit 0 if $command =~ m{\A q (uit)? \z}imxs;
   my $entry = $self->command_entry;
   my $ud = $entry->userdata;
   unshift $ud->{history}->@*, $command;
   $ud->{provisional} = '';

   my $cui = $self->cui;
   $cui->leave_curses;
   my $set_from_stdout = 0;
   my ($stdout, $stderr) = capture {
      $set_from_stdout = !system {'/bin/sh'} '/bin/sh', '-c', $command;
      say {*STDERR} 'Press RETURN to go back to the program';
      scalar <STDIN>;
   };
   $cui->reset_curses;

   if ($set_from_stdout && (my $data = eval { decode_json($stdout) })) {
      $self->show($data);
   }

   $self->focus_selectors;
} ## end sub run_command ($self)

sub _get ($self, @chain) {
   reduce { $a->getobj($b) } $self->cui, @chain;
}

sub command_entry ($self) { $self->_get(qw< command_win entry >) }
sub selectors_win ($self) { $self->_get(qw< selectors_win >) }
sub viewer ($self)        { $self->_get(qw< data_win viewer >) }

sub set_view ($self, $data, $home = !!0) {
   my $viewer = $self->viewer;
   $viewer->text($data);
   $viewer->process_bindings(KEY_HOME) if $home;
   $viewer->draw;
   return $self;
} ## end sub set_view

sub focus_entry ($self)     { $self->command_entry->focus }
sub focus_selectors ($self) { $self->selectors_win->focus }
sub focus_viewer ($self)    { $self->viewer->focus }

sub names_for ($self, $aref) {
   +{map { $_ => $_ + 1 } 0 .. $aref->$#*};
}

sub add_selector ($self, $keys, $labels = {}) {
   my $selwin = $self->selectors_win;
   my $ud     = $selwin->userdata;
   my $sels   = $ud->{selectors} //= [];

   # calculate offset
   my $offset = 0;
   $offset += $selwin->getobj($_)->width + 2 for $sels->@*;

   push $sels->@*, my $id = 'selector-' . $sels->@*;
   my $update_cb = sub {
      $self->show_data_slice;
      $self->cui->draw;
   };
   my $obj = $selwin->add(
      $id          => 'Popupmenu',
      -values      => $keys,
      -labels      => $labels,
      -wraparound  => 1,
      -selected    => 0,
      -x           => $offset,
      -onchange    => $update_cb,
      -onselchange => $update_cb,
      -onfocus     => $update_cb,
      -onblur      => $update_cb,
   );
   $obj->set_binding(sub { $self->focus_entry },  ":");
   $obj->set_binding(sub { $self->focus_viewer }, ".");

   return $self;
} ## end sub add_selector

sub show_data_slice ($self) {
   return if $self->{setting_up};
   my $data            = $self->{data} //= {};
   my $selwin          = $self->selectors_win;
   my $ud              = $selwin->userdata;
   my @selectors_names = ($ud->{selectors} // [])->@*;
   my $key;
   for my $name (@selectors_names) {
      my $selector = $selwin->getobj($name);
      $key = $selector->get;
      $data =
          ref $data eq 'ARRAY' ? $data->[$key]
        : $key eq '*'          ? $data
        :                        $data->{$key};
   } ## end for my $name (@selectors_names)

   my $reset_to_home = ($ud->{last_key} // '') ne $key;
   $self->set_view(Dump($data), $reset_to_home);
   $ud->{last_key} = $key;
   return $self;
} ## end sub show_data_slice ($self)

sub show ($self, $data) {
   $self->set_view('ok, showing...');
   $self->{setting_up} = 1;

   my $selwin = $self->selectors_win;
   my $ud = $selwin->userdata;

   my $selectors = $ud->{selectors} // [];
   $ud->{selectors} = [];
   $selwin->delete($_) for $selectors->@*;

   my %forkeys;
   if (ref $data eq 'ARRAY') {
      %forkeys = (%forkeys, $_->%*) for $data->@*;
      $self->add_selector([0 .. $data->$#*], $self->names_for($data));
   }
   else {
      %forkeys = $data->%*;
   }

   my @keys = ((sort { $a cmp $b } keys %forkeys), '*');
   $self->add_selector(\@keys);

   $self->{setting_up} = 0;
   $self->{data}       = $data;
   $self->show_data_slice;

   $self->focus_selectors;
   return $self;
} ## end sub show

1;
