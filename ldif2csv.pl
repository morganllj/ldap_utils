#!/usr/bin/perl -w
#

# usage:
# for i in `cat google.csv | cut -d',' -f1` ; do ldapsearch -x -H ldaps://sgldap.philasd.net -LLL -y ~/.pass mail=$i sdpSIDN sdpGAFEDefaultOrgUnit sdpHomeOrgCD sdpStudentActive sdpStudentOnSite sdpwithdrawaldate sdpwithdrawalstatuscd sdpwithdrawalstatus; done |~/ldif2csv.pl -f sdpsidn,sdpgafedefaultorgunit,sdphomeorgcd,sdpstudentactive,sdpstudentonsite,sdpwithdrawaldate,sdpwithdrawalstatuscd,sdpwithdrawalstatus 2>&1 | tee google_results.csv

use Getopt::Std;
use Data::Dumper;
getopts('f:', \%opts);

my @fields;
if (exists $opts{f}) {
    @fields=split(/,/, lc $opts{f});
    print join (',', @fields), "\n";
}
  
$/="";

while (<>) {
    s/\n //;

    my @e = split /\n/;

    my %h;
    
    for (@e) {
	chomp;

	@l=split /:\s+/;

	if (/^dn:/) {
	    next;
	}

	$h{lc $l[0]} = $l[1]
    }

    my $c = 0;
    for my $field (@fields) {
	if (exists $h{$field}) {
	    print "\""
	      if ($h{$field} =~ /\,/);
	    
	    print $h{$field};
	    
	    print "\""
	      if ($h{$field} =~ /\,/);
	}

	print "," if (++$c <= $#fields);
    }

    print "\n"
}
