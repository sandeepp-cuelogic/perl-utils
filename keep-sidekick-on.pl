#!/usr/bin/perl -w

#use strict;
use warnings;

use File::chdir; #provides $CWD variable for manipulating working directory

print "Current dir: $CWD \n";

$check = "sidekiq 3.4.2 foundly";

#$running = system("ps -aux | grep \"$check\"");

while(true)
{
	$running = `ps -aux | grep "$check"`;
	$arr = split(/ubuntu/,$running);

	print "Sidekiq related processes: $arr\n";

	if($arr > 3){
		$checktime = localtime();
		print("\nSidekiq working fine!! ($checktime)\n");
		sleep(300);
	}	
	else{
		$restarttime = localtime();
		print ("\n !!!! SIDEKIQ FOUND DEAD !!!\n$restarttime \nCurrently running processes:\n$running\nRestarting again....");
		#chdir into download directory
		#this action is local to the block (i.e. {})
		local $CWD = '/var/html/foundly/foundlyprod/foundly/';
		system "bundle exec sidekiq -d -L sidekiq.log  -e production";
	  	die "Could not start sidekiq $!" if ($?);
		#print (`ls`);
		#Writing logs to file
		#sleep(45); 
		print "restarted, writing logs...";
		sleep(45);
		$restarttime = localtime();
		my $filename = 'keep-sidekiq-on.log';
		open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
		print $fh "\n--------------------------------------------------------------";
		print $fh "\nSidekiq found dead :(! \nSidekiq restarted on : $restarttime\n";
		print $fh "\n--------------------------------------------------------------\n";
		close $fh;
		print ("\nWaiting for sidekiq to start....");
		sleep(45);
		print "done!!\n";
	}	
}
