#!/usr/bin/perl -w
#
# update an attribute based on csv input

use strict;

while (<>) {
    chomp;
    my ($dn,$expiration) = (split (/;/))[0,1];

    my $entry = `ldapsearch -D binddn -x -w 'pass' -H ldap://host -LLLb $dn objectclass=\* dn attr`;

    my $expiration_frm_ldap;
    if ($entry =~ /attr:\s*([^\n]+)\n/i) {
	$expiration_frm_ldap = $1;

	  if (defined $expiration_frm_ldap) {
	      next;
	  }
    }

    print "dn: $dn\n";
    print "changetype: modify\n";

    print "replace: attr\n";
    print "attr: $expiration\n";
    print "\n";

}
