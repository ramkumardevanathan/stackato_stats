#!/usr/bin/perl -w

use JSON;
use Data::Dumper;

use fns;

my $users = fns::decode("stackato users --json");

foreach my $userhash (@$users) {
	my $useremail = $userhash->{'email'};
	my $appsarray = $userhash->{'apps'};

	my @applist;
	foreach my $apphash (@$appsarray) {
		push (@applist, $apphash->{'name'});
	}

	print $useremail,"\t",join(",",@applist), "\n";
}
