package ISSRT::ConConn;

our @EXPORT_OK = qw(GetConfig config);

use strict;
use warnings;

use Config::General;
use Data::Dumper;

my $debug = 0;

sub GetConfig{
	my $configfile = qq|$ENV{"HOME"}/.qr|;
	if($_[0]) {
		$configfile = $_[0];
	}
	if( ! -e $configfile){ 
		die "\n$configfile does not exist\n";
	}
	my $perms = sprintf("%o",(stat($configfile))[2] & 07777);
	if($debug > 3){ print "Permissions on rc file: " . Dumper($perms); }
	die "\nConfig file must not have any more than owner rw\n"
		unless ($perms == '600' || $perms == '0400');

	my $conf = new Config::General($configfile);
	my %config = $conf->getall;
	if($debug > 3){ print "Config is: \n" . Dumper(\%config) . "\n"; }
	die "\nNo hostname!\n" unless $config{hostname};
	return %config;
}

1;