#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

binmode(STDOUT);

#local vars
my $path="jEdit4.3/jEdit4.3ListOfFeatureIDs.txt";
my $pathMapping = "jEdit4.3/CorpusMethods-jEdit4.3.mapping";
my $pathVSM= "VSM_final.txt";
my @featureID;
my @mappings;
my %VSM;


### READ FEATURE FILE
open(MYFILE,'<:crlf',$path) or die $!;
while(<MYFILE>){
	chomp;
	my $line= $_;
	push (@featureID, $line);
}
close(MYFILE);

### READ MAPPINGS FILE
open(MAPPING,$pathMapping) or die $!;
while(<MAPPING>){
	chomp;
	my $line= $_;
	push (@mappings,$line);
}
close(MAPPING);

chomp(@featureID);

### READ VSM FILE
my $featureCount=0;
open(VSM, '<:crlf', $pathVSM) or die $!;
while(<VSM>){
	chomp;
	my $line= $_;
	if ($line ne ""){
		my @values=split("\t",$line);
		$VSM{$featureID[$featureCount]}{$values[0]}=$values[1];			# CONSTRUCT VSM HASH TO STORE ITS VALUES WITH DOCUMENT ID
		
	}else{
		$featureCount++;
	}
}
close(VSM);


### READ GOLD SETS DIRECTORY
my $directory = 'jEdit4.3/jEdit4.3GoldSets';							# READ THIS DIRECTORY
my @files;
opendir (DIR, $directory) or die $!;
while (my $file = readdir(DIR)) {
	push (@files, $file) if ($file =~m /^[A-Z]/g);						# FILES ARRAY WILL CONTAINS ALL NAMES OF FILES
}

my $count =0;
my @GoldFiles;
push (@GoldFiles,$files[148]);
push (@GoldFiles,$files[149]);
foreach my $row (@files){
	$count++;
	next if ($count==149);
	next if ($count==150);
	push (@GoldFiles,$row);
}

my $counter=0;
my $mapdefault=-1;														# DEAFUALT VALUES FOR NON PRESENT METHODS
my @csv_final;															# TO STORE MIDDLE 3 COLUMNS
my @best;																# TO STORE THE BEST RANK (5TH COLUMN)
my @linecount;															# TO STORE THE COUNT OF METHODS IN EACH FEATURE
foreach my $feature(@featureID){
	my $pathGold = "jEdit4.3/jEdit4.3GoldSets/$GoldFiles[$counter]";	# CONSTRUCT THE PATH DYNAMICALLY
	my $first=1;
	my $min=9999;
	my $line_count=0;
	open (GOLDSET, $pathGold) or die $!;
	while(<GOLDSET>){
		chomp;
		my $line= $_;
		my $string=undef;
		$line_count++;
		
		###Find the position in mapping 
		my $mapcount=1;
		my $val1;
		my $val2;
		my $val3;
		foreach my $map (@mappings){
			if ($line eq $map){
				$val1=$mapcount;
				last;
			}
			$mapcount++;
		}
		if ($mapcount==6414){
			$val1=$mapdefault
		}
		$val2=$line;
		
		# Find the position of the method in VSM
		my $flag=0;		
		foreach my $method (keys %{$VSM{$feature}}){
			my $index = index($VSM{$feature}{$method}, " ");			
			if (substr ($VSM{$feature}{$method}, 1, $index) == $mapcount ){
				$val3=$method;
				$min = $method if($method < $min);							# SET MINIMUM TO THE BEST RANK OF ALL METHODS
				$flag=1;
			}
			
		}

		$val3=" " if ($flag==0);											# PRINT NOTHING FOR ABSENT METHODS
		my @list=($val1,$val2,$val3);
		$string = join('%', @list);											# CONSTRUCT THE STRING FOR MIDDLE 3 COLUMNS
		push (@csv_final, $string);
	}
	close(GOLDSET);

	$counter++;
	push(@best,$min);
	push(@linecount,$line_count);

}

### PRINT THE FORMATTED FILE
my $master_count=0;
my $sum = 0;
my $count_lines=0;

chomp(@csv_final);

open (CSV, '>csvfile.txt');

#PRINT FIRST LINE
print CSV "featureID%GoldSet MethodID Position%Goldset MethodID%VSM GoldSetMethodID Rank - All Ranks%VSM GoldSetMethodID Rank - Best Ranks\n\n";
foreach my $f (@featureID){
	print CSV $featureID[$master_count];	
	$sum = $sum + $linecount[$master_count];
	my $first=1;
	for (my $cnt = $count_lines; $cnt < $sum; $cnt++) {
		print CSV "%".$csv_final[$cnt];										# THE FILE WILL BE % DELIMETED
		if ($first==1){
			print CSV "%".$best[$master_count]."\n";
			$first=0;
		}else{
			print CSV "\n";
		}
		$count_lines++;
	}
	$master_count++;
	print CSV "\n";
}
close(CSV);

########################### END OF PROJECT ##########################
