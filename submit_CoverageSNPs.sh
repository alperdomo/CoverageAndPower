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
REFERENCE=$2
VCFPOSBED=$3
MAPQC=$4
BASEQC=$5
MAXCOUNT=$6


source activate splitBam

perl $SCRIPT1 $REFERENCE $VCFPOSBED $MAPQC $BASEQC $MAXCOUNT

conda deactivate 

##---------------------------------------------------------- Notes: -----------------------------------------------------------------------------------------##
# Before to run the split process, create and activate the environtment, and install the option to run in parallel using "cpanm Proc::Queue" in the terminal  #                
# SCRIPT1= path to parsing script (split_bam_sciATAC.pl)                                                                                                      #                                                               
# REFERENCE= fastafile                                                                                                                                        #
# VCFPOSBED = Format = chr positionSNP positionSNP                                                                                                            #
# MAPQC = Minimum mapping quality . Integer                                                                                                                   #	
# BASEQC = Minimum base quality. Integer                                                                                                                      #
# MAXCOUNT= Maximun number for coverage. It reduces the amount of memory used                                                                                 #
##-----------------------------------------------------------------------------------------------------------------------------------------------------------## 
