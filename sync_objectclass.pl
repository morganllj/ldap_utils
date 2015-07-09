#!/usr/bin/perl -w
#

# ldapsearch -w pass -h host -x -LLLb base -D uid=morgan,ou=people,dc=domain,dc=org '(&(|(objectclass=orgperson)(objectclass=orgnonperson))(orgactiveinactive=i))' uid orghrexpirationdate| ./convert_expiration_dates.pl

use strict;
#use Date::Pcalc qw(Delta_Days);
#use Time::Local;
use Net::LDAP;
use Getopt::Std;
use strict;

$/ = "";
$| = 1;

my %opts;
getopts('n', \%opts);

if (exists $opts{n}) {
    print "-n used, no changes will be made\n";
    print "\n";
};


my $ldap = Net::LDAP->new("ldap.domain.org") || die "$@";
my $bind_rslt = $ldap->bind("cn=directory manager", password=>"pass");
$bind_rslt->code && die "problem binding: ", $bind_rslt->error;

my $new_ldap = Net::LDAP->new("ldaps://ldapm01.domain.org") || die "$@";
my $new_bind_rslt = $new_ldap->bind("cn=directory manager", password=>"pass");
$new_bind_rslt->code && die "problem binding to new ldap: ", $bind_rslt->error;

my $rslt = $ldap->search(base=>"dc=domain,dc=org", 
#			 filter=>"(&(objectclass=orgzimbraperson)(uid=zimbratest*))",
			 filter=>"(objectclass=orgzimbraperson)",
			 attrs=>["objectclass", "uid"]);
$rslt->code && die "problem searching: ", $rslt->error;

for my $entry ($rslt->entries) {
#    my $new_expiration;
    my $ocs = $entry->get_value("objectclass");
    my $uid = $entry->get_value("uid");

    my $dn = $entry->dn;

	my $new_rslt = $new_ldap->search(base=>"dc=domain,dc=org", 
				 filter=>"(uid=$uid)",
				 attrs=>["objectclass", "uid"]);
	$new_rslt->code && die "problem searching: ", $rslt->error;

	my @new_entries = $new_rslt->entries;

	if ($#new_entries != 0) {
	    print " too many/too few entries in new ldap for $uid in new_ldap: $#new_entries ";
	    next;
	} else {
	    my $new_entry = $new_entries[0];
	    my $new_dn = $new_entry->dn;

	    my @new_ocs = $new_entry->get_value("objectclass");

	    my $zimbraPerson_found = 0;
	    for (@new_ocs) {
		$zimbraPerson_found = 1
		  if (/orgZimbraPerson/i);
	    }

	    unless ($zimbraPerson_found) {
		print "adding zimbraperson to $uid...";
		unless (exists $opts{n}) {
		    my $new_mod_result = $new_ldap->modify($new_dn,
							   add => {objectclass => "orgZimbraPerson"});
		    $new_mod_result->code && die "problem modifying new ldap: ", $new_mod_result->error;
		    print "success";
		}

		print "\n";
	    }
	}
}
