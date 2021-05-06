#!/usr/bin/perl
#common edits on fasta files
#functions I would like:
#trim fasta headers to length n or field n (with custom delimeter)
#convert multi-line fasta to linear
#rename fasta headers 1..n w/ option for n+filename/or other unique ID
#fasta splitter + file renamer

use strict;
use warnings;
use Getopt::Long;

my(
  $help,
  $firstEntry,
  $inFileName,
  $inFileHandle,
  $method,
  $outFileName,
  $outFileHandle,
  $outDirName
);

GetOptions(
  "i|in=s"  =>  \$inFileName,
  "d|dir=s" =>  \$outDirName,
  "h|help"  =>  \$help,
  "m|method=s"  => \$method
);


open($inFileHandle,'<',$inFileName) or die;

#check for file exist, not empty, bad characters in sequence names, non-DNA/prot chars in sequence

if(!defined $outDirName){
  $outDirName="tmp";
}
#add overwrite option
mkdir($outDirName) or die "Directory $outDirName already exists";


if($method eq "split"){
  fastaSplit($inFileHandle);
}


#splits multi-fasta file into individual fasta files with one sequence per file. files named after sequence header, located in folder $outDirName.
sub fastaSplit{
while(<$inFileHandle>){
  if($_ =~/^\>(.*)/){
    if(defined $firstEntry){close($outFileHandle)};
    $firstEntry=1;
    my $fastaHeader=$1;
    $fastaHeader=~ tr/\//-/;
    $outFileName=$outDirName."/".$fastaHeader.".fasta";
    open($outFileHandle,'>',$outFileName) or die $!; #checking for file exist first. opt?
    print $outFileHandle ">$1\n";
  }
  else{print $outFileHandle $_};
  }
close($inFileHandle);
}

#add help
