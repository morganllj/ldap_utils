#!/usr/bin/perl -w
#
# morgan@morganjones.org
# given an ldap search print the attributes as a csv
# needs command command line arguments rather than hardcoded values

use strict;
use Net::LDAP;

my $ldap = Net::LDAP->new("mldap03.domain.org") || die "$@";
my $bind_rslt = $ldap->bind("cn=config", password=>"pass");
$bind_rslt->code && die "problem binding: ", $bind_rslt->error;

my $rslt = $ldap->search(base=>"", filter=>"(&(objectclass=zimbraAccount)(zimbramailforwardingaddress=*))",
			attrs=>["zimbramailforwardingaddress", "mail"]);
$rslt->code && die "problem searching: ", $rslt->error;

my @mismatches;

for my $entry ($rslt->entries) {
    my $mail = $entry->get_value("mail");
    my @forwards = $entry->get_value("zimbramailforwardingaddress");

    if ($#forwards > 0) {
	print "mismatch, "
    } else {
	my $l = $mail;
	my $r = $forwards[0];

	$l =~ s/([^@]+)@.*/$1/;
	$r =~ s/([^@]+)@.*/$1/;

#	print "$l $r\n";
	
	if (lc $l ne lc $r) {
	    print "mismatch, ";
	} else {
	    print "ok, ";
	}
    }

    print $mail, ", ", join ' ', @forwards, "\n";


}
