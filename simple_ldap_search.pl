#!/usr/bin/perl -w
#

use Net::LDAP;
use Data::Dumper;
use strict;

my $ldap = Net::LDAP->new("ldaps://host") || die "problem connecting";
my $br = $ldap->bind(dn=>"binddn", password=>"pass");
$br->code && die $br->error;
my $sr = $ldap->search(base=>"dc=domain,dc=org", filter=>"uid=morgan", attrs=>['uid'] );
$sr->code && die $sr->error;
my @e = $sr->entries;

print Dumper @e;
