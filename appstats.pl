#!/usr/bin/perl -w

use JSON;
use Data::Dumper;

use fns;

my $appstats = fns::decode("./getstats.sh $ARGV[0]");

print "instance\tstate\tcores\tdisk_quota\tfds_quota\tmem_quota\tuptime\turi\tcpu_usage\tdisk_usage\tmem_usage\n";

foreach my $stat_hash (@$appstats) {
	my $instance = $ARGV[0]."-". $stat_hash->{"instance"};
	print $instance.": ".$stat_hash->{'state'};
	
}
