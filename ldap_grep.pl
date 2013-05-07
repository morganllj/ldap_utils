#!/usr/bin/perl -w
#

use strict;

if (!defined $ARGV[0]) {
    print "\nusage: $0 PATTERN [file]\n\n";
    exit;
}

my $value = $ARGV[0];

my @buffer;
my $prev_conn;
my $found=0;

$,="\n";

my $in;
if (defined $ARGV[1]) {
    open ($in, $ARGV[1]) || die "can't open $ARGV[2]";
} else {
    $in = "STDIN";
}


while (<$in>) {
    chomp;

    my ($conn) = /conn=(\d+)\s+/;

    $prev_conn = $conn
      if (!defined $prev_conn);

    if ($conn != $prev_conn) {
	if (/$value/i || $found) {
	    print @buffer;
	    print "\n";
	}

	@buffer = ();
	$prev_conn = undef;
	$found = 0;
    }

    $found = 1
      if (/$value/i);

    push @buffer, $_;

}

if (grep (/$value/i, @buffer) || $found) {
    print @buffer;
    print "\n";
}



