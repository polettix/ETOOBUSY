---
title: SQLite import with AutoCommit turned off
type: post
tags: [ sqlite, perl ]
comment: true
date: 2023-09-20 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Schwern][] wrote [a little gem][].

Some time ago I wanted to import a few CSV files in one [SQLite][]
database file and I initially tried to do it with [Perl][]. It was
*sloooooow*.

Then I looked for alternatives and found out `.import` from the
command-line client `sqlite3`. *This* is reasonably fast, so I used it
straight away and forgot about it.

Until I came to read [Schwern][]'s [little gem][a little gem], hinting
to turn `AutoCommit` off. That hit the nail so good that one single hit
sufficed.

So here's an example:

```perl
#!/usr/bin/env perl
use v5.24;
use warnings;
use experimental 'signatures';

use DBI;
use Text::CSV_XS;

my $csv_file = shift // help_then_die('no CSV file');
my $sqlite_file = shift // help_then_die('no SQLite file');
my $sqlite_table = shift // help_then_die('no SQLite table name');

my $csv_it = csv_it($csv_file);
my $fields = $csv_it->();

my $dbh = DBI->connect("dbi:SQLite:$sqlite_file", '', '',
   { RaiseError => 1, AutoCommit => $ENV{AUTOCOMMIT}, }
);

say scalar(localtime);
$dbh->do(sqlite_create_query($dbh, $sqlite_table, $fields));
$dbh->commit unless $ENV{AUTOCOMMIT};

my $sth = $dbh->prepare(sqlite_insert_query($dbh, $sqlite_table, $fields));
while (my $row = $csv_it->()) {
   $sth->execute($row->@*);
}
$dbh->commit unless $ENV{AUTOCOMMIT};
say scalar(localtime);

sub sqlite_create_query ($dbh, $table, $fields) {
   my $q_table = $dbh->quote_identifier($table);
   my $fields_def = join ",\n", map { "  $_ TEXT" } $fields->@*;
   return "CREATE TABLE IF NOT EXISTS $q_table (\n$fields_def\n)";
}

sub sqlite_insert_query ($dbh, $table, $fields) {
   my $q_table = $dbh->quote_identifier($table);
   my $fields_def = join ', ', $fields->@*;
   my $pholds_def = join ', ', ('?') x scalar($fields->@*);
   return "INSERT INTO $q_table ($fields_def) VALUES ($pholds_def)";
}

sub csv_it ($path, %args) {
   my $csv = Text::CSV_XS->new(
      {
         sep_char => ',',
         %args,
      }
   ) or die Text::CSV_XS->error_diag;
   open my $fh, '<:encoding(UTF-8)', $path
      or die "open('$path'): $!\n";
   return sub { return $csv->getline($fh) };
}

sub help_then_die ($msg) {
   say {*STDERR} "$0 <csv-file> <sqlite-file> <sqlite-table>\n";
   die $msg, "\n";
}
```

Test time:

```
$ rm -f local/prova.db; time AUTOCOMMIT=1 perl csv2sqlite local/somedata.csv local/prova.db whatever
Tue Sep 19 23:08:39 2023
Tue Sep 19 23:09:30 2023

real	0m50.788s
user	0m0.134s
sys	0m6.149s

$ rm -f local/prova.db; time AUTOCOMMIT=0 perl csv2sqlite local/somedata.csv local/prova.db whatever
Tue Sep 19 23:10:21 2023
Tue Sep 19 23:10:21 2023

real	0m0.174s
user	0m0.118s
sys	0m0.023s
```

*This* is what I call a speed improvement!

Cheers!

[Perl]: https://www.perl.org/
[Schwern]: https://stackoverflow.com/users/14660/schwern
[a little gem]: https://stackoverflow.com/questions/15331791/dbicsv-implementation-based-on-sqlite/15337369#15337369
[SQLite]: https://www.sqlite.org/index.html
