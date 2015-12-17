#!/usr/bin/perl

#Carl Loeffler
#11/8/2015

use strict;
use warnings;

use Cwd;

if(@ARGV != 1){
	print "Usage: ./autobuild <assignment folder>\n";
	exit;
}

my $assignment;
$assignment = $ARGV[0];

opendir(ASSIGNMENT_ROOT, "$assignment") || die "Can't open directory: $!\n";

my $workingDir = getcwd;	#we're going to be moving the working directory around a fair bit later, this is so we can find our way back

while (my $current = readdir(ASSIGNMENT_ROOT)) {
	if($current eq "." || $current eq ".."){
		next;
	}


	if(!opendir(CURRENT_SUB, "$assignment/$current")){
		print "Failed to open directory $current for grading\n";
		next;
	}

	print "\n";

	my $buildTargets = "";	#we're manually building the arguments string for the microsoft compiler
	while(my $f = readdir(CURRENT_SUB)){
		if(-d $f){
			next;
		}
		print "Found file $f in $current";	# we do this by looking at each file in the submission folder
		if( $f =~ m/[.]cpp$/){
			print ", adding file to build targets";	#and just appending it to $buildTargets string if it's a .cpp file
			$buildTargets = "$buildTargets $f";
		}
		print "\n";
	}

	print "attempting to build...\n";
	
	#it's easiest (shortest filepaths in the argument) to run the compiler from the submission directory, so jump there.
	chdir "$assignment/$current/";
	`cl /EHsc $buildTargets > compiler.txt`;	#this is where the magic happens (if you have the environment variables set up right)
	chdir $workingDir;	#and this is where we run away from the magic.

	closedir(CURRENT_SUB);
}
closedir(ASSIGNMENT_ROOT);
