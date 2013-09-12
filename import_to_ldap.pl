#!/usr/bin/perl -w
#

use strict;
use Net::LDAP;
use Getopt::Std;
use Data::Dumper;

my $buf='';

my %opts;
getopts('H:D:f:b:y:w:sn', \%opts);

exists $opts{D} || print_usage();
exists $opts{b} || print_usage();
(exists $opts{y} || exists $opts{w}) || print_usage();

my $pass;
if (exists $opts{y}) {
    open (IN, $opts{y}) || die "can't open $opts{y}";
    $pass = <IN>;
    chomp $pass;
} else {
    $pass = $opts{w};
}

my @attrs = @ARGV
  if ($#ARGV>-1);

@ARGV = ();

my $ldap=Net::LDAP->new($opts{H}) || die "$@";

my $bind_rslt = $ldap->bind($opts{D}, password=>$pass);
$bind_rslt->code && die "problem binding: ", $bind_rslt->error;

while (<>) {
    chomp;

    my @import_values = split /,/;
    if ($#attrs != $#import_values) {
	print "wrong number of values: /$_/ ", $#attrs+1, " passed on the command line, ", $#import_values+1, " in ldap.  skipping.\n";
	next;
    }


    my $rslt = $ldap->search(base=>$opts{b}, filter=>"($attrs[0]=$import_values[0])", attrs=>[@attrs]);
    $rslt->code && die "problem searching: ", $rslt->error;

    my $entry = ($rslt->entries)[0];
    if (!defined $entry) {
	print "$attrs[0]=$import_values[0] returned no account, skipping.\n";
	next;
    }

    my $dn = $entry->dn;

    for (my $i=1; $i<=$#attrs; $i++) {
	my $ldap_value = ($entry->get_value($attrs[$i]))[0];
#	if (!defined $ldap_value || $ldap_value ne $import_values[$i]) {
	if (!defined $ldap_value) {
	    print "replace $dn, ", $attrs[$i], "=>", $import_values[$i], "\n";
	    if (!exists $opts{n}) {
		my $mod_result = $ldap->modify($dn,
					       add => { $attrs[$i] => [ $import_values[$i] ] }
					      );
		$mod_result->code && die "modify failed: ", $mod_result->error;
	    }
	}

    }
}

exit;
# if ($#attrs < 0) {
#     print "please specify attributes.\n";
#     print_usage();
# #    my $rslt = $ldap->search(base=>$opts{b}, filter=>$opts{f});
# } else {
#     my $rslt = $ldap->search(base=>$opts{b}, filter=>$filter, attrs=>[@attrs]);
#     $rslt->code && die "problem searching: ", $rslt->error;
    
#     for my $entry ($rslt->entries) {
# 	my @values;
# 	for my $attr (@attrs) {
# 	    push @values, ($entry->get_value($attr))[0];
# 	}
# 	my $skip_entry = 0;

# 	for my $v (@values) {
# 	    $skip_entry = 1
# 	      if ($v =~ /^\s*$/ && exists $opts{s});
# 	}
# 	if (!$skip_entry) {
# 	    for (my $i=0; $i<=$#values; $i++) {
# 		print $values[$i];
# 		print " "
# 		  unless ($i == $#values);
# 	    }
# 	    print "\n";
# 	}

#     }
# }


sub print_usage {
    print "usage: $0 [-s] [ -D binddn -b basedn -y passfile || -w pass\n\n";
    print "\t-b basedn base to import data into\n";
    print "\t-s skip entire entry if attributes are empty\n";
    exit;
}
