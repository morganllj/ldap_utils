#!/usr/bin/perl -w
#
# simple_jes_directory_backup.pl
# September 7, 2011
# $Id$
# Morgan Jones (morgan@morganjones.org)

use strict;

use Getopt::Std;

my $opts;
getopts('hp:i:D:w:nB:', \%$opts);

my $default_ldap_port = 389;
my $default_bind_dn   = "cn=Directory Manager";

$opts->{h} && print_usage();
my $instance = $opts->{i} || print_usage();
my $default_backup_path = "/var/lib/dirsrv/slapd-" . $instance . "/ldif";

my $backup_path =  $opts->{B} || $default_backup_path;
my $bind_dn =      $opts->{D} || $default_bind_dn;
my $ldap_port =    $opts->{p} || $default_ldap_port;

my $db2ldif = "/usr/lib64/dirsrv/slapd-" . ${instance} . "/db2ldif";

my $search_out =  `ldapsearch -x -Lb "" -s base objectclass=\*`;

die "$backup_path does not exist, exiting.."
    if (! -d $backup_path);

print "beginning directory backup..\n";
for (split /\n/, $search_out) {
    chomp;
    next unless
        (my ($context) = /namingContexts:\s+(.*)$/i);

    my $date = `date +%y%m%d.%H:%M.%S`;
    chomp $date;

    # normalize the context for the filename
    my $context_filename = $context;
    $context_filename =~ s/[^a-zA-Z0-9._]+/_/g;

    my $bkp_cmd = "$db2ldif -s $context -a " . $backup_path . "/" .
        $context_filename . "_" . $date . ".ldif\n";

    print $bkp_cmd . "\n";

    exists $opts->{n} ||
      system "$bkp_cmd";

    if (exists $opts->{n} && $? >> 8 != 0) {
        print "failed to back up context $context: $!\n";;
        next;
    }
}

print "done.\n";



sub print_usage {

    print "\nusage: $0 [-h] [-n] -i <instance> [-B <backup_path>] \n\t[-D <bind dn>] [-p <port>]\n";
    print "example: $0  -i host -B /var/lib/dirsrv/slapd-ares<host>/ldif \n\t-D $default_bind_dn".
     	"-p $default_ldap_port\n";
    print "\n-h print this message\n";
    print "-n show what I'm going to do, don't make changes\n";

    print "\nitems in [] are optional.  Defaults are as they're listed in the example\n";

    print "\n";

    exit 0;
}
