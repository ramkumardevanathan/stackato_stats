#!/usr/bin/perl

use JSON;
use Data::Dumper;

use fns;

my $users = fns::decode("stackato users --json");
my $epoch = fns::time_msecs;

print "EPOCH\tuserid\tadmin_role\tapp_count\tallocated_mem_mb\tused_mem_mb\tgroups\n";

foreach my $userhash (@$users) {
	my $useremail = $userhash->{'email'};
	my $admin_role = $userhash->{'admin'};
	my $appsarray = $userhash->{'apps'};
	my $groups = $userhash->{'groups'};
	$groups =~ tr/ /,/;

	my $appcount = scalar (@$appsarray);

	my $mem_info_hash = fns::decode("stackato usage $useremail --json");
	my $allocated_mb = $mem_info_hash->{'allocated'}->{'mem'}/1024;
	my $usage_mb = $mem_info_hash->{'usage'}->{'mem'}/1024;
	if ($admin_role eq "true") {
		$useremail = "admin.".$useremail;
	} elsif ($admin_role eq "false") {
                $useremail = "user.".$useremail;
        }

	if ($ARGV[0] eq "--users") {
		print $epoch."\t".$useremail.
			"\t".$admin_role."\t".$appcount.
			"\t".$allocated_mb."\t".$usage_mb.
			"\t".$groups."\n" if ($admin_role eq "false");
	} elsif ($ARGV[0] eq "--admins") {
		print $epoch."\t".$useremail.
			"\t".$admin_role."\t".$appcount.
			"\t".$allocated_mb."\t".$usage_mb.
			"\t".$groups."\n" if ($admin_role eq "true");
	} else {
		print $epoch."\t".$useremail.
			"\t".$admin_role."\t".$appcount.
			"\t".$allocated_mb."\t".$usage_mb.
			"\t".$groups."\n";
	}
}
