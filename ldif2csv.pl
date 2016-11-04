#!/usr/bin/perl -w
#
$/="";

while (<>) {
    s/\n //;

    my @e = split /\n/;
    my $c=0;

    for (@e) {
	chomp;

	@l=split /:\s+/;

	if (/^dn:/) {
	    $c++;
	    next;
	}

	print "\""
	  if (/\,/);

	if (/::/) {
	    print `echo $l[1] | openssl base64 -d`;
	} else {
	    print $l[1]
	      if (defined $l[1]);
	}

	print "\""
	  if (/\,/);

	print "," if (++$c <= $#e);
    } 

    print "\n"
}
