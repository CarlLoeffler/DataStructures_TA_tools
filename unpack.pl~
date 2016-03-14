#!/usr/bin/perl

#Carl Loeffler
#11/8/2015

use Text::Table;

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

my $tb = Text::Table->new("Student", "Contained Folder\t");

opendir(D, "$assignment") || die "Can't open directory: $!\n";

while (my $f = readdir(D)) {
	if( $f =~ m/\.zip/ ){	#blackboard gradebook archives contain stuff we don't care about - ignore everything except .zip archives
		if($extras){
			opendir(EXTRAS, "$extras") || die "Can't open directory: $!\n";
		}

		my $errors = 0;

		$f =~ /(.*).*_(.+)[.]zip/;	#retrieve student and submission name
    	my $stdntName = $2;
		my $subName = $1;
    
		print "Starting unpack for $stdntName...\n";

		#this cluster makes the submission directory, unzips submission to it, and then deletes the submission .zip
    	`mkdir \"$assignment/$stdntName\"`;
    	`unzip \"$assignment/$f\" -d \"$assignment/$stdntName/\"`;
		`rm \"$assignment/$f\"`;
	
		#blackboard generates a submission info file for each submission - move that to the folder we just created
		`mv "$assignment/$subName.txt" "$assignment/$stdntName/"`;

		#this section checks if they've submitted their work in a folder inside the zip file. The savages.
		my $containedFolder = 0;
		opendir(ASSIGNMENT_ROOT, "$assignment") || die "Error opening assignment directory\b";
		while (my $current = readdir(ASSIGNMENT_ROOT)) {
			if($current eq "." || $current eq ".."){
				next;
			}elsif(!opendir(TESTHANDLE, "$assignment/$current")){	#this is a hack to deal with -d not working right
				next;
			}
			opendir(CURRENT_SUB, "$assignment/$current") || die "Error opening $assignment/$current\n";
			my $foundFolder = "ERR_NONE_FOUND";
			my $foundC = 0;
			while(my $f = readdir(CURRENT_SUB)){
				if(-d $f){
					next;
				}elsif(opendir(TESTHANDLE, "$assignment/$current/$f")){	#this is a hack to deal with -d not working right
					if(!($f eq "__MACOSX")){	#I don't know where this comes from but it's irritatingly common
						$foundFolder = $f;
						closedir(TESTHANDLE);
					}
				}
				if( $f =~ m/[.]cpp$/){
					$foundC = 1;
				}
			}
			
			if($foundC == 0 && !($foundFolder eq "ERR_NONE_FOUND")){
				print "Found folder $foundFolder but no source files, attempting to unpack folder...\n";
				`cp $assignment/$current/$foundFolder/* $assignment/$current/`;
				$containedFolder = 1;
			}

			closedir(CURRENT_SUB);
		}
		$tb->load([$stdntName, $containedFolder ? "Yes" : "No"]);
		closedir(ASSIGNMENT_ROOT);
		
		
		#puts those files from the third argument into the newly created submission folder. This is handy for autorunning later.
		if($extras){
			while(my $xtra = readdir(EXTRAS)){
				if( !( $xtra eq "." || $xtra eq ".." ) ){
					`cp "$extras/$xtra" "$assignment/$stdntName/$xtra"`;
				}
			}
			closedir(EXTRAS);
		}

		print "\tCompleted unpacking to $stdntName.\n";
	}
}
closedir(D);
print "\n\n";
print $tb;

