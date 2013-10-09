#!/usr/bin/perl

use strict;
use warnings;

#local vars
my $path="similarity.txt";					# Unsorted similarity file
my $counter=0;
my %documents;

open(VSM, ">VSM.txt");
open(MYFILE,$path) or die $!;
while(<MYFILE>){
	chomp;
	my $line= $_;
	if ($counter!=6413){
		my @values=split("\t",$line);	
		my $tab_count=0;
		foreach my $row (@values){		
			if($tab_count==0){
				$tab_count++;
				next;
			}
			my @docs=split(" ",$row);			
			$documents{$docs[0]}=$docs[1];	# POPULATE HASH 
			$counter++;
		}
	}else{
		my @sorted = sort { $documents{$b} <=> $documents{$a} } keys %documents;		# SORT THE SIMILARITY VALUES
		my $count=1;
		foreach my $file (@sorted) {
			next if($documents{$file}==0.0000);											# EXCLUDE 0 SIMILARITY VALUE
			print VSM "$count\t$file $documents{$file}\n";								# GENERATE VSM FILE
			$count++;
		}
		$counter=0;
		print VSM "\n";
	}
	
}
close(MYFILE);
close(VSM);


