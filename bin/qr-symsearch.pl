#!/usr/bin/env perl

#IST-ISS Co-op Cheng Jie Shi <cjshi@uwaterloo.ca> Jan 2013
#Supervisor: Mike Patterson <mike.patterson@uwaterloo.ca>
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Socket;
use Net::SSH qw(sshopen2);
use vars qw/ $opt_i $opt_s $opt_e $opt_f $opt_h/;
use Getopt::Std;
use ConConn;

getopts('i:s:e:f:h');

my($command, @output,$ip, $host,$user,$risk,$filename,%config);
my $input = $opt_i;
my $d1 = $opt_s;
my $d2 = $opt_e;
if ($opt_h){
   print "Options: -i (IP or hostname), -s(start-date), -e(end-date), -f(config file)\n";
   
}else{
if (not ($input =~ /^[0-9]/)){
   $host = $input; 
   $ip = gethostbyname($input);
	if(defined $ip){           
	$ip = inet_ntoa($ip);  	
        }
}
if($input =~ /^[0-9]/){
    $ip = $input;
    my $foo = inet_aton($input);
    $host = gethostbyaddr($foo,AF_INET) || "Unknown";
}
if($opt_f){
	%config = ISSRT::ConConn::GetConfig($opt_f);
} else {
	%config = ISSRT::ConConn::GetConfig();
}

my $host = $config{hostname};
$command = "/opt/qradar/bin/arielClient -start $d1 -end $d2 -x  \"select * from events where category = 6006 and sourceIP = '$ip'\"";
@output = sshopen2($host, *READER, *WRITER, $command)|| die "ssh: $!"; 

foreach my $line (<READER>){
   chomp($line);
   my @currline = split(/[,]+/, $line);
   my $len = $#currline;
   if ($len > 1){
      $risk = substr $currline[4], 11;
      $filename = $currline[6];
      if($currline[6] =~ /SUMMARIZED DATA/){
         $user = substr $currline[17], 6;
         print qq("$ip" , "$host" , "$user" , "$risk", "$filename");
         print "\n";
      }else{
         $user = substr $currline[18], 6;
         print qq("$ip" , "$host" , "$user" , "$risk", "$filename");
         print "\n";
      }   
   }
   
}   
close(READER);
close(WRITER);
}