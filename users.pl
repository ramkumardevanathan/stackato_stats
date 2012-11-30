#!/usr/bin/perl -w

use JSON;
use Data::Dumper;

sub decode {
	local $/; #enable slurp mode
	my $cmd = shift;
	open (CMD, "$cmd|")
		or die "Unable to run \"$cmd\" command: $!";

	my $json = <CMD>;
	close (CMD);

	return decode_json ($json);
}

my $users = decode("stackato users --json");

print "epoch\tuserid\tadmin_role\tapp_count\tallocated_mem_mb\tused_mem_mb\tgroups\n";

foreach my $userhash (@$users) {
	my $epoch = time;
	my $useremail = $userhash->{'email'};
	my $admin_role = $userhash->{'admin'};
	my $appsarray = $userhash->{'apps'};
	my $groups = $userhash->{'groups'};
	$groups =~ tr/ /,/;

	my $appcount = scalar (@$appsarray);

	my $mem_info_hash = decode("stackato usage $useremail --json");
	my $allocated_mb = $mem_info_hash->{'allocated'}->{'mem'}/1024;
	my $usage_mb = $mem_info_hash->{'usage'}->{'mem'}/1024;

	print $epoch."\t".$useremail.
		"\t".$admin_role."\t".$appcount.
		"\t".$allocated_mb."\t".$usage_mb.
		"\t".$groups."\n";
}
