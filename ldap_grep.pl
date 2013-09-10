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

my %conns;
my @conns_to_print;

while (<$in>) {
    chomp;

    my ($conn) = /conn=(\d+)\s+/;

    next
      if (!defined $conn);

    push @{$conns{$conn}}, $_;

    push @conns_to_print, $conn
      if (/$value/i);

    for my $conn (@conns_to_print) {
	if (exists $conns{$conn}) {
	    print @{$conns{$conn}};
	    print "\n";
	    delete $conns{$conn};
	}
    }
}





