#!/usr/bin/perl -w
#

# ldapsearch -w pass -h host -x -LLLb base -D uid=morgan,ou=people,dc=domain,dc=org '(&(|(objectclass=orgperson)(objectclass=orgnonperson))(orgactiveinactive=i))' uid orghrexpirationdate| ./convert_expiration_dates.pl

use strict;
use Date::Pcalc;

$/ = "";

while (<>) {
    my $old_expiration;
    my $new_expiration;

    my ($uid) = /uid:\s*([^\n]+)\n/;

    if (/orghrexpirationdate:\s*([^\.]+)\./i) {
	print "$uid";
	$old_expiration = $1;
	print " $old_expiration"
    } else {
	next;
    }

    if (defined $old_expiration) {
	my $year = join '', (split //, $old_expiration)[0..3];
	my $month = join '', (split //, $old_expiration)[4..5];
	my $day = join '', (split //, $old_expiration)[6..7];
#	print " $year $month $day\n";

	my ($exp_year, $exp_month, $exp_day) = Date::Pcalc::Add_Delta_Days($year, $month, $day, 1064);
	$exp_month = "0" . $exp_month if ($exp_month<10);
	$exp_day = "0" . $exp_day if ($exp_day<10);
	$new_expiration = $exp_year . $exp_month . $exp_day;
	print " $new_expiration";
	if ($new_expiration > 20140811) {
	    print " N";
	} else {
	    print " Y";
	}
    } else {
	print "no_expiration";
    }
    
    print "\n";
}



