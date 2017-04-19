#!/usr/bin/perl -w
#
# for i in *gz; do echo $i ; done 2>&1 | tee  -a unnest.out
# convert errorstst-20170406.gz-20170408.gz-20170410.gz-20170412.gz-20170414.gz-20170416.gz-20170418.gz to errorstst-20170406.gz
# from a botched logrotate config
# This was a one-time use script so has limited testing and isn't terribly efficient.

use strict;
while (<>) {
    my $f = $_;
    chomp $f;
    while ($f !~ /^[^-]+\-........\.gz$/) {
	print "gunzip $f\n";
	system "gunzip $f";
	$f =~ s/\.gz$//;
	my $f2 = $f;
	$f2 =~ s/\-........$//;
	print "mv $f $f2\n";
	system "mv $f $f2";
	$f = $f2;
    }
}
