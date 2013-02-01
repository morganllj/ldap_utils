#!/usr/bin/perl -w
#
# update an attribute based on csv input
#   originally built for orgRoleTransROR


use strict;

while (<>) {
    my ($homeorgcd, $empid) = (split (/,/))[0,3];

    my $count = split //, $empid;
    my $fill = 10-$count;
    $empid = '0' x $fill . $empid;

    my $entry = `ldapsearch -D uid=morgan,ou=employees,dc=domain,dc=org -x -w 'pass' -H ldaps://devldap02.domain.org -LLLb dc=domain,dc=org orgeidn=$empid dn objectclass`;
    
    my $dn = $1
      if ($entry =~ /dn:\s*([^\n]+)\n/);

    next unless (defined $dn);

    print "dn: $dn\n";
    print "changetype: modify\n";

    if ($entry !~ /objectclass: orgrole/i) {
	print "add: objectclass\n";
	print "objectclass: orgrole\n";
	print "-\n";
    }


    print "replace: orgRoleTransROR\n";
    print "orgRoleTransROR: $homeorgcd\n";
    print "\n";

}
