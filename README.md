
### Calculate coverage per SNP, plot power to detect allelic imbalance, and count heterozygous SNPs within genomic elements

Scripts to calculate the coverage per SNP in bam files. This repository was initially thought to explore single cell RNA and ATAC seq data

This repository contains:

"""

    • Script to calculate the coverage per SNP using samtools and bam-readcounts .

    • Script for calculating the power to detect allelic imbalance.

    • Script to count and plot the counts per features for SNPs found in
    heterozygous state (hetSNPs) that are locatedin specific genomic elements
    (e.g. Genes, Peaks, other genome coordinate)

    • Script to split bam files.

    • yml files to recreate the conda environmnet.
    
"""

The main aim of the code in this repository is allow the users to address the following questions:
- How much coverage our sequencing experiment has to have to be able to detect allelic inbalance with
effect values of 0.63,0.68,0.74,0.79,0.84? These values can be adjusted by the user. Of use to explore  
to which extend the sequencing run will suffice required coverage for detecting allelic imbalance.
- How many hetSNPs, with a user define depth of coverage, are located within genes, peaks, or other genome coordinates?

Note: The code in this repository was implemented using high performance computing (HPC) facilities. Therefore, it includes
submission scripts to the queue system from a HPC.

"""
Step I. Calculate the coverage per SNP (parallel run)
"""

• Create the environment using conda env create -f splitBam (use the splitBam.yml file)

• Install the Proc::Queue perl module within the splitBam environment using `cpanm Proc::Queue`.
This is of use running it in parallel.

• use the next information as inputs                                          #
  1. filtering script                                                       #
  2. path to reference genome *.fa, *.fasta                                   #
  3. file from vcf containing the chr, pos1 pos1                              #
  4. Minimun mapping quality to filter. Integer (e.g. 20)                     #
  5. Minimun  base quality. Integer (e.g. 20)                                 #
  6. Maximum counts to be considered  
  Example:  perl CoveragePerSnpParallel.pl filteringIDsBam.pl REF VCFpos 20 20 600
Note: The CoveragePerSnpParallel.pl script will read within the folder and search for all files bam files (*.bam)    
![](images/FertilityVsLifeExpectancy.gif)





## Step 1. Run CoveragePerSnpParallel.pl (do a less -S to the script to find more information on how to proceed with it).
## Step 2. Run the PowerAndFeatureCounts.pl script (do a less -S to the script to find more information on how to proceed with it).
