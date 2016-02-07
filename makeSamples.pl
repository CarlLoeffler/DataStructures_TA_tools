#!/usr/bin/perl

#Carl Loeffler
#11/8/2015

use Text::Table;

use strict;
use warnings;

use Cwd;

if(@ARGV != 2){
	print "Usage: ./autobuild <source folder> <inputs folder>\n";
	exit;
}

my $srcFolder = $ARGV[0];
my $inputsFolder= $ARGV[1];

my @inputFiles;

opendir(SAMPLE_INPUTS, $inputsFolder) || die "Can't open directory $!\n";
while (my $f = readdir(SAMPLE_INPUTS)){ #build list of sample inputs
	if( $f =~ m/[.]in$/ ){
		push @inputFiles, $f;
	}
}
closedir(SAMPLE_INPUTS);

opendir(SRC_FOLDER, "$srcFolder") || die "Can't open directory: $!\n";

my $foundC = 0;
while(my $f = readdir(SRC_FOLDER)){
	if( $f =~ m/[.]cpp$/){
		$foundC = 1;
	}
}	

my $buildTargets = "";	#we're manually building the arguments string for the microsoft compiler
rewinddir(SRC_FOLDER);
while(my $f = readdir(SRC_FOLDER)){
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
chdir "$srcFolder";
`cl /EHsc /Feprogram $buildTargets`;	#this is where the magic happens (if you have the environment variables set up right)

rewinddir(SRC_FOLDER);

while(my $f = readdir(SRC_FOLDER)){
	if(-d $f){
		next;
	}
	if( $f =~ m/[.]exe$/){		#run executable with the sample sets
		print "Running $f with inputs...\n";
		chdir "$srcFolder/";		#first go to src dir
		foreach my $input (@inputFiles){
			$input =~ /(.*)[.]in$/;		#retrieve name of input file
			my $iName = $1;
			`./$f < ../$inputsFolder/$input > ../$inputsFolder/$iName.out`;		#actually run the thing, save output to samples folder
		}
	}
}	
closedir(SRC_FOLDER);
