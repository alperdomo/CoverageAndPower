
### Calculate coverage per SNP, power to detect allelic imbalance, and count heterozygous SNPs within genomic elements

Scripts to calculate the coverage per SNP in bam files. This repository was initially thought to explore single cell RNA and ATAC seq data

This repository contains:

    • Script to calculate the coverage per SNP using samtools and bam-readcounts .

    • Script for calculating the power to detect allelic imbalance.

    • Script to count and plot the counts per features for SNPs found in
    heterozygous state (hetSNPs) that are locatedin specific genomic elements
    (e.g. Genes, Peaks, other genome coordinate)

    • Script to split bam files.

    • yml files to recreate the conda environmnet.


The main usage of the code in this repository is to allow the users explore:
- How much coverage our sequencing experiment has to have to be able to detect allelic imbalance with
default effect values of 0.63,0.68,0.74,0.79,0.84? Effect values can be defined.

- How many hetSNPs, using user defined depth and base quality, are located within genes, peaks, or other genome coordinates?
Additional parameters could be set by following bam-readcount manual.

#### Notes:
The code in this repository was implemented using high performance computing (HPC) facilities. Therefore, it includes
submission scripts to the queue system from a HPC.

The CoveragePerSnpParallel.pl script will read within the folder and search for all files bam files (*.bam)    

Check the line "use Proc::Queue size=>31, qw(run_back);" to define the number of cores to be used.


### Step I. Calculate the coverage per SNP (runs in parallel).

1. Create the environment using the splitBam.yml file: conda env create -f splitBam.yml

2. Install the Proc::Queue perl module within the splitBam environment using `cpanm Proc::Queue`.
This is of use running it in parallel.

3. use the following information as input
  - filtering script
  - path to reference genome *.fa, *.fasta
  - file from vcf containing the chr, pos1 pos1
  - Minimun mapping quality to filter. Integer (e.g. 20)
  - Minimun  base quality. Integer (e.g. 20)
  - Maximum counts to be considered  
  Example:  perl CoveragePerSnpParallel.pl filteringIDsBam.pl REF VCFpos 20 20 600


### Step II. Calculate the power and feature counts
In this step the statistical power for detecting allele specific expression (AES) is performed.

The script will read all *.cov.bed files, whiech are generated in the previous step, and calculate the power using as effect's values: 0.63,0.68,0.74,0.79,0.84. This values can be changed by within the script PowerAndFeatureCounts.pl.

A graphical representation of the statistical power per each sample will be created.

In this step, the counts per features for SNPs that are found in heterozygous state (hetSNPs) within specific genome elements (Genes or Peaks) will be calculated. For genes it will produce two feature files (txt) containing the information for exons and for genes.

To run this step you require the following information:
  - Power calculation script  (PlottingPowerSim.R)
  - *.cov.bed (for all files)
  - R script for plotting features, either for scRNA/scATAC.
  - vcf file, which will be subsequently parsed as chr, pos1 pos1
  - A GTF or SAF file for counting the coordinates for the features (see data folder for an example)
    • The SAF annotation file format is: ID 	chr 	start 	end 	strand
    • For peak SAF annotation files set strand to +
  - Quality (Q) is set to 20, change as necessary: line running featureCounts
  - Multi-mapping reads (M) is active.
  - Multiple feature is activated (O) is active
  - Multiple processing is activated to 30 cores (-T)
  - Paired end reads is active (-p)
  - Fractional counts is active (-f)
  - Ignore duplicates is active (--ignoreDup)                             #

#### NOTE:
Using a SAF file for exons will require to run it only with the annotation for exons

Use the following information as input:
  - Script PowerAndFeatureCounts.pl
  - Script PlottingPowerSim.R
  - Script CountsFeaturesscRNA.R or CountsFeaturesscATAC.R
  - AnnotationFile: Either GTF or SAF file
  - dataType: either rna/atac
  - AnnoType: either SAF or GTF
  Example: perl PowerAndFeatureCounts.pl PlottingPowerSim.R CountsFeaturesscRNA.R annotation.gtf dataType=rna AnnoType=GTF
  

![](images/FertilityVsLifeExpectancy.gif)

## Step 1. Run CoveragePerSnpParallel.pl (do a less -S to the script to find more information on how to proceed with it).
## Step 2. Run the PowerAndFeatureCounts.pl script (do a less -S to the script to find more information on how to proceed with it).
