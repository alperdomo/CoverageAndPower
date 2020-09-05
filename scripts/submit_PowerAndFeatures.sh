#!/usr/bin/env bash

###A cluster script to be submitted to via qsub that will trim and align reads

#First we give a few cluster parameters

# Define the expected running time of your job. Hopefully nothing runs longer than this
#$ -l h_rt=72:00:00

# Specify cue via expected length of job. Is there a reason to ever use anything other than medium?
#$ -P medium

# Combine stderr and stdout log files into the stdout log file.
#$ -j y

# Keep current environment variables.
#$ -V

# Use current working directory as working directory of the job.
#$ -cwd

# And specify the number of cores we want for this job
#$ -pe smp 31

# Set the log directory.
#$ -o logs


SCRIPT1=$1
SCRIPT2=$2
SCRIPT3=$3
ANNOTATION=$4
DATATYPE=$5
ANNOTYPE=$6

source activate splitBam

perl $SCRIPT1 $SCRIPT2 $SCRIPT3 $ANNOTATION $DATATYPE $ANNOTYPE

conda deactivate

##---------------------------------------------------------- Notes: -----------------------------------------------------------------------------------------##
# Before to run the split process, create and activate the environtment, and install the option to run in parallel using "cpanm Proc::Queue" in the terminal  #
# SCRIPT1= path to script for power and feature counts calculation (PowerAndFeatureCounts.pl)                                                                 #
# SCRIPT2= path to script for calculating the statistical power (PlottingPowerSim.R)                                                                          #
# SCRIPT3= path to script for counting and plotting feature counts (CountsFeatures.R)                                                                         #
# ANNOTATION= Either a GTF or SAF file. For scATAC: only SAF files can be used                                                                                #
# DATATYPE=  Indicate if it is either RNA or ATAC data by using: dataType=rna or dataType=atac                                                                #
# ANNOTYPE= Indicate if the ANNOTATION file is in GTF or SAF format by using: AnnoType=SAF or AnnoType=GTF                                                    #
##-----------------------------------------------------------------------------------------------------------------------------------------------------------##
