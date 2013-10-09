#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use POSIX;

###Local variables
my $path = "tf_transpose.txt";
my $pathTF = "norm_tf.txt";
my $count=0;
my $total_docs=6413;
my @idf;


###Construct Inverse Document Frequency

open (MYFILE, $path) or die $!;
while(<MYFILE>){
	chomp;
	my $line = $_; #Read each line of the file
	my $term_number=0;
	$count++;
	my @values = split('\t', $line);
	foreach my $val (@values){
		if ($val != 0){
			$term_number++;
		}
	}		
	push (@idf, sprintf("%.4f",log($total_docs/$term_number)));
	
}
close (MYFILE);


### Construct Weighted Document Frequency.

open (WDF,">wdf.txt");
open (NORMTF, $pathTF) or die $!;
while (<NORMTF>){
	chomp;
	my $line = $_; #Read each line of the file
	my @values = split(' ', $line);
	my $cnt=0;
	foreach my $tf (@values){
			my $tf_idf = sprintf("%.4f",$tf*$idf[$cnt]);									
			print WDF $tf_idf."\t";
			$cnt++;
	}
	print WDF "\n";
}
close (NORMTF);
close(WDF);
