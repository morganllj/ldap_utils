#!/usr/bin/perl -w
#
# morgan@morganjones.org
# import a csv file into ldap--used to bulk add users from a csv.
# Not the most straightforward to use and needs to be generalized but got the job done.

# $ perl -pi -e 's/\r/\n/g' Morgan_Charter_Import.csv
# $ ~/Docs/git/ldap_utils/import_from_csv.pl < ~morgan/Desktop/Morgan_Charter_Import.csv |ldapmodify -a -x -H ldaps://devldapm01.domain.org -y ~/Docs/.pass

# to delete if applicable:
# $ ldapsearch -LLL -x  -y ~/Docs/.pass -H ldaps://devldapm01.domain.org orgaccountstatuslog="*for Compass*" dn| sed 's/dn: //' | ldapdelete  -v  -D uid=morgan,ou=employees,dc=domain,dc=org -y ~/Docs/.pass -H ldaps://devldapm01.domain.org
#


use strict;

my @fields = qw/orgeidn uid userpassword cn givenname sn orgmiddlename orgsuffix orghomeorgcd orghomeorg orgsponsorhomeorgcd orgsponsorhomeorg orgsponsoreidn orgvendorname mail orgworktelephonedid orgassociateusertypecd orgassociateusertype orgstateid sambasid/;

my @common_fields = qw/objectClass inetorgperson objectClass ntUser objectClass orgAssociate objectClass top objectClass sambaSamAccount objectClass organizationalPerson objectClass person objectClass inetuser orgAccountActive TRUE orgAccountStatus ACTIVE nsAccountLock FALSE/;

push @common_fields, ("orgAccountStatusLog", "201508170000000Z; 0000060473-kacless imported user for Compass from Oracle External Users");

while (<>) {
#    my ($homeorgcd, $empid) = (split (/,/))[0,3];
    my @field_values = split /,/;

    next if ($field_values[0] eq "orgEIDN");

    # my $count = split //, $empid;
    # my $fill = 10-$count;
    # $empid = '0' x $fill . $empid;

    my $empid = $field_values[0];
    next unless ($empid);

      my $entry = `ldapsearch -D uid=morgan,ou=employees,dc=domain,dc=org -x -w 'pass' -H ldaps://ldapm01.domain.org -LLLb dc=domain,dc=org orgeidn=$empid dn objectclass`;
    
    my $dn = $1
        if ($entry =~ /dn:\s*([^\n]+)\n/);

#    next if (defined $dn);
    if (defined $dn) {
	print STDERR "skipping $dn...\n";
	next;
    }

    my $dn2add = "uid=" . $field_values[1] . ",ou=employees,dc=domain,dc=org";

    print "dn: $dn2add\n";
#    print "changetype: add\n";

    # if ($entry !~ /objectclass: orgrole/i) {
    # 	print "add: objectclass\n";
    # 	print "objectclass: orgrole\n";
    # 	print "-\n";
    # }

    # print "replace: orgRoleTransROR\n";
    # print "orgRoleTransROR: $homeorgcd\n";
    # print "\n";

    my $h = 0;
    for (@common_fields) {
	if (!($h % 2)) {
	    print $common_fields[$h];
	} else {
	    print ": ", $common_fields[$h], "\n";
	}
	$h++;
    }
      

    my $i = 0;
    for (@fields) {
	chomp $field_values[$i];
	print $fields[$i] , ": " , $field_values[$i] . "\n";
	$i++;
    }
    print "ntuserdomainid: $field_values[1]\n";
    print "\n";
}
