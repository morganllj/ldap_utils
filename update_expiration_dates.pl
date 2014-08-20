#!/usr/bin/perl -w
#

# ldapsearch -w pass -h host -x -LLLb base -D uid=morgan,ou=people,dc=domain,dc=org '(&(|(objectclass=orgperson)(objectclass=orgnonperson))(orgactiveinactive=i))' uid orghrexpirationdate| ./convert_expiration_dates.pl

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


my $ldap = Net::LDAP->new("ldapdev1.oit.domain.net") || die "$@";
my $bind_rslt = $ldap->bind("cn=directory manager", password=>"pass");
$bind_rslt->code && die "problem binding: ", $bind_rslt->error;

my $new_ldap = Net::LDAP->new("ldaps://devldapm01-mgmt.domain.net") || die "$@";
my $new_bind_rslt = $new_ldap->bind("cn=directory manager", password=>"pass");
$new_bind_rslt->code && die "problem binding to new ldap: ", $bind_rslt->error;

my $rslt = $ldap->search(base=>"dc=domain,dc=org", 
			 filter=>"(&(orghrexpirationdate=*)(orgaccountstatus=hrterminated))",
			 attrs=>["orghrexpirationdate", "uid"]);
$rslt->code && die "problem searching: ", $rslt->error;

for my $entry ($rslt->entries) {
    my $new_expiration;
    my $old_expiration = $entry->get_value("orghrexpirationdate");
    my $uid = $entry->get_value("uid");

    my $dn = $entry->dn;

    next
      if (defined $old_expiration && $old_expiration =~ /Z$/);

    print "$uid ";

    if (defined $old_expiration) {
	print "$old_expiration ";

	if ($old_expiration =~ /Z$/) {
	    # TODO shortcut, parse gmt time too.
	    # if it's already gmt, don't convert it.
	    $new_expiration = $old_expiration;
	} else {
	    my $year = join '', (split //, $old_expiration)[0..3];
	    my $month = join '', (split //, $old_expiration)[4..5];
	    my $day = join '', (split //, $old_expiration)[6..7];
	    my $old_time = (split/\./, $old_expiration)[1];

	    my ($hour, $min, $sec);
	    if (split (//, $old_time) >5) {
		$hour = join '', (split //, $old_expiration)[9..10];
		$min = join '', (split //, $old_expiration)[11..12];
		$sec = join '', (split //, $old_expiration)[13..14];
	    } else {
		$hour = join '', (split //, $old_expiration)[9];
		$hour = "0" . $hour;
		$min = join '', (split //, $old_expiration)[10..11];
		$sec = join '', (split //, $old_expiration)[12..13];
	    }

	    my $local_time = timelocal($sec,$min,$hour,$day,$month-1,$year);
	    my ($gm_sec,$gm_min,$gm_hour,$gm_day,$gm_month,$gm_year) = gmtime($local_time);
	    $gm_month++;

	    $gm_month = "0" . $gm_month if ($gm_month<10);
	    $gm_day = "0" . $gm_day if ($gm_day<10);

	    $gm_sec = "0" . $gm_sec if ($gm_sec<10);
	    $gm_min = "0" . $gm_min if ($gm_min<10);
	    $gm_hour = "0" . $gm_hour if ($gm_hour<10);

	    my ($exp_year, $exp_month, $exp_day) = Date::Pcalc::Add_Delta_Days($gm_year, $gm_month, $gm_day, 1064);
	    $exp_month = "0" . $exp_month if ($exp_month<10);
	    $exp_day = "0" . $exp_day if ($exp_day<10);
				   
	    $new_expiration = $exp_year+1900 . $exp_month++ . $exp_day . $gm_hour . $gm_min . $gm_sec . "Z";
	}

	print " $new_expiration ";

	# unless (exists $opts{n}) {
	#     my $mod_result = $ldap->modify( $dn, 
	# 				    replace => { orghrexpirationdate => $new_expiration });
	#     $mod_result->code && die "problem modifying: ", $mod_result->error;
	# }


	my $new_rslt = $new_ldap->search(base=>"dc=domain,dc=org", 
				 filter=>"(uid=$uid)",
				 attrs=>["orgAccountExpirationDate", "uid"]);
	$new_rslt->code && die "problem searching: ", $rslt->error;

	my @new_entries = $new_rslt->entries;

	if ($#new_entries != 0) {
	    print " too many/too few entries in new ldap for $uid in new_ldap: $#new_entries ";
	    next;
	} else {
	    my $new_entry = $new_entries[0];
	    my $new_dn = $new_entry->dn;
#	    print $new_entry->dn;

	    my $new_ldap_expiration = $new_entry->get_value("orgAccountExpirationDate");

	    my $days_difference = 0;
# 	    if (defined $new_ldap_expiration && $new_ldap_expiration != "replace") {
# 		if (defined $old_expiration) {
# 		    print " $new_ldap_expiration";
# 		    # my $old_expiration_date = (split (/\./, $old_expiration))[0];
# 		    # my $new_ldap_expiration_date = (split (/\./, $new_ldap_expiration))[0];

# 		    my $old_year = join '', (split(//, $old_expiration))[0..3];
# 		    my $old_mon = join '', (split(//, $old_expiration))[4..5];
# 		    my $old_day = join '', (split(//, $old_expiration))[6..7];

# 		    my $new_year = join '',  (split(//, $new_ldap_expiration))[0..3];
# 		    my $new_mon = join '', (split(//, $new_ldap_expiration))[4..5];
# 		    my $new_day = join '', (split(//, $new_ldap_expiration))[6..7];
		    
# #		    print "\n$old_year/$old_mon/$old_day $new_year/$new_mon/$new_day\n";
# 		    my $days_difference = Delta_Days($old_year, $old_mon, $old_day, $new_year, $new_mon, $new_day);




# 		} else {
# 		    print "\tnew ldap has an expiration ($new_ldap_expiration) but old does not, skipping\n";
# 		    next;
# 		}
# 	    } elsif (!defined $new_ldap_expiration) {
# 		print "\n\tskipping $uid, no new_ldap_expiration!\n";
# 		next;
# 	    }

# 	    if ($days_difference > 90) {
# 		print "\n\tskipping $uid, too much time between expiration dates ($days_difference)\n";
# 		next;
# 	    }

	    print "$new_ldap_expiration " if (defined $new_ldap_expiration);

	    if (defined $new_ldap_expiration && defined $old_expiration && $new_ldap_expiration ne "replace") {
		# my $old_expiration_date = (split (/\./, $old_expiration))[0];
		# my $new_ldap_expiration_date = (split (/\./, $new_ldap_expiration))[0];

		my $old_year = join '', (split(//, $old_expiration))[0..3];
		my $old_mon = join '', (split(//, $old_expiration))[4..5];
		my $old_day = join '', (split(//, $old_expiration))[6..7];

		my $new_year = join '',  (split(//, $new_ldap_expiration))[0..3];
		my $new_mon = join '', (split(//, $new_ldap_expiration))[4..5];
		my $new_day = join '', (split(//, $new_ldap_expiration))[6..7];
		    
#		    print "\n$old_year/$old_mon/$old_day $new_year/$new_mon/$new_day\n";
		$days_difference = Delta_Days($old_year, $old_mon, $old_day, $new_year, $new_mon, $new_day);
	    }

	    if (!defined $old_expiration) {
		print "skipping, no expiration in legacy ldap\n";
	    }

 	    if ($days_difference > 90) {
 		print "skipping,too much time between expiration dates ($days_difference)\n";
 		next;
 	    }

#	    if (!defined $new_ldap_expiration) {
#		print "\tnew ldap has an expiration ($new_ldap_expiration) but old does not, skipping\n";
#		next;
#	    }

 	    if (!defined $new_ldap_expiration) {
 		print "skipping, no new_ldap_expiration!\n";
 		next;
 	    }

	    unless (exists $opts{n}) {
		my $mod_result = $ldap->modify( $dn, 
						replace => { orghrexpirationdate => $new_expiration });
		$mod_result->code && die "problem modifying old ldap: ", $mod_result->error;

		my $new_mod_result = $new_ldap->modify($new_dn,
						       replace => {orgAccountExpirationDate => $new_expiration});
		$new_mod_result->code && die "problem modifying new ldap: ", $new_mod_result->error;
	    }
	    print "success";
	}


    } else {
	print "no_expiration !?";
    }
    
    print "\n";
}



