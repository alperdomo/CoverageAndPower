#usr/bin/perl
use strict;
use warnings"all";
use DirHandle;
use Data::Dumper;
use Cwd qw(getcwd);
use File::Temp qw/ tempfile tempdir /;
use Proc::Queue size=>2, qw(run_back);
use File::Copy;
Proc::Queue::trace(1);

my $RefFasta = $ARGV[0];
my $vcf = $ARGV[1];
my $MAPQC = $ARGV[2];
my $baseQC = $ARGV[3];
my $maxCount = $ARGV[4];
my $datestring = localtime();
print("Starting time = $datestring\n");

my @array1 = <*.bam>;
$datestring = localtime();

sub run_code1 {
		my $tempfiles=shift;
		mkdir $tempfiles.'.dir';
		my $newdir = $tempfiles.'.dir';
		copy("../scripts/splitbamBychunks.sh", "$newdir/splitbamBychunks.sh");
		chdir $newdir;
    system ("chmod +777 ./splitbamBychunks.sh");
		system ("./splitbamBychunks.sh ../$tempfiles");
		unlink("splitbamBychunks.sh");
}
for (@array1) {
     run_back { run_code1($_) };
}
1 while wait != -1;

my @array2 = <*/*.bam>;
sub run_code2 {
  my $tempfiles2=shift;
  system ("samtools index $tempfiles2");
  system ("bam-readcount -w1 -q $MAPQC -b $baseQC -d $maxCount -l $vcf -f $RefFasta $tempfiles2 | awk '{if(\$4>0){print \$0}}' > $tempfiles2.'cov1'");

}
for (@array2) {
     run_back { run_code2($_) };
}
1 while wait != -1;

my @array3 = <*.dir>;
sub run_code3 {
	my $tempfiles3=shift;
	chdir "$tempfiles3";
	system ("cat *.cov1 | sort -k1,1V -k2,2n -k3,3n > ../$tempfiles3'.cov'");
	chdir "..";
	system("cut -f 1,2,4 $tempfiles3'.cov' > $tempfiles3'.cov.bed'");
  system("rm -r $tempfiles3");
}
for (@array3) {
     run_back { run_code3($_) };
}
1 while wait != -1;

$datestring = localtime();
print("Ending time = $datestring\n");
