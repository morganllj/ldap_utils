#!/usr/bin/perl -w 
#
# 3 * * * * /usr/local/sbin/centralize_dirsrv_logs.pl
#
use strict;

my $short_host=`hostname`;
chomp $short_host;
$short_host=~s/([^\.]+)\..*/$1/;

my $instance="slapd-".$short_host;
my $remote_location="/var/log/dirsrv";
my $local_location="/var/log/dirsrv";
my @logs=qw/access errors audit/;
my $log_host="rsyslog1.oit.domain.org";

my $cmd="rsync -aHe ssh ";

system ("ssh $log_host \"mkdir -p /var/log/dirsrv/slapd-devldap01\"");

for my $l (@logs) {
    $cmd .= "$local_location/". $instance . "/${l}* "
}

$cmd .= " $log_host:" . $remote_location . "/" . $instance;

#print "/$cmd/\n";
system ($cmd);
