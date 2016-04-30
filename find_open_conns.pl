#!/usr/bin/perl -w
#
# morgan@morganjones.org
# simple no frills script to keep print open connections in linux.
# could use some polishing and generalizing but I believe it works.
# not ldap specific but I've only used it on ldap servers to keep track of run-away connections

use strict;
#use Getopt::Std;

#my %opts;
#getopt('v', \%opts);

print "top\n";

$,=$\="\n";

my $in;

if ($#ARGV > 0) {
    print "opening $ARGV[-1]\n";
    open ($in, $ARGV[-1]) || die "can't open $ARGV[-1]";
} else {
    $in = "STDIN";
}

my %conns;
#my %matching_conns;

while (<$in>) {
    chomp;

    my ($conn) = /conn=(\d+)\s+/;
    next
      if (!defined $conn);

    print "working on $conn";

    push @{$conns{$conn}}, $_;

    if (/closed/) {
    	delete $conns{$conn}
    }



    # if (!exists $opts{v}) {
    # 	if (/$value/i) {
    # 	    $matching_conns{$conn} = 1;
    # 	    if (exists $conns{$conn}) {
    # 		if (!exists ($opts{v})) {
    # 		    print @{$conns{$conn}};
    # 		    delete $conns{$conn}
    # 		}
    # 	    }
    # 	} elsif (exists $matching_conns{$conn}) {
    # 	    if (!exists $opts{v}) {
    # 		print "$_";
    # 		pop @{$conns{$conn}};
    # 	    }
    # 	}
    # } else {
    # 	$matching_conns{$conn} = 1
    # 	  if (/$value/);

    # 	if (/closed/ && !exists ($matching_conns{$conn})) {
    # 	    print @{$conns{$conn}};
    # 	    delete $conns{$conn}
    # 	}
    # }
}


print "open connections:\n";
for my $conn (sort keys %conns) {
    print  @{$conns{$conn}};
}







# sub print_usage() {
#     print "\nusage: $0 PATTERN [file]\n\n";
#     exit;
# }
