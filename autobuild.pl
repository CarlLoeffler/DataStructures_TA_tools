#!/usr/bin/perl

#Carl Loeffler
#11/8/2015

use Text::Table;

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

my $tb = Text::Table->new("Folder", "Status", "Note");

while (my $current = readdir(ASSIGNMENT_ROOT)) {
	
	if($current eq "." || $current eq ".."){
		next;
	}

	print "\n$current:\n";
	
	if(!opendir(CURRENT_SUB, "$assignment/$current")){
		print "Failed to open directory $current for grading\n";
		$tb->load([$current, "Failed", "Could not open folder"]);
		next;
	}

	my $foundFolder = "ERR_NONE_FOUND";
	my $foundC = 0;
	while(my $f = readdir(CURRENT_SUB)){
		if(-d $f){
			next;
		}elsif(opendir(TESTHANDLE, "$assignment/$current/$f")){	#this is a hack to deal with -d not working right
			$foundFolder = $f;
			closedir(TESTHANDLE);
		}
		if( $f =~ m/[.]cpp$/){
			$foundC = 1;
		}
	}	

	my $buildTargets = "";	#we're manually building the arguments string for the microsoft compiler
	rewinddir(CURRENT_SUB);
	while(my $f = readdir(CURRENT_SUB)){
		if(-d $f){
			next;
		}
		
		# we do this by looking at each file in the submission folder
		if( $f =~ m/[.]cpp$/){
			print "added $f to build targets\n";	#and just appending it to $buildTargets string if it's a .cpp file
			$buildTargets = "$buildTargets $f";
		}
	}

	print "attempting to build...\n";
	
	#it's easiest (shortest filepaths in the argument) to run the compiler from the submission directory, so jump there.
	chdir "$assignment/$current/";
	`cl /EHsc /Feprogram $buildTargets > compiler.txt`;	#this is where the magic happens (if you have the environment variables set up right)
	my $clReturn = ${^CHILD_ERROR_NATIVE};
	my $status;
	my $folderMessage;
	
	if($clReturn == 0){
		$status = "Success";
	}else{
		$status = "Failed";
	}
	
	if($foundC == 0 && !($foundFolder eq "ERR_NONE_FOUND")){
		$folderMessage = "Auto-unpacked folder found in submission";
	}elsif(!($foundFolder eq "ERR_NONE_FOUND")){
		$folderMessage = "Found folder in submission";
	}elsif($foundC ==0){
		$folderMessage = "Folder contained no source files";
	}else{
		$folderMessage = " ";
	}
	
	$tb->load([$current, $status, $folderMessage]);
	
	chdir $workingDir;	#and this is where we run away from the magic.

	closedir(CURRENT_SUB);
}
closedir(ASSIGNMENT_ROOT);

print $tb;