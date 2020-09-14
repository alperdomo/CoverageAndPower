
### Calculate the power to detect allelic imbalance,  coverage per SNP, and count heterozygous SNPs ()HetSNPs) within coordinate defined genomic regions. 

![](images/PowerAndFeatureCounts_peaks_hetSNPs.png)


Scripts to calculate the power to detect allelic imbalance and the coverage per SNP in bam files. This repository was initially thought to explore single cell RNA and ATAC seq data, where we wanted to explore the obtained coverge per each cluster of cells. It is a complement to the SplitBam repository, which is of use for splitting bam files from single cell data based on cell IDs clustering together.

The CoverageAndPower repository contains:

    • Script to calculate the coverage per SNP using samtools and bam-readcounts .

    • Script for calculating the power to detect allelic imbalance.

    • Scripts to count and plot the counts per features per SNPs found in
    heterozygous state (hetSNPs) that are located in specific genomic elements
    (e.g. Genes, Peaks, other genome coordinates)

    • Script to split bam files by chunks.

    • yml file to recreate the CovSnp conda environmnet.


This code allows the users to explore:
- How much coverage our sequencing experiment has to have to be able to detect allelic imbalance with
default effect values of 0.63,0.68,0.74,0.79,0.84? Effect values can be user adjusted.

- How many hetSNPs, using user defined depth and base quality, are located within genes, peaks, or other genome coordinates?
Additional parameters could be set by following bam-readcount manual available here: https://github.com/genome/bam-readcount, and the package subread here: http://subread.sourceforge.net/.

#### Notes:
The code  was implemented to be used in high performance computing (HPC) facilities with queuing systems; therefore, it also includes the submission scripts to the HPC.

The CoveragePerSnpParallel.pl script will read within the folder and search for all bam files (unsorted or sorted *.bam)

Check the line "use Proc::Queue size=>31, qw(run_back);" to define the number of cores to be used.

It will split the bam file based on a particular length. The user can modify this length by changing the size in the script splitbamByshuncks.sh.

To run the test files, check the file `running_test.sh` within the scripts folder. 


### Step I. Calculate the coverage per SNP (runs in parallel).

1. Create the environment using the coverage.yml file: conda env create -f coverage.yml. It will create a conda environment called CovSnp (Recommended step). The user can also install the required programs on its local file system using the listed programs in the yml file as guide.

2. Install the Proc::Queue perl module within the CovSnp environment using `cpanm Proc::Queue`.
This is of use running it in parallel.

3. Use the following information as input
  - filtering script
  - path to reference genome *.fa, *.fasta
  - file containing information from the variant call. Example: chr pos1 pos1
  - Minimun mapping quality to filter. Integer (e.g. 20)
  - Minimun  base quality. Integer (e.g. 20)
  - Maximum counts to be considered
  Example:  `perl CoveragePerSnpParallel.pl reference.fa VCF_positions 20 20 600`


### Step II. Calculate the power and feature counts
In this step the statistical power for detecting allelic imbalance is performed.

- The script will read all *.cov.bed files, which are generated in the previous step, and calculate the power using as effect's values: 0.63,0.68,0.74,0.79,0.84. This values can be changed by within the script PowerAndFeatureCounts.pl.

- Plot the statistical power per each sample will be created.

- Count the hetSNPs within specific genome elements (coordinates for Genes or Peaks). For genes it will produce two feature's files (txt) containing the information for exons and for genes. It will also plot the amount of HetSNPs per feature at different ranges of coverage. These ranges can also be updated by modifying values within the R scripts. 

To run this step the user will require the following information:
  - Power calculation script  (`PlottingPowerSim.R`)
  - *.cov.bed (for all files)
  - R script for plotting features, either for scRNA/scATAC.
  - vcf file, which will be subsequently parsed as chr, pos1 pos1
  - A GTF or simpler annotation format (SAF) file for counting the the HetSNPs for specific features (see data folder for examples)
    • The SAF annotation file format is: ID 	chr 	start 	end 	strand
    • For peak SAF annotation files set strand to +
  - Quality (Q) is set to 20, change as necessary: line running featureCounts
  - Multi-mapping reads (M) is active.
  - Multiple feature is activated (O) is active
  - Multiple processing is activated to 30 cores (-T)
  - Paired end reads is active (-p)
  - Fractional counts is active (-f)
  - Ignore duplicates is active (--ignoreDup)

#### Note:
Using a SAF file for getting information for exons will require to run it only with an annotation file for such features.

To run this step, use the following information as input:
  - Script `PowerAndFeatureCounts.pl`
  - Script `PlottingPowerSim.R`
  - Script `CountsFeaturesscRNA.R` or `CountsFeaturesscATAC.R`
  - AnnotationFile: Either GTF or SAF file
  - dataType: either rna/atac
  - AnnoType: either SAF or GTF
  Example: `perl PowerAndFeatureCounts.pl PlottingPowerSim.R CountsFeaturesscRNA.R annotation.gtf dataType=rna AnnoType=GTF`


### Count for features in hestSNPs with coverage higher than X
In the case that users want to calculate the counts for features where the hetSNPs have a coverage higher than X, and that are located in genes or peaks, the *cov files can be filtered using the steps described in the shell script found in the scripts folder `filter_by_coverage.sh`

