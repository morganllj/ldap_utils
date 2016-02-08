#!/usr/bin/perl -w
#

use strict;
use Date::Pcalc qw(Delta_Days);
use Time::Local;
use Net::LDAP;
use Getopt::Std;
use strict;

$/ = "";

my %opts;
getopts('n', \%opts);

if (exists $opts{n}) {
    print "-n used, no changes will be made\n";
    print "\n";
};


my $ldap = Net::LDAP->new("devldapm.domain.net") || die "$@";
my $bind_rslt = $ldap->bind("uid=morgan,ou=employees,dc=domain,dc=org", password=>"pass");
$bind_rslt->code && die "problem binding: ", $bind_rslt->error;

my $rslt = $ldap->search(base=>"dc=domain,dc=org", 
			 filter=>"(orgaccountexpirationdate=replace)",
			 attrs=>["orgaccountexpirationdate", "uid", "orgaccountstatuslog"]);
$rslt->code && die "problem searching: ", $rslt->error;

for my $entry ($rslt->entries) {
    my $new_expiration;
    my $old_expiration = $entry->get_value("orgaccountexpirationdate");
    my $uid = $entry->get_value("uid");
    my @account_status_log = $entry->get_value("orgaccountstatuslog");

    my $dn = $entry->dn;

    print "$uid ";

    my $most_recent_disable_date;
    my $number_of_disable_dates = 0;
    for (@account_status_log) {
	if (/(.*)\s+ams2ldap disabled by HR/) {
	    my $disable_date = $1;
	    $number_of_disable_dates++;
	    if ($disable_date !~ /Z$/) {
		print "Not in GMT!? $disable_date. Skipping.\n";
		next;
	    }

	    # from accountstatuslog
	    my $year =  join '', (split //, $disable_date)[0..3];
	    my $month = join '', (split //, $disable_date)[4..5];
	    my $day =   join '', (split //, $disable_date)[6..7];


	    if (defined $most_recent_disable_date) {
		# from most recent disabled date if applicable
		my $most_recent_year =  join '', (split //, $most_recent_disable_date)[0..3];
		my $most_recent_month = join '', (split //, $most_recent_disable_date)[4..5];
		my $most_recent_day =   join '', (split //, $most_recent_disable_date)[6..7];

		# update most recent disabled date if its more recent than the current
		my $days;

		$days = Delta_Days ($year, $month, $day, 
		    $most_recent_year, $most_recent_month, $most_recent_day);
		if ($days < 0) {
		    $most_recent_disable_date = $disable_date;
		}
	    } else {
		# set most recent if it wasn't set prior
		$most_recent_disable_date = $disable_date;
	    }
	}
    }

    print "$number_of_disable_dates ";

    my $expiration_date;
    if (defined $most_recent_disable_date) {

	# calculate and populate the expiration date
	my $year =  join '', (split //, $most_recent_disable_date)[0..3];
	my $month = join '', (split //, $most_recent_disable_date)[4..5];
	my $day =   join '', (split //, $most_recent_disable_date)[6..7];

	my $time =  join '', (split //, $most_recent_disable_date)[8..14];

	my ($exp_year, $exp_month, $exp_day) = Date::Pcalc::Add_Delta_Days($year, $month, $day, 1095);
	$exp_month = "0" . $exp_month if ($exp_month<10);
	$exp_day =   "0" . $exp_day if ($exp_day<10);
	
	$expiration_date  = $exp_year . $exp_month++ . $exp_day . $time ;
    } else {
	print "Warning: $uid has an accountexpiration of replace but no accountstatuslog with a disable date!\n";
	next;
    }

    print "$expiration_date ";

    unless (exists $opts{n}) {
	my $mod_result = $ldap->modify( $dn, 
					replace => { orgaccountexpirationdate => $expiration_date });
	$mod_result->code && die "problem modifying ldap: ", $mod_result->error;
    }

    print "success";
    print "\n";
}



