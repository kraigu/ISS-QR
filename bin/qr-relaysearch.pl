#!/usr/bin/env perl

# IST-ISS Co-op Cheng Jie Shi <cjshi@uwaterloo.ca> Jan 2013
# and Co-Op Davidson Marshall <damarsha@uwaterloo.ca> Nov 2013
# Supervisor: Mike Patterson <mike.patterson@uwaterloo.ca>

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

# QID of event: Relay Event - Event CRE
my $qid = '6501068';

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

print "Timestamp\tUserID\tSourceIP\tLogged Payload\n";
for my $event (@$events) {
  my $st = $event->{"startTime"};
	my $sip = $event->{"sourceIP"};
  my $payload = $event->{"payload"};
  if($st){
  	print "$st\t$userid\t$sip\t$payload\n";
  }
  if($debug > 2){
    print "\n--- events\n";
    print Dumper($events);
    print "\n--- end events\n";
  }
}

close(READER);
close(WRITER);
