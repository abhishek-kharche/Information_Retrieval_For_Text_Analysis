#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use POSIX;

###Local variables
my $path = "jEdit4.3/CorpusMethods-jEdit4.3-AfterSplitStopStem.txt";
my $Query_Corpus = "jEdit4.3/CorpusQueries-jEdit4.3-AfterSplitStopStem.txt";
my @queries;
my @uniqueterms;

#Open file and perform operations
open (MYFILE, $path) or die $!;
while(<MYFILE>){
	chomp;
	my $line = $_; #Read each line of the file
	$line =~ s/  / /g; #Remove extra spaces
	
	my @values = split(' ', $line);
	
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

open(VECTOR, ">query_as_a_vector.txt");
open (QUERY_CORPUS, $Query_Corpus) or die $!;
while(<QUERY_CORPUS>){
	chomp;
	my $line = $_; #Read each line of the file
	#push(@queries, $line);
	
	my @values = split(' ', $line);
	
	foreach my $term (@uniqueterms){
		my $count=0;
		foreach my $val (@values){
			if ($term eq $val){
				$count++;
			}
		}
		print VECTOR "$count\t";
	}	
	print VECTOR "\n";
}
close (QUERY_CORPUS);
close(VECTOR);