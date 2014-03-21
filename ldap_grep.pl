#!/usr/bin/perl -w
#

use strict;
use Getopt::Std;

sub print_usage();

print_usage()
  if (!defined $ARGV[-1]);

my %opts;
getopt('v', \%opts);

$,=$\="\n";

my $value;
if (exists $opts{v}) {
    $value = $opts{v};
} else {
    if ($#ARGV == 0) {
	$value = $ARGV[-1];
    } else {
	$value = $ARGV[-2];
    }
}

for my $k (keys %opts) {
    print_usage()
      if ($k ne "v")
}

my $found=0;

my $in;
#if (defined $ARGV[-1]) {
if ($#ARGV > 0) {
    open ($in, $ARGV[-1]) || die "can't open $ARGV[-1]";
} else {
    $in = "STDIN";
}

my %conns;
my %matching_conns;

while (<$in>) {
    chomp;

    my ($conn) = /conn=(\d+)\s+/;
    next
      if (!defined $conn);

    push @{$conns{$conn}}, $_;

    if (!exists $opts{v}) {
	if (/$value/i) {
	    $matching_conns{$conn} = 1;
	    if (exists $conns{$conn}) {
		if (!exists ($opts{v})) {
		    print @{$conns{$conn}};
		    delete $conns{$conn}
		}
	    }
	} elsif (exists $matching_conns{$conn}) {
	    if (!exists $opts{v}) {
		print "$_";
		pop @{$conns{$conn}};
	    }
	}
    } else {
	$matching_conns{$conn} = 1
	  if (/$value/);

	if (/closed/ && !exists ($matching_conns{$conn})) {
	    print @{$conns{$conn}};
	    delete $conns{$conn}
	}
    }
}







sub print_usage() {
    print "\nusage: $0 PATTERN [file]\n\n";
    exit;
}
