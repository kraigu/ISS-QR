#!/usr/bin/env perl

# Based off qr-relaysearch.

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Socket;
use Net::SSH qw(sshopen2);
use vars qw/ $opt_i $opt_s $opt_e $opt_f $opt_h $opt_v/;
use Getopt::Std;
use ISSQR;
use Date::Manip;
use Text::CSV;
use Data::Dumper;

getopts('i:s:e:f:hv:');

my($command,@output,$queryhost,%config,$debug,$d1,$d2);

# QID of event: "Address assigned to session"
my $qid = '3504450';
# might also be 11750388 "IPSec Authentication Succeeded" or 6500666 "IPSec Session Started - Event CRE"

if ($opt_h){
	print "Options:\n-i (user id) - required\n-s, -e - optional start/end dates, format yyyy:mm:dd\n";
	print "-f - optional alternate config file location\n-v - optional - set verbosity/debug level\n";
	exit 0;
}   

$debug = $opt_v || 0;

my $userid = $opt_i || die "user id required\n";

if($opt_s){
	$d1 = $opt_s."-00:00:00";
	} else { 
		$d1 = UnixDate("today","%Y:%m:%d-00:00:00");
}

if($opt_e){
	$d2 = $opt_e."-23:59:59";
} else {
	$d2 = UnixDate("today","%Y:%m:%d-23:59:59");
}

if($debug > 1){
	print "Dates are:\nStart $d1\nEnd $d2\n";
}

if($opt_f){
	%config = ISSQR::GetConfig($opt_f);
} else {
		%config = ISSQR::GetConfig();
}

$queryhost = $config{hostname};

$command = "/opt/qradar/bin/arielClient -start $d1 -end $d2 -f CSV -x \"select * from events where qid = $qid and userName = '$userid'\"";
if($debug > 0){
	print("Command is\n$command\n");
}

@output = sshopen2($queryhost, *READER, *WRITER, $command)|| die "ssh: $!";
my $csv = Text::CSV->new ({binary => 1}) or die "Cannot use CSV: ".Text::CSV->error_diag();
$csv->column_names($csv->getline(*READER));
my $events = $csv->getline_hr_all(*READER);

print "Timestamp\tUserID\tAssigned IP\tSource IP\n";
for my $event (@$events) {
	my $sts = $event->{"startTime"};
	my $stn = 0;
	if($sts){
		$stn = scalar(localtime($sts / 1000));
	}
	my $sip = $event->{"sourceIP"};
	my $dip = $event->{"destinationIP"};
	if($sts && $sip && $dip){
		print "$stn\t$userid\t$sip\t$dip\n";
	}
	if($debug > 2){
		print Dumper($events);
	}
}

close(READER);
close(WRITER);
