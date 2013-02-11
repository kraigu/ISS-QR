#!/usr/bin/env perl

#IST-ISS Co-op Cheng Jie Shi <cjshi@uwaterloo.ca> Jan 2013
#Supervisor: Mike Patterson <mike.patterson@uwaterloo.ca>
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Net::SSH qw(sshopen2);
use Date::Manip;
use vars qw/ $opt_i $opt_s $opt_e $opt_f $opt_h/;
use Getopt::Std;
use ISSQR;

getopts('i:s:e:f:h');
   
#get input  
my $ip = $opt_i;
my $d1 = $opt_s;
my $d2 = $opt_e;
my (@output,$command,%config);

if( ($opt_h) || !($opt_i) ){
  print "Options: -i (source IPv4 or MAC address),  -s(start-date, format:yyyy:mm:dd),  -e(end-date, format:yyyy:mm:dd),  -f(config file)\n";
  print "Date argument can be one, two, or none\n";
  print "One date sets date range to that day\nNo dates sets date range to past three days\n";
  exit 0;
}

if($opt_f){
	%config = ISSQR::GetConfig($opt_f);
} else {
	%config = ISSQR::GetConfig();
}

my $host = $config{hostname};

#start and end date
if($ip && $d1 && $d2){
  $d1 = "$d1"."-00:00:00";
  $d2 = "$d2"."-23:59:59";
}elsif($ip && $d1 && (!$d2)){
  my $temp = $d1;
  $d1 = "$temp"."-00:00:00";
  $d2 = "$temp"."-23:59:59";
}elsif($ip && (!$d1) && (!$d2)){
  $d1 = UnixDate("-3d","%Y:%m:%d-00:00:00");
  $d2 = UnixDate("today","%Y:%m:%d-23:59:59");
}

print "Search from $d1 to $d2\n";
 
if ($ip =~ /:/){
    $command = "/opt/qradar/bin/arielClient -start $d1 -end $d2 -x  \"select sourceIP, startTime, endTime from events where sourceMAC = '$ip'\"";
    @output = sshopen2($host, *READER, *WRITER, $command)|| die "ssh: $!";      
}else{
    $command = "/opt/qradar/bin/arielClient -start $d1 -end $d2 -x  \"select sourceMAC, startTime,endTime from events where sourceIP = '$ip' and sourceMAC != '00:00:00:00:00:00'\"";
    @output = sshopen2($host, *READER, *WRITER, $command)|| die "ssh: $!";
  }
  
#time converter
my ($mac,$start_time,$end_time,$time,$ele);
sub converter{
  $time = $_[0]/1000;
  my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
  my ($sec, $min, $hour, $day,$month,$year) = (localtime($time))[0,1,2,3,4,5]; 
  return $months[$month]." ".$day.", ".($year+1900)." ".$hour.":".$min.":".$sec;
}

#read and print
foreach my $line (<READER>){
  chomp($line);
  my @currline = split(/\|/, $line);
  my $x = shift(@currline);
  if (@currline && (not($currline[0] =~ /source/))){  
    $mac = $currline[0];
    $mac =~ s/\s//;
    $start_time = converter($currline[1]);
    print "$mac\t$start_time\n";
  }
}
close(READER);
close(WRITER);