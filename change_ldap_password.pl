#!/usr/bin/perl -w
#
# morgan@morganjones.org
# simple script to change a user's ldap password.  
# I think it's incomplete though should be easily fixed

use strict;
use Net::LDAP;
use Getopt::Std;
use strict;

$/ = "";

my %opts;
getopts('u:o:n:', \%opts);

$opts{u} || print_usage();
$opts{o} || print_usage();
$opts{n} || print_usage();


my $ldap = Net::LDAP->new("devldapm01.domain.org") || die "$@";
my $bind_rslt = $ldap->bind("uid=morgan,ou=people,dc=domain,dc=org", password=>"pass");
$bind_rslt->code && die "problem binding: ", $bind_rslt->error;

my $rslt = $ldap->search(base=>"dc=domain,dc=org", 
			 filter=>"(uid=$opts{u})");
$rslt->code && die "problem searching: ", $rslt->error;

my $entry - $rslt->entries

my $dn = $

for my $entry ($rslt->entries) {
    my $new_expiration;
    my $pass = $entry->get_value("userpassword");

    my $dn = $entry->dn;
    print "dn: $dn\n";

	unless (exists $opts{n}) {
	    my $mod_result = $ldap->modify( $dn, 
 				    replace => { userpassword => $pass });
  $mod_result->code && die "problem modifying: ", $mod_result->error;
	}
	
    }

}

