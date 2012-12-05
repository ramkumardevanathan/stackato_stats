package fns;

use JSON;

require Exporter;
use vars       qw($VERSION @ISA @EXPORT);
use POSIX;
use Config;

# set the version for version checking
$VERSION     = 0.01;
@ISA         = qw(Exporter);

# sub json_pp {
	# my $json_slurp_str = shift;
	# open (J2P, "
%secret = (
		qw/ramd@hp.com/ => qw/1iso*help/,
		qw/thiyagu@hp.com/ => qw/1thiyagu/,
		qw/u1@hp.com/ => qw/u12345/,
		qw/u2@hp.com/ => qw/u23456/
	);

sub roundn10 {
        my $n = shift;

        # if (($n % 10) ge 5) {
                # return $n + 10 - ($n % 10);
        # } else {
                return $n - ($n % 60);
        # }
}

sub decode {
        local $/; #enable slurp mode
        my $cmd = shift;
        open (CMD, "$cmd|")
                or die "Unable to run \"$cmd\" command: $!";

        my $json = <CMD>;
        close (CMD);

        return decode_json ($json);
}

sub time_msecs {
        my $epoch = time;
	$epoch = roundn10 ($epoch);
	$epoch = $epoch."000"; # msecs adjustment required for java code to handle datetime
	return $epoch;
}

sub chklogin {
        my $current_user;
        open (STAU,"stackato user|") or die "Unable to run \"stackato user\" command";
        while (<STAU>) {
                chomp;
                if (/^$/) { next; }
                if (/^\[(.*)\]$/) { $currentuser = $1; last; }
        }
        close (STAU);
        return $currentuser;
}

sub login {
        my $useremail = shift;
        my $password  = $secret{$useremail};
        my $group = shift;

        if (chklogin eq $useremail) { return 0; }
        if ($group eq "") {
                system ("stackato login --email $useremail --password $password");
        } else {
                system ("stackato login --email $useremail --password $password --group $group");
        }
        return $?;
}

sub logout {
        system ("stackato logout");
        return $?;
}

1;
