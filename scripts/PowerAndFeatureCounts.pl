#usr/bin/perl

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
