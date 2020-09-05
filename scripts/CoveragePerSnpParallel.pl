#usr/bin/perl

use strict;
use warnings"all";
use DirHandle;
use Data::Dumper;
use Cwd qw(getcwd);
use File::Temp qw/ tempfile tempdir /;
use Proc::Queue size=>31, qw(run_back);
use File::Copy;
Proc::Queue::trace(1);

my $RefFasta = $ARGV[0]; # /fast/groups/ag_garfield/work/genomes/sea_urchins/Spurp/v5/old_v5/fasta/spur5_plusMissing.fasta
my $vcf = $ARGV[1];		# vcf_pos.bed .. Format = chr positionSNP positionSNP
my $MAPQC = $ARGV[2];
my $baseQC = $ARGV[3];
my $maxCount = $ARGV[4];
my $datestring = localtime();
  print("Starting time one = $datestring\n");

# Create output directory and Read files containing the cell ids to be used for splitting the bam
my @array1 = <*.bam>;
print Dumper (@array1);
$datestring = localtime();
  print("Parallelizing time = $datestring\n");

# create subroutine for splitting bam and using parallel processing
sub run_code {
		my $tempfiles=shift;
		mkdir $tempfiles.'.dir';
		my $newdir = $tempfiles.'.dir';
		print("$newdir\n");
		copy("splitbamBychunks.py", "$newdir/splitbamBychunks.py");
		chdir $newdir;
		system ("python splitbamBychunks.py ../$tempfiles");
		unlink("splitbamBychunks.py");

}

# Run the sub routine ONE in parallel
for (@array1) {
     run_back { run_code($_) };
}
# Report processing status
1 while wait != -1;

my @array2 = <*/output*.sam>;
print Dumper (@array2);
sub run_code2 {
	my $tempfiles2=shift;
	system ("samtools view -bS $tempfiles2 > $tempfiles2'.bam'");
	system ("samtools index $tempfiles2'.bam'");
	system ("bam-readcount -q $MAPQC  -w1 -b $baseQC -d $maxCount -l $vcf -f $RefFasta $tempfiles2'.bam' | awk '{if(\$4>0){print \$0}}' > $tempfiles2.'cov1'");

}
		# Run the sub routine TWO in parallel
for (@array2) {
     run_back { run_code2($_) };
}

# Report processing status
1 while wait != -1;

my @array3 = <*.dir>;
print Dumper (@array3);
sub run_code3 {
	my $tempfiles3=shift;
	print("$tempfiles3\n");
	chdir "$tempfiles3";
	system ("cat *.cov1 | sort -k1,1V -k2,2n -k3,3n > ../$tempfiles3'.cov'");
	chdir "..";
	system("cut -f 1,2,4 $tempfiles3'.cov' > $tempfiles3'.cov.bed'");
	system("rm -r $tempfiles3");

}
		# Run the sub routine THREE in parallel
for (@array3) {
     run_back { run_code3($_) };
}

# Report processing status
1 while wait != -1;
$datestring = localtime();
print("Ending time = $datestring\n");
