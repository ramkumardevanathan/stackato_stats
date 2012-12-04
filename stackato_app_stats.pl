#!/usr/bin/perl

use JSON;
use Data::Dumper;

use fns;

my $users = fns::decode("stackato users --json");

foreach my $userhash (@$users) {
	my $epoch = fns::time_msecs;
	my $useremail = $userhash->{'email'};
	my $appsarray = $userhash->{'apps'};

	foreach my $apphash (@$appsarray) {
		my $app = $apphash->{"name"};
		fns::login ($useremail);
		open (ASPL, "perl appstats.pl $app|") or die ("unable to run appstats.pl: $!");

		my $firstline="";
		while (<ASPL>) {
		  my $line = $_;
		  if ($firstline eq "") {
		    $firstline = $_;
		    next;
		  }
		  my @parts = split (/\t/, $line);
		  my $busfilename = 
			"APP_INSTANCE\$!".$parts[1].".bus";
		  open (BUS,">".$busfilename)
			or die ("Unable to open file for writing");
		  print (BUS $firstline);
		  print (BUS $line);
		  close (BUS);
		}

		close (ASPL);
	}
}
