
#### Notes:
Replace the number 20 in all lines to set the desired depth of coverage to filter hetSNP, and generate the customized GTF and SAF.

There must be a GTF file within the folder that contains the *.cov files

If you are going to run using only SAF files generated from a GTF (genes), use the the last line of the point 3 (#) and skip the line 4.  

If you are going to run using only a SAF file generated from a GTF (peaks), use the first two lines of the point 3.


1. source activate CovSnp

2. Filter of those hetSNPs that have a coverage higher than X (20 in the example) and create a *.bed file by using:
`for B in *dir.cov; do awk '{OFS="\t"; if($4>=20){print $0}}' $B | awk '{OFS="\t"; print $1,$2,$2,$4}' > ${B/.cov/20.bed}; done`

3. Generate a file to perform the overlap between hetSNPs (*.cov) and the GTF or SAF files

  - From gene annotation (GTF) to bed
  `for B in *.gtf; do awk '{OFS="\t"; print $1,$4,$5,$10}' $B | sed 's/"//g;' |sed 's/;//g;' > ${B/.gtf/.gtf.bed}; done`

  - From gene annotation (GTF) to SAF
  `for B in *.gtf; do grep -P '\ttranscript\t' $B| awk '{OFS="\t"; print $1,$4,$5,$10,$7}' | sed 's/"//g;' |sed 's/;//g;' > ${B/.gtf/.saf}; done`

  - from GTF peaks file to SAF use
  `for B in *.gtf; do awk '{OFS="\t"; print $1,$4,$5,$10,$7}' $B | sed 's/"//g;' |sed 's/;//g;' > ${B/.gtf/.saf}; done`

4. Put all the SNPs detected with coverage higher than X together, sort, and unique them. This will be used to generate a new filtered file

  - GTF and SAF file for  regions that contain hetSNP with depth > X and that are located within either Genes (GTF) or peaks (SAF)
  `cat *20.bed | sort -k1,1V -k2,2n -k3,3n | uniq > AllSNPs20.bed`

  - Generate the new  GFT and SAF with the annotation filtered based on the coverage of the hetSNPs. Here, regions that contain hetSNP with depth equal or higher than X and that are located within either Genes (GTF) or peaks (SAF) will be stored from in a subset file

    • From a Gene Annotation (GTF.bed) to subset.gtf
    `for B in *.gtf.bed; do  bedtools intersect -wao -a $B -b AllSNPs20.bed |  grep -v -P '\-1' |awk '{OFS="\t"; print $4}'| uniq |grep -f - ${B/.bed/} > ${B/.gtf.bed/.subset20.gtf}; done`

  	• From a GTF peaks file to SAF to subset.saf
    `for B in *.saf; do  bedtools intersect -wao -a $B -b AllSNPs20.bed|  grep -v -P '\-1' |awk '{OFS="\t"; print $4}'| uniq |grep -f - $B > ${B/.saf/.subset20.saf}; done`

5. delete intermediate *.bed files
  `rm *dir20.bed`
