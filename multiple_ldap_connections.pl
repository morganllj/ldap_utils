#!/usr/bin/perl -w
#
# morgan@morganjones.org
# open an arbitrary number of connections to an ldap server and hold them open
# used for testing how many persistent connections a server can handle

use Net::LDAP;
use Data::Dumper;
use strict;

my %conns;

for (my $i=0; $i<150; $i++) {
    print "opening connection number $i\n";
    $conns{$i} = Net::LDAP->new("ldaps://devldap03.domain.org") || die "problem connecting";
    my $br = $conns{$i}->bind(dn=>"cn=directory manager", password=>"pass");
    $br->code && die $br->error;
    my $sr = $conns{$i}->search(base=>"dc=domain,dc=org", filter=>"uid=morgan", attrs=>['uid'] );
    $sr->code && die $sr->error;
    my @e = $sr->entries;

    print Dumper @e;
}

print "sleeping...\n";
sleep 500000;
