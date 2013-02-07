#!/usr/bin/env perl

# IST-ISS Co-op Cheng Jie Shi <cjshi@uwaterloo.ca> Jan 2013
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

getopts('i:s:e:f:hv:');

my($command,@output,$ip,$host,$queryhost,$user,$risk,$filename,%config,$debug,$d1,$d2);

my $SYMCalert = 6006; # Probably very site-dependent

if ($opt_h){
   print "Options:\n-i (IP or hostname) - required\n-s, -e - optional start/end dates, format yyyy:mm:dd\n";
   print "-f - optional alternate config file location\n-v - optional - set verbosity/debug level\n";
   exit 0;
}   

$debug = 0;
if(defined $opt_v){
  $debug = $opt_v;
} else {
  $debug = 1;
}

my $input = $opt_i || die "-i argument is required\n";

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

if($input =~ /^[1-2]/){ # -i argument was probably an IPv4 address
  $ip = $input;
  my $foo = inet_aton($input);
  $host = gethostbyaddr($foo,AF_INET) || "Unknown";
} else {
  $ip = gethostbyname($input);
  $host = $input;
}

if($debug > 0){
  print "Input was $input\nHost was $host\nIP was $ip\n";
}

if($opt_f){
	%config = ISSQR::GetConfig($opt_f);
} else {
	%config = ISSQR::GetConfig();
}

$queryhost = $config{hostname};

$command = "/opt/qradar/bin/arielClient -start $d1 -end $d2 -x  \"select * from events where category = $SYMCalert and sourceIP = '$ip'\"";
if($debug > 0){
  print("Command is\n$command\n");
}
@output = sshopen2($queryhost, *READER, *WRITER, $command)|| die "ssh: $!";

foreach my $line (<READER>){
   chomp($line);
   my @currline = split(/[,]+/, $line);
   my $len = $#currline;
   if ($len > 1){
      $risk = substr $currline[4], 11;
      $filename = $currline[6];
      if($currline[6] =~ /SUMMARIZED DATA/){
        $user = substr $currline[17], 6;
        print qq("$ip","$host","$user","$risk","$filename");
        print "\n";
      } else {
        $user = substr $currline[18], 6;
        print qq("$ip","$host","$user","$risk","$filename");
        print "\n";
      }  
   }
}   

close(READER);
close(WRITER);
