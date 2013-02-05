#!/usr/bin/env perl

#IST-ISS Co-op Cheng Jie Shi <cjshi@uwaterloo.ca> Jan 2013
#Supervisor: Mike Patterson <mike.patterson@uwaterloo.ca>
use strict;
use warnings;
use Net::SSH qw(sshopen2);
use DateTime;
use Time::Piece;
   
#get input  
my $ip = $ARGV[0];
my $d1 = $ARGV[1];
my $d2 = $ARGV[2];
my (@output,$command);

#start and end date
if($ip && $d1 && $d2){
   $d1 = "$d1"."-00:00:00";
   $d2 = "$d2"."-23:59:59";
   if ($ip =~ /:/){
    $command = "/opt/qradar/bin/arielClient -start $d1 -end $d2 -x  \"select sourceIP, startTime, endTime from events where sourceMAC = '$ip'\"";
    @output = sshopen2('iss-q1-console', *READER, *WRITER, $command)|| die "ssh: $!";      
   }else{
     $command = "/opt/qradar/bin/arielClient -start $d1 -end $d2 -x  \"select sourceMAC, startTime,endTime from events where sourceIP = '$ip' and sourceMAC != '00:00:00:00:00:00'\"";
     @output = sshopen2('iss-q1-console', *READER, *WRITER, $command)|| die "ssh: $!";
  }
}  
#only one date entered
elsif($ip && $d1 && (!$d2)){
   my $d11 = "$d1"."-23:59:59";
   $d1 = "$d1"."-00:00:00";
   if($ip =~ /:/){
    $command = "/opt/qradar/bin/arielClient -start $d1 -end $d11 -x  \"select sourceIP, startTime, endTime from events where sourceMAC = '$ip'\"";
    @output = sshopen2('iss-q1-console', *READER, *WRITER, $command)|| die "ssh: $!"; 
    }else{
     $command = "/opt/qradar/bin/arielClient -start $d1 -end $d11 -x  \"select sourceMAC, startTime,endTime from events where sourceIP = '$ip' and sourceMAC != '00:00:00:00:00:00'\"";
     @output = sshopen2('iss-q1-console', *READER, *WRITER, $command)|| die "ssh: $!";
    }
}
#only ip entered, print result for past 3 days
elsif($ip && (!$d1) && (!$d2)){
    my $currentdate = DateTime->now;
    my $temp= DateTime->now;
    $currentdate = Time::Piece->strptime($currentdate, "%Y-%m-%dT%H:%M:%S");
    $currentdate = $currentdate ->strftime("%Y:%m:%d-%H:%M:%S");
    my $date = $temp->subtract(days => 3);
    $date = Time::Piece->strptime($temp, "%Y-%m-%dT%H:%M:%S");
    $date = $date ->strftime("%Y:%m:%d-%H:%M:%S");
    if($ip =~ /:/){
      $command = "/opt/qradar/bin/arielClient -start $date -end $currentdate -x  \"select sourceIP, startTime, endTime from events where sourceMAC = '$ip'\"";
      @output = sshopen2('iss-q1-console', *READER, *WRITER, $command)|| die "ssh: $!"; 
    }else {
      $command = "/opt/qradar/bin/arielClient -start $date -end $currentdate -x  \"select sourceMAC, startTime,endTime from events where sourceIP = '$ip' and sourceMAC != '00:00:00:00:00:00'\"";
      @output = sshopen2('iss-q1-console', *READER, *WRITER, $command)|| die "ssh: $!";
    }
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
    $start_time = $currline[1];
    $end_time = $currline[2];
    print $mac."   ";
    print converter($start_time);
    print "   ";
    print converter($end_time);
    print "\n";
  }
}
close(READER);
close(WRITER);
