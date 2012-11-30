package fns;

use JSON;

require Exporter;
use vars       qw($VERSION @ISA @EXPORT);
use POSIX;
use Config;

# set the version for version checking
$VERSION     = 0.01;
@ISA         = qw(Exporter);


sub decode {
        local $/; #enable slurp mode
        my $cmd = shift;
        open (CMD, "$cmd|")
                or die "Unable to run \"$cmd\" command: $!";

        my $json = <CMD>;
        close (CMD);

        return decode_json ($json);
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
        my $password  = shift;
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