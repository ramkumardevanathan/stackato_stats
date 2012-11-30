#!/usr/bin/perl

use JSON;
use Data::Dumper;

use fns;

my $users = fns::decode("stackato users --json");

print "EPOCH\tappinstance\tuser\turi\tquota\tused\n";

foreach my $userhash (@$users) {
	my $epoch = fns::time_msecs;
	my $useremail = $userhash->{'email'};
	my $admin_role = $userhash->{'admin'};
	my $appsarray = $userhash->{'apps'};
	my $groups = $userhash->{'groups'};
	$groups =~ tr/ /,/;

	my $appcount = scalar (@$appsarray);

	my $mem_info_hash = fns::decode("stackato usage $useremail --json");
	my $allocated_mb = $mem_info_hash->{'allocated'}->{'mem'}/1024;
	my $usage_mb = $mem_info_hash->{'usage'}->{'mem'}/1024;

	print $epoch."\t".$useremail.
		"\t".$admin_role."\t".$appcount.
		"\t".$allocated_mb."\t".$usage_mb.
		"\t".$groups."\n";
}
