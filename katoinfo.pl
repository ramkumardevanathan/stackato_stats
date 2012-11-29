#!/usr/bin/perl -w

use JSON;
use Data::Dumper;

local $/; #enable slurp mode
open (KCMD, "kato info --json|") or die "Unable to run kato command: $!";

my $json = <KCMD>;
close (KCMD);

my $decoded_json = decode_json ($json);

print Dumper ($decoded_json);
