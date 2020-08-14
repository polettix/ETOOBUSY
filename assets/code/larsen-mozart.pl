#!/usr/bin/perl

use MIDI;
use MIDI::Simple;
use Getopt::Mixed;
#use Tie::Hash::Cannabinol :))
use strict;

use vars qw/
    $opt_f
    $opt_o
    $opt_t
    $opt_s
    $opt_c
    $opt_n
    $opt_h
/;

Getopt::Mixed::getOptions(
    'f=s filename>f o=s output>o t=i track>t s=i tuple_size>s c=i tracks_to_be_composed>c n=i notes>n h help>h');

my $filename = $opt_f || (usage() and die);   # a MIDI file to learn from
my $output_file = $opt_o || 'fake.mid';
my $track_number = $opt_t || 6;               # the track from $filename to be learned            
my $tuple_size = $opt_s || 9;                 # how many notes for each tuple?
my $tracks_to_be_composed = $opt_c || 3;      # how many tracks?
my $notes_per_track = $opt_n || 100;          # how many notes must be composed per track?

my %tuples = ();

usage() and exit if $opt_h;

my $song = MIDI::Opus->new(
    { from_file => $filename }
) || die "Problems opening MIDI file...\n";


info( $song );
my $score = get_track( $song, $track_number );
learn( $score );
compose();

sub get_track
{
    my ($song, $track_number) = @_;
    
    print "Fetching track $track_number...\n";
    my $track = @{ $song->tracks_r() }[ $track_number - 1 ];
    
    return MIDI::Score::events_r_to_score_r( $track->events_r );
}


sub learn
{
    my $score = shift;

    my @notes = map { $_->[4] } @$score;
    
    while( @notes ) {
        if( scalar @notes >= $tuple_size + 1 ) {
            push @{ $tuples{ join ' ', @notes[0 .. $tuple_size-1] } }, 
                $notes[$tuple_size];
        }
        shift @notes;
    }
    
    print "I've learnt ", scalar keys %tuples, " tuples...\n";
    my $sum = 0;
    $sum += scalar @{ $tuples{$_} } for keys %tuples;
    print "Average number of buckets per key: ", 
        ($sum / scalar keys %tuples), "...\n";
}


sub compose
{
    new_score();

    my $t = 1;

    while( $t <= $tracks_to_be_composed ) {
        print "Composing track $t...\n";    
        compose_track( $t );
        $t++;
    }
    
    print "Finished.\n";
    write_score( $output_file );
}


sub compose_track
{
    my $n = $notes_per_track;
    my ($hit, $miss);

    my @tempo = qw/wn hn qn en sn/;
    my @volume = qw/ppp pp p mp m mf f ff fff/;
    
    my $l = scalar keys %tuples;
    my $k = ( keys %tuples )[ int rand $l ];

    Time( 1 );
    Channel( shift );
    while( $n-- ) {
        my @tuple = @{ $tuples{ $k } };
        my $last = $tuple[ int rand scalar @tuple ];

        n( $last, $tempo[ rand scalar @tempo ], 'f' );

        my @next_tuple = split / /, $k;
        shift @next_tuple;
        push @next_tuple, $last;

        if (defined $tuples{ join ' ', @next_tuple }) {
            $k = join ' ', @next_tuple;
            ++$hit;
        }
        else {
            $k = ( keys %tuples )[ int rand $l ];
            ++$miss;
        }
    }
    print "\tHit/Miss ratio: $hit/$miss\n";
}


sub info
{
    my $song = shift;

    print "Fetching info from MIDI file...\n";
    printf "%6s %-6s %-20s %-20s\n", '#', 'Type', 'Track Name', 'Instrument';
    my $counter = 0;
    foreach my $t ( $song->tracks() ) {
        my $track_info = '';
        my %info = ();
        my $flag = 0;

        foreach($t->events()) {
            if ($_->[0] eq 'track_name' || $_->[0] eq 'instrument_name') {
                $info{ $_->[0] } = $_->[2];
                $flag++;
            }
            last if $flag == 2;
        }

        printf "%6d %-6s %-20s %-20s\n", 
            ++$counter,
            $t->type(),
            $info{'track_name'},
            $info{'instrument_name'};
    }
}


sub usage
{
    print <<USAGE;
    
    mozart.pl -f peaches.mid -t 1 -s 6 -n 100
    by Stefano Rodighiero - larsen\@perlmonk.org

    -f --filename           A midi file to learn from
    -t --track          What track has to be learned
    -s --size           Number of notes for tuple
    -c --tracks_to_be_composed
    -n --notes          Notes to be composed

    -h --help           Shows this message

USAGE
}
