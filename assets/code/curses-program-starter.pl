#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;
use Curses;

my $win = Curses->new;
curs_set(0);       # don't show the cursor
noecho();          # don't echo keypresses on screen
cbreak();          # get anything unbuffered
$win->keypad(1);

# ... now use $win for most things

endwin();
