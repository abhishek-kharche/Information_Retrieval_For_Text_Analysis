#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use POSIX;

###Local variables
my $path = "wdf.txt";
my $query_vector = "query_as_a_vector.txt";
my @vector; 									#to store each line of vector total 150
my @vector_value; 								#to store value for sqrt(sum(wjt)) of rows in vector total 150 values
my @wdf; 										#to store each line of wdf matrix total 6413
my @wdf_value;									#to store value to sqrt(sum(wit)) of rows in wdf total 6413 values


### READ QUERY AS A VECTOR FILE
open (MYFILE, $query_vector) or die $!;
while(<MYFILE>){
	chomp;
	my $line = $_; #Read each line of the file
	push(@vector, $line);
}
close (MYFILE);


### FIND MAX FOR EACH LINE IN QUERY AS A VECTOR
foreach my $vect (@vector){
	my @vector_items = split('\t', $vect);
	my $count=0;
	foreach my $item(@vector_items){	
		$count = $count + $item*$item;
	}
	push (@vector_value, sqrt($count));					### THIS IS SQRT OF ALL SQRS OF VECTORS
}


### READ WDF FILE
open (WDFREQ, $path) or die $!;
while(<WDFREQ>){
	chomp;
	my $line = $_; #Read each line of the file
	push(@wdf, $line);
}
close (WDFREQ);


### FIND THE NUMERATOR IN SIMILARITY FORMULA
foreach my $vect (@wdf){
	my @wdf_items = split('\t', $vect);
	my $count=0;
	foreach my $item(@wdf_items){	
		$count = $count + $item*$item;		
	}
	push (@wdf_value, sprintf("%.4f",sqrt($count)));    ### THIS IS SQRT OF ALL SQRS OF WDF
}

open (SIMILARITY, ">similarity.txt");
my $super_counter=0;
foreach my $vect (@vector){							    ### Iterate through all vector value 150 iterations each will contain 6413 values
	my @vector_seperate = split('\t', $vect); 			### @vector_seperate will have 3179 items in total, just the first line of query_as_a_vector
	my $similarity_value=0;
	my $big_counter=1;
	foreach my $wdf (@wdf){
		my @wdf_seperate = split('\t', $wdf); 			### @wdf_seperate will have 3179 items in total just first line of wdf (total 6413)
		
		my $counter=0;
		my $final_value=0;
		foreach my $val (@wdf_seperate){
			my $value = $wdf_seperate[$counter]*$vector_seperate[$counter];
			$final_value=$final_value+$value;																	### THIS IS FINAL NUMERATOR
			$counter++;
		}
		$similarity_value=$final_value/($wdf_value[$big_counter-1]*$vector_value[$super_counter]);				### APPLY OVERALL FORMUALA	
		print SIMILARITY $big_counter."\t"."d$big_counter"." ".sprintf("%.4f",$similarity_value)."\n";			### MAKE A FORMATED OUTPUT
		$big_counter++;
	}
	print SIMILARITY "\n";
	$super_counter++;

}
close(SIMILARITY);
