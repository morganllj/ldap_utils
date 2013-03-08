#!/usr/bin/perl -w 
#
# 3 * * * * /usr/local/sbin/centralize_dirsrv_logs.pl
#
use strict;

my @dir_hosts = qw/ldapm01-mgmt ldapm02-mgmt ldap01-mgmt ldap02-mgmt devldap01-mgmt devldap02-mgmt ldap0 ldap3 ds01-mgmt ds02-mgmt/;
my $log_host="rsyslog1.oit.domain.org";

my $remote_location="/var/log/dirsrv";
my $local_location="/var/log/dirsrv";
my @logs=qw/access errors audit/;

for my $dir_host (@dir_hosts) {
    my $short_host=$dir_host;
    $short_host=~s/([^\.]+)\..*/$1/;
    my $instance="slapd-".$short_host;
    $instance =~ s/-mgmt$//;

    system ("ssh -l root $log_host \"mkdir -p /var/log/dirsrv/$instance\"");

    my $cmd="ssh -l root ${dir_host} \"rsync --progress -avHe ssh ";

    for my $l (@logs) {
	if ($dir_host eq "ldap0") {
	    $cmd .= "/var/Sun/mps/slapd-ldap0/logs/${l}* "
	} elsif ($dir_host eq "ldap3") {
	    $cmd .= "/var/Sun/mps/slapd-ldap3/logs/${l}* "
	} else {
	    $cmd .= "$local_location/". $instance . "/${l}* "
	}
    }

    $cmd .= " $log_host:" . $remote_location . "/" . $instance . "\"";

    print "\n$cmd\n";
    system ($cmd);
}



