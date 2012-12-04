#!/usr/bin/perl -w

use JSON;
use Data::Dumper;

use fns;

my $appstats = fns::decode("./jsonfix.sh $ARGV[0]");
my $username = fns::chklogin;
my $epoch = fns::time_msecs;

print "EPOCH\tinstance\tstate\tcores\tdisk_quota\tfds_quota\tmem_quota\tuptime\tcpu_usage\tdisk_usage\tmem_usage\turis\n";

foreach my $apphash (@$appstats) {
	my $sref = $apphash->{"stats"};
	my $uref = $sref->{"usage"};
	my $instance = $sref->{"name"}.
			"-". $apphash->{"instance"}; # get env-0
	print $epoch."\t".
		$username.".".$instance."\t".
		$apphash->{'state'}."\t".
		$sref->{"cores"}."\t".
		$sref->{"disk_quota"}."\t".
		$sref->{"fds_quota"}."\t".
		$sref->{"mem_quota"}."\t".
		$sref->{"uptime"}."\t".
		$uref->{"cpu"}."\t".
		$uref->{"disk"}."\t".
		$uref->{"mem"}."\t".
		join(",",@{$sref->{"uris"}})."\n";
}
