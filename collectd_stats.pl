#!/bin/perl

use POSIX;
use Getopt::Std;

use Data::Dumper;
use Text::CSV_XS;

# fetch data from csv files
# in collectd csv folder
# in last 2 minutes
sub setcsvHome {
	$csvhome = shift;
}

sub setDomain {
	$domain = shift;
}

sub setInterval {
	my $t = shift;
	if ($t =~ /[1-5]+m/) {
		$interval = $t;
	} else {
		warn("Interval higher than 5-minutes not supported");
		$interval = "5m";
	}
}	

sub mintoepoch {
	my $mins = shift;
	if ($mins<0) {return -1;}
	my $cursecs = localtime;
	return time - $mins*60;
}

sub getepochstart {
	$argme = shift;

	if ($argme =~ /[0-9]+m/) { $epoch_start = mintoepoch($argme) };

	$date_start = strftime ("%Y-%m-%d", localtime ($epoch_start));
	$date_end = strftime ("%Y-%m-%d", localtime);

	return $epoch_start;
}

sub getHosts {
	opendir (DIR, $csvhome) || die "Unable to open $csvhome: $!";
	my @dircontents = grep { !/^\.{1,2}$/ } readdir (DIR);
	closedir (DIR);
	# @dircontents = map { $csvhome . '/' . $_ } @dircontents;

	return @dircontents;
}

sub printHosts {
	my @hosts = getHosts($csvhome);
	foreach (@hosts) {
		if (-d $csvhome.'/'.$_) {print $_, "\n";}
	}
	return 0;
}


sub getMetricFilesPerHost {
	my $host = shift;
	my $metric = shift;

	my @mfiles=();
	  my $focusdir = $csvhome."/".$host;

	  if (-d $focusdir) {
	    $epoch_start = getepochstart($interval);
	    my $mfile_start = $focusdir . "/" . $metric . "-" . $date_start ;
	    push (@mfiles, $mfile_start);
	    if ($date_start ne $date_end) {
		my $mfile_end = $focusdir . "/" . $metric . "-" . $date_end ;
		push (@mfiles, $mfile_end);
	    }
	  } else {
		warn "Invalid/unknown host $_";
	  }
	return @mfiles;
}

sub fetchfromCSV {
	my @csvfiles = shift;
	my %time_rows = ();

	foreach (@csvfiles) {
	   my $csv = Text::CSV_XS->new ({ binary => 1 }) or
			die "Cannot use CSV: ".Text::CSV->error_diag ();
	   my $linect = 1;

	   open (my $fh, "<", $_) or warn "Unable to open $_: $!";
	   while (my $row = $csv->getline ($fh)) {
	    if ($linect == 1) {
		$linect++;
		$time_rows{"headings"} = $row;
	    } else {
		if ($row->[0] >= $epoch_start) {
			my $epoch = shift @$row;
			# handle delays in logging by rounding off epoch to nearest 10
			$time_rows{$epoch -($epoch % $collectd_secs)} = $row;
		}
	    }
	 }
	}
	return (\%time_rows);
}

sub makebusfilename {
	my $hname = shift;
	return $domain.'$!'.$hname.".bus";
}

sub getConfig {
	open (CFGSH,"./getsyscfg.sh|") or die "Unable to execute getsyscfg.sh: $!";
	my %cfghash = ();
	while (<CFGSH>) {
		chomp;
		my @fields = split / +/;
		$cfghash{$fields[0]} = $fields[1];
	}
	close (CFGSH);
	return (\%cfghash);
}

sub writeToFlatFileBusfmt {
	my $hash_ref = shift;
	my $cfghash_ref = getConfig;
	my $metric_count = 0;

	my $busfile = makebusfilename ($hash_ref->{"hostname"});

	open (BUS, ">$busfile") or die "Unable to open file $busfile for writing: $!";

	# Write in the headings/metric names first
	my $epoch_printed = 0;
	foreach my $metric (@metrics) {

	 my $harray = $hash_ref->{$metric}->{'headings'};
	 $metric_count += scalar (@$harray);

	 my ($obj,$mshort) = split (/\//,$metric);
	 $mshort =~ tr/-/_/;
	 if ($epoch_printed == 0) {
		$harray->[0] = qw/EPOCH/ if ($harray->[0] == qw/epoch/);
		$epoch_printed++;
	 } else {
		# remove 'epoch' metric from array
		# always first element in array
		shift(@$harray) if (lc($harray->[0]) == qw/epoch/);
		$harray->[0] = $mshort."_".$harray->[0];
	 }

	 if (scalar(@$harray) > 1) {
	  print BUS join("\t".$mshort."_", @$harray), "\t";
	 } else {
	  print BUS $harray->[0], "\t";
	 }
	} # foreach my $metric

	print BUS join("\t", keys $cfghash_ref);
	print BUS "\n";
	 $metric_count += scalar (keys $cfghash_ref);

	# write in the data next
	my %hostdata;
	foreach my $metric (@metrics) {
	  my $metric_values = $hash_ref->{$metric};
	  if (!scalar keys %hostdata) { %hostdata = %$metric_values; }
	  else {
	    foreach my $key ( keys %$metric_values ) {
		if (exists $hostdata{ $key }) {
			my $temp = delete $hostdata{$key};
			push @{ $hostdata{$key} }, @$temp, @{ $metric_values->{$key} };
		} else {
			$hostdata{$key} = $metric_values->{$key};
		}
		if ($metric eq $metrics[$#metrics]) {
			push @{ $hostdata{$key} }, values %$cfghash_ref;
		}
	    }
	 }
	}
	foreach my $key (sort keys %hostdata) {
		print BUS join("\t", $key."000", @{ $hostdata{$key} }) unless ($key eq "headings");
		print BUS "\n" unless ($key eq "headings");
	}
	close (BUS);
}



my %options = (); # hash to store command-line options

$domain = "";
$date_start = "";
$date_end = "";

$epoch_start = "";
$epoch_end = "";;

$csvhome = "";
$interval = "";

$collectd_secs = 10;

@metrics = ("load/load", "cpu-0/cpu-idle", "memory/memory-used", "memory/memory-free");

setDomain ("CONTROLLER");

getopts("i:c:", \%options);
if (defined $options{i}) {
	setInterval($options{i});
} else {
	setInterval("1m");
}

if (defined $options{c}) {
	setcsvHome($options{c});
} else {
	setcsvHome("/var/lib/collectd/csv");
}

@allhosts = getHosts;
foreach (@allhosts) {
  my %hashmaster = ();
  my $the_host = $_;
  $hashmaster{"hostname"} = $the_host;
  foreach (@metrics) {
   my $the_metric = $_;
   my @csvfiles = getMetricFilesPerHost($the_host, $the_metric);;

   my ($d) = fetchfromCSV (@csvfiles);
   $hashmaster{$the_metric} = $d;
	
  }

  writeToFlatFileBusfmt(\%hashmaster);
}

