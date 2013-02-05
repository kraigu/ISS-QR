#!/usr/bin/env perl

#IST-ISS Co-op Cheng Jie Shi <cjshi@uwaterloo.ca> Jan 2013
#Supervisor: Mike Patterson <mike.patterson@uwaterloo.ca>

use strict;
use warnings;
use Socket;
use Net::SSH qw(sshopen2);

my($command, @output,$ip, $host,$user,$risk,$filename);
my $input = $ARGV[0];
my $d1 = $ARGV[1];
my $d2 = $ARGV[2];

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

$command = "/opt/qradar/bin/arielClient -start $d1 -end $d2 -x  \"select * from events where category = 6006 and sourceIP = '$ip'\"";
@output = sshopen2('iss-q1-console', *READER, *WRITER, $command)|| die "ssh: $!"; 

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

