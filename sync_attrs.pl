#!/usr/bin/perl -w
#
# set values in one ldap based on values in another ldap.  
#
# Values hardcoded, needs work.

use strict;
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

#my @attrs = qw/zimbraaccountstatus zimbramailstatus zimbrahideingal:empty=false/;
my @attrs = qw/zimbraaccountstatus zimbramailstatus zimbrahideingal/;
my @desired_values = qw/active enabled FALSE/;


my $ldap = Net::LDAP->new("ldaps://ldap.domain.org") || die "$@";
my $bind_rslt = $ldap->bind("cn=directory manager", password=>"pass");
$bind_rslt->code && die "problem binding: ", $bind_rslt->error;

my $new_ldap = Net::LDAP->new("ldap://mldap03.domain.org") || die "$@";
my $new_bind_rslt = $new_ldap->bind("cn=config", password=>"pass");
$new_bind_rslt->code && die "problem binding to new ldap: ", $bind_rslt->error;

my $rslt = $ldap->search(base=>"dc=domain,dc=org", 
			 filter=>"(&(objectclass=orgemployee)(orgaccountactive=TRUE))",
			 attrs=>["uid","orgaccountactive"]);
$rslt->code && die "problem searching: ", $rslt->error;

for my $entry ($rslt->entries) {
    my $uid = $entry->get_value("uid");


    # not working but +/- what it should look like
    # my $k = 0;
    # for (@attrs) {
    # 	if ($attrs[$j] =~ /:/) {
    # 	    my ($lhs, $rhs) = split (/:/, $desired_values[$j]);
    # 	    print "colon $lhs $rhs\n";
    # 	    if ($rhs =~ /=/) {
    # 		my ($e_lhs, $e_rhs) = split (/=/, $rhs);
    # 		print "equals: $e_lhs $e_rhs\n";
    # 		if ($e_lhs =~ /empty/) {
    # 		    if ($e_rhs =~ /true/) {
    # 			# drop through to comparison below
    # 			$current_values[$i] = "false";				    
    # 		    } elsif ($e_rhs =~ /false/) {
    # 			$current_values[$i] = "false";
    # 		    } else {
    # 			die "lhs of '=' in $desired_values[$i] must be true or false";
    # 		    }
    # 		} else {
    # 		    die "lhs of '=' in $desired_values[$i] can only be 'empty'";
    # 		}
    # 	    } else {
    # 		die "$desired_values[$i] includes a ':' without an '='";
    # 	    }
    # 	}
    # }



    my $dn = $entry->dn;
	my $new_rslt = $new_ldap->search(base=>"", 
				 filter=>"(&(uid=$uid)(objectclass=zimbraaccount))",
#				 attrs=>["objectclass", "uid", "zimbraaccountstatus", "zimbramailstatus", "zimbrahideingal"]);
				 attrs=>["objectclass", "uid", @attrs]);
	$new_rslt->code && die "problem searching: ", $new_rslt->error;

	my @new_entries = $new_rslt->entries;

	if ($#new_entries != 0) {
	    print "too many/too few entries in new ldap for $uid in new_ldap: $#new_entries\n";
	    next;
	} else {
	    my $new_entry = $new_entries[0];
	    my $new_dn = $new_entry->dn;

	    # my $accountstatus = $new_entry->get_value("zimbraaccountstatus");
	    # my $mailstatus = $new_entry->get_value("zimbramailstatus");
	    # my $hideingal = $new_entry->get_value("zimbrahideingal");

	    my @current_values;
	    my $i=0;
	    for my $attr (@attrs) {
		$current_values[$i] = $new_entry->get_value($attr);
		$current_values[$i] = "" 
		  if (!defined $current_values[$i]);
		$i++
	    }


#	    unless ($accountstatus eq "closed" && $mailstatus eq "disabled" && $hideingal eq "TRUE") {
	    my $mismatch = 0;
	    my $j=0;
	    for (@desired_values) {
		if ($attrs[$j] =~ /zimbrahideingal/) {
		    if ($current_values[$j] =~ /^\s*$/) {
			$current_values[$j] = "FALSE";
		    }
		}
		
		if (lc $desired_values[$j] ne lc $current_values[$j]) {
		    $mismatch = 1
		}

		$j++
	    }
	      
	    if ($mismatch) {
#		print "$uid,$accountstatus,$mailstatus,";
		print "$uid,";
		for my $value (@current_values) {
		    print $value . ",";
		}
#		print $hideingal if (defined $hideingal);
	    
		unless (exists $opts{n}) {
		    # my $new_mod_result = $new_ldap->modify($new_dn,
		    # 					   replace => {"zimbraaccountstatus" => "closed",
		    # 						       "zimbramailstatus" => "disabled",
		    # 						       "zimbrahideingal" => "TRUE"
		    # 						      },
		    # 				      );
		    # $new_mod_result->code && die "problem modifying new ldap: ", $new_mod_result->error;
		    # print " successfully modified";
		}
		print "\n";
	    }
	    

	}
}
