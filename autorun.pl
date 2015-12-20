#!/usr/bin/perl

#Carl Loeffler
#11/8/15

use Text::Table;

use strict;
use warnings;

use Cwd;

if(@ARGV != 3){
	print "Usage: ./autorun.pl <assignment directory> <sample input directory> \"<diff flags>\"\n";
	exit;
}

my $assignment;
my $inputDir;
my $diffArgs;
$assignment = $ARGV[0];
$inputDir = $ARGV[1];
$diffArgs = $ARGV[2];

opendir(ASSIGNMENT_ROOT, "$assignment") || die "Can't open directory: $assignment\n";
opendir(SAMPLE_INPUTS, "$inputDir") || die "Can't open directory: $inputDir\n";

my $workingDir = getcwd; #so we can return to the original working directory later
my @report; #so we can have a summary when it's all over

my @inputFiles;

while (my $f = readdir(SAMPLE_INPUTS)){ #build list of sample inputs (this just assumes the outputs are there too, there'll be errors if there aren't)
	if( $f =~ m/[.]in$/ ){
		push @inputFiles, $f;
	}
}

my $tb = Text::Table->new("Folder", "Total runs", "Succes", "Failure");

while (my $current = readdir(ASSIGNMENT_ROOT)) {
	if($current eq "." || $current eq ".."){
		next;
	}


	if(!opendir(CURRENT_SUB, "$assignment/$current")){
		print "Failed to open directory $current for grading\n";
		next;
	}

	print "\n";
	
	my $runSucc = 0;
	my $runFail = 0;
	while(my $f = readdir(CURRENT_SUB)){
		if(-d $f){
			next;
		}
		if( $f =~ m/[.]exe$/){		#run every executable with the sample sets
			print "Found file $f in $current, attempting grading runs...\n";
			chdir "$assignment/$current/";		#first go to submission dir
			foreach my $input (@inputFiles){
				$input =~ /(.*)[.]in$/;		#retrieve name of input file
				my $iName = $1;
				`./$f < ../../$inputDir/$input > $iName.out`;		#actually run the thing
				
				#log if run exited cleanly
				if(${^CHILD_ERROR_NATIVE} != 0){
					$runFail++;
				}else{
					$runSucc++;
				}
				
				`diff ../../$inputDir/$iName.out $iName.out $diffArgs > $iName.diffs`;	#run the diff
			}
			chdir $workingDir;	#go back
			last;
		}
	}
	if(!$runSucc){
		print "No exe file found in $current\n";	#if we didn't find an executable 
	}
	$tb->load([$current, $runSucc + $runFail, $runSucc, $runFail]);

	closedir(CURRENT_SUB);
}
closedir(ASSIGNMENT_ROOT);
closedir(SAMPLE_INPUTS);

print $tb;