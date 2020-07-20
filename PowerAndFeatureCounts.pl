#usr/bin/perl

##----------STATISTICAL POWER CALCULATION AND FEATURE COUNTS--------------------##
## Alvaro Perdomo-Sabogal                                                       ##
## Garfieldlab, HU, 2019                                                        ## 
##                                                                              ##
##------------------------ HELPER NOTES-----------------------------------------##
# NOTES: 									 #
# This script will calculate the statistical power for detecting Allele          # 
# especific expresion (AES) stored in *.cov files resulting from using the.      #
# script CoveragePerSnpParallele.pl. 						 #
#                                                                                #
# The script will read in the folder containing all *.cov.bed files, calculate   #
# the powers using the following effect's values: (0.63,0.68,0.74,0.79,0.84),    #
# and bult a grafical representation of the statistical power per each *.cov     #
# sample.                                                                        #
#                                                                                #
# It will also estimate  the count and plot the counts per features for those    # 
# SNPs that are found in heterozygous state (hetSNPs) and located withing        #
# specific particula genomic elements (Genes or Peaks). For genes it will        #
# produce two feature files (txt) containing the information for exons and for.  # 
# genes. #                                                                       #
#                                                                                #
# The script will read in the folder and search for all files named with the     #
# *.cov.bed files.                                                               # 
#                                                                                #
#To run the script you will need to :                                            #
# Clone the environment using conda env create -f splitBam.yml                   #
# Install the cpanm Proc::Queue in your environment using: cpanm Proc::Queue     #
# use the next information as inputs                                             #
# 1. Power calculation script  (PlottingPowerSim.R)                              #
# 2. *.cov.bed                                                                   #
# 3. R script for plotting features, either for scRNA/scATAC. (see below script3)#
# 4. vcf file, which will be posteriorly parsed as chr, pos1 pos1                #
# 4. GTF or SAF file for counting the features.                                  #
# 	 SAF annotation format: ID 	chr 	start 	end 	strand	(set     #
# strand to + 									 #
# for peak saf files.                                                         	 #
#	 - Quality (Q) is set to 20, change as necessary: line running 	 	 #
#		featureCounts 							 #
#	 - Multi-mapping reads (M) is active.                                    #
# 	 - Multiple feature is activated (O) is active                           #
#	 - Multiple processing is activated to 30 cores (-T)                     #
#	 - Paired end reads is active (-p)                                       #
#    - Fractional counts is active (-f)                                          #
#	 - Ignore duplicates is active (--ignoreDup)                             #
# 5. Flag indicating the type of data (genes or peaks). DataType=genes or        #
#    DataType=peaks                                                              #
# NOTE: Using a SAF for annotating exons will require to run it with a *.saf file#   
# with annotation only for exons                                                 #
# usage:                                                                         #
# perl script1 script2 script3 AnnotationFile dataType=rna/atac AnnoType=SAF/GTF # 
# Script1: PowerAndFeatureCounts.pl                                              #
# script2: PlottingPowerSim.R                                                    #
# script3: CountsFeaturesscRNA.R or CountsFeaturesscATAC.R                       # 
# AnnotationFile: Either GTF or saf file                                         #
# dataType: either rna/atac                                                      #
# AnnoType: either SAF or GTF                                                    #  
##------------------------------------------------------------------------------##
## Running in screen: 
## perl PowerAndFeatureCounts.pl PlottingPowerSim.R CountsFeaturesTYPE.R v3.1_mapped_annotationsFilterByHetSnps.gtf dataType=rna AnnoType=GTF
use strict;
use warnings"all";
use DirHandle;
use Data::Dumper;
use Cwd qw(getcwd);
use File::Temp qw/ tempfile tempdir /;
use Proc::Queue size=>31, qw(run_back);
use File::Copy;
Proc::Queue::trace(1); ## Note: if this package doe not work in your conda environment, use this command to install it via terminal: cpanm Proc::Queue

my $powerCalc = $ARGV[0]; 
my $countFeatures = $ARGV[1];	
my $annotation = $ARGV[2];		  
my $dataType = $ARGV[3];
	$dataType=~s/^dataType=//;
my $annotFileType = $ARGV[4];
	$annotFileType=~s/^AnnoType=//;
my $datestring = localtime();
#my $path2R=$ARGV[5];
  print("Starting time one = $datestring\n"); 

# Create output directory and Read files containing the *.cov files
my @array1 = <*.cov.bed>; 
print Dumper (@array1);
$datestring = localtime();
  print("Parallelizing time = $datestring\n");

# create subroutine for calculating power and plotting 
sub run_code {
		my $tempfiles=shift;
		mkdir $tempfiles.'.dir';
		my $newdir = $tempfiles.'.dir'; 
		print("$newdir\n");
		chdir $newdir;
		system ("R '--vanilla' '--args' ../$tempfiles $tempfiles.'pdf' \< $powerCalc ");	
}

my @array2 = <*.bam>;
print Dumper (@array2);
sub run_code2 {
	my $tempfiles2=shift;
	if ($dataType eq "rna") { 
		if ($annotFileType eq  "GTF") {
		system("featureCounts -T 30 -M -O -Q 20 --ignoreDup -p -f -F GTF -a $annotation -t transcript -g gene_id -o $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'GTFtranscript.txt' $tempfiles2"); 
	    system("featureCounts -T 30 -M -O -Q 20 --ignoreDup -p -f -F GTF -a $annotation -t exon -g gene_id -o $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'GTFexon.txt' $tempfiles2"); 
	    system("R --vanilla --args $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'GTFtranscript.txt' $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'GTFexon.txt' $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'GTFtransAndExons.pdf' \< $countFeatures");

	    }
	    if ($annotFileType eq  "SAF") {
		system("featureCounts -T 30 -M -O -Q 20 --ignoreDup -p -f -F SAF -a $annotation -t transcript -g gene_id -o $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'SAF.txt' $tempfiles2"); 
	    system("R --vanilla --args $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'SAF.txt' $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'SAF.txt' $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'SAF.pdf' \< $countFeatures");
	    }
	}
	if ($dataType eq "atac") { 
		if ($annotFileType eq  "SAF") {
		system("featureCounts -T 30 -M -O -Q 20 --ignoreDup -p -f -F SAF -a $annotation -o $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'peak.txt' $tempfiles2"); 
	    system("R --vanilla --args $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'peak.txt' $tempfiles2.'dir.cov.bed.dir/$tempfiles2'.'peak.pdf' \< $countFeatures");
	    }
	}
}

# Run the sub routine ONE in parallel
for (@array1) {
     run_back { run_code($_) };
}
# Report processing status
1 while wait != -1;

# Run the sub routine TWO in parallel
for (@array2) {
     run_back { run_code2($_) };
}

# Report processing status
1 while wait != -1;
$datestring = localtime();
print("Starting time one = $datestring\n"); 
