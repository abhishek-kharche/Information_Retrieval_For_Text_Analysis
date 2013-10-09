#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use POSIX;

###Local variables
my $pathCorpus = "jEdit4.3/CorpusMethods-jEdit4.3-AfterSplitStopStem.txt";
my @uniqueterms; # Array to store unique terms from whole corpus
my @line_array;
my %term_doc;

my $cntr=0;
#Open file and perform operations
open (MYFILE, $pathCorpus) or die $!;
while(<MYFILE>){
	chomp;
	my $line = $_; #Read each line of the file
	$line =~ s/  / /g; #Remove extra spaces
	push (@line_array, $line);
	
	my @values = split(' ', $line);	
	
	foreach my $r (@values){
		$cntr++;
	}
	
	### To find unique terms in one line
	my %seen;
	@values = grep { ! $seen{ $_ }++ } @values;
	
	foreach my $row (@values){
		push (@uniqueterms,$row);   ### Storing all unique terms in a line to an array		
	}	
}
close (MYFILE);

### To find the unique terms in whole file
my %seen;
@uniqueterms = grep { ! $seen{ $_ }++ } @uniqueterms;


open (FILE, ">norm_tf.txt");
foreach my $ln (@line_array){
	my @values = split(' ', $ln);	
	my @rows;
	my $max=0;
	foreach my $row (@uniqueterms){
		my $counter=0;
		foreach my $val (@values){
			if ($val eq $row){
				$counter++;				
			}			
		}
		push (@rows, $counter);
		$max=$counter if($counter>$max);	#Find max for each line
	}
	foreach my $item (@rows){
		print FILE sprintf("%.4f",$item/$max)." "; #Print normalized tf
	}
	print FILE "\n";
}
close(FILE);