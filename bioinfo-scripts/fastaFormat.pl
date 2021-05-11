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
use File::Util;

my(
  $fastaHeader,
  $firstEntry,
  $help,
  $inFileName,
  $inFileHandle,
  $method,
  $outFileName,
  $outFileHandle,
  $outDirName,
  $seqLen,
  $seqName

);

GetOptions(
  "i|in=s"  =>  \$inFileName,
  "d|dir=s" =>  \$outDirName,
  "h|help"  =>  \$help,
  "m|method=s"  => \$method,
  "n|name=s" => \$seqName,
  "t|trim=i" => \$seqLen
);

if($help){
  &help();
  exit(1);
}

#input checks
if(!$method){
  die "Method not defined. Please select a method -m from split, etc.\n";
}
if(!$inFileName){
  die "Input file name not defined. Please provide an input file with -i.\n";
}
if(! -s -r -f $inFileName){
 die "File does not exist or cannot be read.\n";
}
open($inFileHandle,'<',$inFileName) or die "Cannot open file $inFileName.\n";


#run selected method. currently only one at a time can be performed
if($method eq "name"){
  fastaName($inFileHandle);
  close($inFileHandle);
}
elsif($method eq "trim"){
  fastaTrim($inFileHandle);
  close($inFileHandle);
}
elsif($method eq "split"){
  fastaSplit($inFileHandle);
  close($inFileHandle);
}


#renames sequences in a multi-fasta file based on number + user input $seqName. prints to STDOUT
sub fastaName{
  if(!defined $seqName){
    die "Please input a sequence name prefix with -n/--name\n";
  }
  my $seqNum = 0;
  while(<$inFileHandle>){
    if($_ =~/^\>(.*)/){
      $seqNum++;
      $fastaHeader=">$seqNum\_$seqName\n";
      print $fastaHeader;
    }
    else{
      seqCheck($_);
      print $_;
    }
  }
}

#trim fasta header to user-desired length $seqLen, which can be positive or negative
sub fastaTrim{
  if(!defined $seqLen){
    die "Please input a header length with -t/--trim\n";
  }
  while(<$inFileHandle>){
    if($_ =~/^\>(.*)/){
      if($seqLen > length($1)){
        print $_;
      }
      elsif($seqLen > 0){
        print ">".substr($1,0,$seqLen)."\n";
      }
      else{
        print ">".substr($1,$seqLen)."\n";
      }
    }
    else{
      seqCheck($_);
      print $_;
    }
  }
}

#split multi-fasta file into separate files containing only one sequence. requires a dedicated directory
sub fastaSplit{
  if(!defined $outDirName){
    $outDirName="tmp";
  }
  mkdir($outDirName) or die "Directory $outDirName already exists\n";
  while(<$inFileHandle>){
    if($_ =~/^\>(.*)/){
      if(defined $firstEntry){close($outFileHandle)};
      $firstEntry=1;
      $fastaHeader=$1;
      $fastaHeader=~ s/[^A-Za-z0-9_-]/_/g;
      $outFileName=$outDirName."/".$fastaHeader.".fasta";
      open($outFileHandle,'>',$outFileName) or die $!; #checking for file exist first. opt?
      print $outFileHandle $_;
    }
    else{
      seqCheck($_);
      print $outFileHandle $_;
    }
  }
}

#checks that sequence is composed with valid DNA, protein or gap chars
sub seqCheck{
  my $seqLine=$_[0];
  chomp($seqLine);
  if($seqLine =~ m/[^-A-Z]/ ){
    die "Sequence $fastaHeader contains non-standard FASTA characters.\n";
    }
  return 1;
}



sub help{
  printf "fastaFormat.pl - Some useful edits on FASTA files.\n
Usage: fastaFormat.pl -i [FASTA file] -m [METHOD] [opts]\n
\t-i --in\tSTR\tInput file. [Required]
\t-m --method\tSTR\tSelect method to perform. Only one method can be performed at a time. [Required]

Methods:
\t\"trim\"\tTrim fasta header to user defined length (useful for phylip, prokka etc). Prints to STDOUT.
\t\"name\"\tAdd index number and user-defined prefix to the beginning of sequence headers. ex. \">Protein sequence\" will become \">1_myName Protein Sequence\". Prints to STDOUT
\t\"split\"\tSplit multi-fasta file into multiple files, containing one sequence per file. Files will be output into a directory which can be named by the user. Default directory name is \"tmp\".

Method options:
\t-t --trim\tINT\tDefine sequence length for \"trim\" method. Negative integers trim from the end of the sequence header. [Required]
\t-d --dir\tSTR\tDirectory name for \"trim\" method. Default value is \"tmp\". [Optional]
\t-n --dir\tSTR\tPrefix for renaming sequence headers. [Required]
\t-h --help\t\tShow this help.\n";
  }
