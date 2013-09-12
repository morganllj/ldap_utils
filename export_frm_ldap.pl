#!/usr/bin/perl -w
#

use strict;
use Net::LDAP;
use Getopt::Std;
use Data::Dumper;

my $buf='';

my %opts;
getopts('H:D:b:y:w:s', \%opts);

exists $opts{D} || print_usage();
exists $opts{b} || print_usage();
(exists $opts{y} || exists $opts{w}) || print_usage();
my $filter = shift @ARGV;

my $pass;
if (exists $opts{y}) {
    open (IN, $opts{y}) || die "can't open $opts{y}";
    $pass = <IN>;
    chomp $pass;
} else {
    $pass = $opts{w};
}

my @attrs = @ARGV
  if ($#ARGV>-1);

my $ldap=Net::LDAP->new($opts{H}) || die "$@";

my $bind_rslt = $ldap->bind($opts{D}, password=>$pass);
$bind_rslt->code && die "problem binding: ", $bind_rslt->error;

if ($#attrs < 0) {
    print "please specify attributes for the time being...\n";
    print_usage();
#    my $rslt = $ldap->search(base=>$opts{b}, filter=>$opts{f});
} else {
    my $rslt = $ldap->search(base=>$opts{b}, filter=>$filter, attrs=>[@attrs]);
    $rslt->code && die "problem searching: ", $rslt->error;
    
    for my $entry ($rslt->entries) {
	my @values;
	for my $attr (@attrs) {
	    push @values, ($entry->get_value($attr))[0];
	}
	my $skip_entry = 0;

	for my $v (@values) {
	    $skip_entry = 1
	      if ($v =~ /^\s*$/ && exists $opts{s});
	}
	if (!$skip_entry) {
	    for (my $i=0; $i<=$#values; $i++) {
		print $values[$i];
		print ","
		  unless ($i == $#values);
	    }
	    print "\n";
	}

    }
}


sub print_usage {
    print "usage: $0 [-s] -D binddn -b basedn -y passfile || -w pass\n\n";
    print "\t-s skip if attributes are empty\n";
    exit;
}
