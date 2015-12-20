#!/usr/bin/perl

#Carl Loeffler
#11/8/2015

use strict;
use warnings;

if(@ARGV != 2 && @ARGV != 3){
	print "Usage: unpack.pl <source .zip> <dest>\n";
	print "Or   : unpack.pl <source .zip> <dest> <source folder>\n";
	exit;
}

my $srcFile;
my $assignment;
my $extras = 0;
$srcFile = $ARGV[0];
$assignment = $ARGV[1];

if(@ARGV == 3){			#optional third argument allows you to prep the execution environment of the submissions
	$extras = $ARGV[2];	#	by putting all files from a location into each unpacked submission folder
}


`mkdir $assignment`;

`unzip \"$srcFile\" -d \"$assignment/\"`;

opendir(D, "$assignment") || die "Can't open directory: $!\n";

while (my $f = readdir(D)) {
	if( $f =~ m/\.zip/ ){	#blackboard gradebook archives contain stuff we don't care about - ignore everything except .zip archives
		if($extras){
			opendir(EXTRAS, "$extras") || die "Can't open directory: $!\n";
		}

		$f =~ /(.*).*_(.+)[.]zip/;	#retrieve student and submission name
    	my $stdntName = $2;
		my $subName = $1;
    
		#this cluster makes the submission directory, unzips submission to it, and then deletes the submission .zip
    		`mkdir \"$assignment/$stdntName\"`;
    		`unzip \"$assignment/$f\" -d \"$assignment/$stdntName/\"`;
		`rm \"$assignment/$f\"`;
	
		#blackboard generates a submission info file for each submission - move that to the folder we just created
		`mv "$assignment/$subName.txt" "$assignment/$stdntName/"`;

		#puts those files from the third argument into the newly created submission folder. This is handy for autorunning later.
		if($extras){
			while(my $xtra = readdir(EXTRAS)){
				if( !( $xtra eq "." || $xtra eq ".." ) ){
					`cp "$extras/$xtra" "$assignment/$stdntName/$xtra"`;
				}
			}
			closedir(EXTRAS);
		}

		print "Completed unpacking to $stdntName.\n";
	}
}
closedir(D);
