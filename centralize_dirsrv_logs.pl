#!/usr/bin/perl -w 
#
# 3 * * * * /usr/local/sbin/centralize_dirsrv_logs.pl
#
use strict;

my @dir_hosts = qw/ldapm01-mgmt ldapm02-mgmt ldap01-mgmt ldap02-mgmt devldap01-mgmt devldap02-mgmt/;
my $log_host="rsyslog1.oit.domain.org";

# my $short_host=`hostname`;
# chomp $short_host;
# $short_host=~s/([^\.]+)\..*/$1/;
# my $instance="slapd-".$short_host;

my $remote_location="/var/log/dirsrv";
my $local_location="/var/log/dirsrv";
my @logs=qw/access errors audit/;



# ssh root@devldap01.domain.org "rsync -n -avHe ssh /var/log/dirsrv/slapd-devldap01/ rsyslog1.oit.domain.org:/var/log/dirsrv/slapd-devldap01"

for my $dir_host (@dir_hosts) {
    my $short_host=$dir_host;
#    chomp $short_host;
    $short_host=~s/([^\.]+)\..*/$1/;
    my $instance="slapd-".$short_host;
    $instance =~ s/-mgmt$//;

    system ("ssh -l root $log_host \"mkdir -p /var/log/dirsrv/$instance\"");

    my $cmd="ssh -l root ${dir_host} \"rsync --progress -avHe ssh ";

    for my $l (@logs) {
	$cmd .= "$local_location/". $instance . "/${l}* "
    }

    $cmd .= " $log_host:" . $remote_location . "/" . $instance . "\"";

    print "\n$cmd\n";
    system ($cmd);
}



