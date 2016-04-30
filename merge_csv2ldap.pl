#!/usr/bin/perl -w
#

use strict;
use Net::LDAP;
use Data::Dumper;
use Getopt::Std;

sub print_dn($);
sub print_usage();

my %opts;
getopts ('o:f:i:r', \%opts);

my $outfile = $opts{o} || print_usage();
my $field_names = $opts{f} || print_usage();

my $index_field;
if (exists $opts{i}) {
    $index_field = $opts{i};
} else {
    $index_field = "uid";
}

if ($field_names !~ /,/) {
    print "-f <fields> must be comma separated\n";
    exit;
}

my @field_names = split /\s*,\s*/, $field_names;

open (my $out, '>', $outfile) || die "can't open $outfile";

my $ldap = Net::LDAP->new("ldap.domain.org");
my $r = $ldap->bind(dn=>"uid=morgan,ou=employees,dc=domain,dc=org", password=>"pass");
$r->code && die "unable to bind to ldap: ", $r->error;

my %role_hash;
my $field_count = $#field_names + 1;

my $i=0;
my $user_index;
for (@field_names) {
    $user_index = $i if (/^$index_field$/);
    $i++
}

while (<>) {
    my @fields = split /,/;

    if (!defined($user_index)) {
	print "one of your fields must be index field $index_field.\n";
	exit;
    }

    chomp $fields[$user_index];

    my $user = $fields[$user_index];

    my $j = 0;
    for (@fields) {
	chomp $fields[$j];
	if ($user_index == $j || $j >= $field_count) { # skip the field containing the index
	    $j++;
	    next;
	}

	my $value_found = 0;

	if (exists $role_hash{$fields[$user_index]}) {
	    for (@{$role_hash{$fields[$user_index]}{lc $field_names[$j]}}) {
		$value_found = 1 if (lc $fields[$j] eq $_);
	    }
	}
	next if ($value_found);

	if ($field_names[$j] =~ /orgrolemdc/i) {
	    $fields[$j] =~ s/"//;
	    $fields[$j] =~ s/^([a-zA-Z0-9]+)\s+.*/$1/;
	}

	push @{$role_hash{$fields[$user_index]}{lc $field_names[$j]}}, $fields[$j] unless
	  grep (/$fields[$j]/i, @{$role_hash{$fields[$user_index]}{lc $field_names[$j]}});

	$j++;
    }

}


for my $index (keys %role_hash) {
    chomp $index;

    my $sr = $ldap->search(base=>"dc=domain,dc=org", 
			   filter=>"$index_field=$index");
    $sr->code && die $sr->error;

    my $href = $sr->as_struct;

    my $dn = (keys %$href)[0];
    
    if (!defined $dn) {
	print "no ldap record for /$index_field=$index/\n"
	    if ($index !~ /^\s*$/);
	next;
    }
    
    if (!defined $href->{$dn}->{objectclass}) {
	print "no objectclass for $dn?!\n";
	next;
    }

    my $dn_printed = 0;
    # if (!grep(/orgrole/i, @{$href->{$dn}->{objectclass}})) {
    # 	print_dn($dn) unless ($dn_printed);
    # 	print $out "add: objectclass\nobjectclass: orgRole\n";
    # 	$dn_printed = 1;
    # }

    for my $attr (keys %{$role_hash{$index}}) {
	for my $value (@{$role_hash{$index}{$attr}}) {
	    if (exists $href->{$dn}->{$attr}) {
		$value =~ s/\+/\\\+/;
		$value =~ s/\*/\\\*/;
		if (!grep /^$value$/, @{$href->{$dn}->{$attr}}) {
		    if ($dn_printed) {
			print $out "-\n";
		    } else {
			print_dn($dn) 
		    }
		    if (exists $opts{r}) {
			print $out "replace: $attr\n$attr: $value\n";
		    } else {
			print $out "add: $attr\n$attr: $value\n";
		    }
		    $dn_printed = 1;
		}
	    } else {
		if ($dn_printed) {
		    print $out "-\n";
		} else {
		    print_dn($dn) 
		}
		print $out "add: $attr\n$attr: $value\n";
		$dn_printed = 1;
	    }
	}
    }
    print $out "\n" if $dn_printed
}

sub print_dn ($) {
    my $dn = shift;
    
    print $out "dn: $dn\nchangetype: modify\n";
}

sub print_usage() {
    print "\nusage: cat input.csv | $0 -o output.ldif -f <fields> [-i <index field>] [-r]\n";
    print "\t-f <fields> comma separated list of fields.\n";
    print "[-r] replace (rather than add)\n";
    print "\t\tOne must be user to link to an account\n";

    
#    print "\t-0 add leading zeros to empids\n";
    exit;
}
