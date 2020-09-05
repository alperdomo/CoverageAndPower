

# Previous steps:
# source activate splitBam 
##  awk '{print $1,$2,$3,$4}'  OverlappingHetSNPsToGenes.intersect | uniq > OverlappingHetSNPsToGenes.intersect.bed
##  Example: bedtools intersect -wao -a AT04_38Aligned.out.markdup.filtered.sorted.bam.dir2.cov.bed -b v3.1_mapped_annotations.bed | grep -v -P '\-1' > OverlappingHetSNPsToGenes.intersect
## 1. Overlap the SNPs from the coverage files (bed format: chr, snpPos snpPos Depth) with the geneAnnotation bed file 
## bedtools intersect -wao -a *hetSNPs.cov -b TranscriptsAnnotations.bed > *.intersec
## Filtered hetSNPs that contains hesSNPs that overlapped with transcripts, thus:
## get the distribution of coverage per transcript 
## saved as bed:  awk '{print $1,$2,$3,$4}'  *.intersect | uniq  > OverlappingHetSNPsToGenes.intersect.bed
## Filtered the annotation SAF file using the overlaps bewteen HestSNPs and Genes
# cut -f 8  OverlappingHetSNPsToGenes.intersect | sort | uniq | grep -f - v3.1_mapped_annotations.saf > v3.1_mapped_annotationsFilterByHetSnps.saf

# featureCounts -T 30 -M -O -Q 20 --ignoreDup -p -f -F GTF -a /fast/scratch/groups/ag_garfield/Alvaro/powers/test/v3.1_mapped_annotationsFilterByHetSnps.gtf -t transcript -g gene_id -o AT04_38Aligned.counts.gtf.txt /fast/scratch/groups/ag_garfield/Alvaro/powers/test/AT04_38Aligned.out.markdup.filtered.sorted.bam



 # SAF FORMAT SEEMS TO PERFORM BETTER 
# Used featurecounts in Terminal 
#featureCounts -T 30 -M -O -Q 30 --ignoreDup -p -f -F SAF -a /fast/scratch/groups/ag_garfield/Alvaro/powers/test/v3.1_mapped_annotationsFilterByHetSnps.saf -t transcript -g gene_id -o AT04_38Aligned.counts.txt /fast/scratch/groups/ag_garfield/Alvaro/powers/test/AT04_38Aligned.out.markdup.filtered.sorted.bam


library(dplyr)
library(ggplot2)
library(gridExtra)

Arg=commandArgs()
Sample <- Arg[4] ## *counts.txt
Sample2 <- Arg[5] ## *counts.txt
outfile <- Arg[6] ## outFileName1
font_size <- 10
counts <- read.table(Sample, sep="\t", header=FALSE, stringsAsFactors=FALSE)
# counts <- read.table('/Users/Varo/Desktop/bihCluster2/powers/test/AT04_38Aligned.out.markdup.filtered.sorted.bam.dir.cov.bed.dir/AT04_38Aligned.out.markdup.filtered.sorted.bam.GTFtranscript.txt', sep="\t", header=FALSE, stringsAsFactors=FALSE)

counts <- counts[counts$V7>0,]
dims <- dim(counts)
dims <- dims[1]
counts <- counts[2:dims,] 
distanceColumn="V7"
Feature <- freq <- .id <- NULL
counts$Feature <- NA
limit <- c(1, 20, 50, 75, 100, 200, 300, 500,1000)
lbs <- c("1-20", "21-50", "51-75", "76-100", "101-200", "201-300","301-500", "501-1000", ">1000")
for (i in 1:length(limit)) {
	if (i < length(limit)) {
        counts$Feature[ (as.numeric(counts[, distanceColumn]))>= limit[i] & as.numeric(counts[,distanceColumn]) < limit[i+1] ] <- lbs[i]
    } else {
        counts$Feature[as.numeric(counts[,distanceColumn])  > limit[i]] <- lbs[i]
    }
}

df <- counts %>%
  group_by(Feature) %>% 
  summarise(counts = n())
df <- df[1:9,]
df$Feature<- factor(df$Feature, levels = c("1-20", "21-50", "51-75", "76-100", "101-200", "201-300","301-500", "501-1000", ">1000"), 
			labels= c("1-20", "21-50", "51-75", "76-100", "101-200", "201-300","301-500", "501-1000", ">1000"))
p1 <- ggplot(df, aes(x = Feature, y = counts)) +
	geom_line() + 
  	theme_bw() + 
  	geom_bar(fill = "lightgoldenrod", stat = "identity") +
  	geom_text(aes(label = counts), vjust = -0.3) + 
    labs( x = "Depth", y = "counts (Transcripts)", angle = 90) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())


counts2 <- read.table(Sample2, sep="\t", header=FALSE, stringsAsFactors=FALSE)
# counts2 <- read.table('/Users/Varo/Desktop/bihCluster2/powers/test/AT04_38Aligned.out.markdup.filtered.sorted.bam.dir.cov.bed.dir/AT04_38Aligned.out.markdup.filtered.sorted.bam.GTFexon.txt', sep="\t", header=FALSE, stringsAsFactors=FALSE)
counts2 <- counts2[counts2$V7>0,]

dims <- dim(counts2)
dims <- dims[1]
counts2 <- counts2[2:dims,] 
distanceColumn="V7"
Feature <- freq <- .id <- NULL
counts2$Feature <- NA
limit <- c(1, 20, 50, 75, 100, 200, 300, 500,1000)
lbs <- c("1-20", "21-50", "51-75", "76-100", "101-200", "201-300","301-500", "501-1000")
for (i in 1:length(limit)) {
	if (i < length(limit)) {
        counts2$Feature[ (as.numeric(counts2[, distanceColumn]))>= limit[i] & as.numeric(counts2[,distanceColumn]) < limit[i+1] ] <- lbs[i]
    } else {
        counts2$Feature[as.numeric(counts2[,distanceColumn])  > limit[i]] <- lbs[i]
    }
}

df2 <- counts2 %>%
  group_by(Feature) %>% 
  summarise(counts2 = n())
df2 <- df2[1:8,]


df2$Feature<- factor(df2$Feature, levels = c("1-20", "21-50", "51-75", "76-100", "101-200", "201-300","301-500", "501-1000", ">1000"), 
			labels= c("1-20", "21-50", "51-75", "76-100", "101-200", "201-300","301-500", "501-1000", ">1000"))
p2 <- ggplot(df2, aes(x = Feature, y = counts2)) +
	geom_line() + 
  	theme_bw() + 
  	geom_bar(fill = "lightcyan3", stat = "identity") +
  	geom_text(aes(label = counts2), vjust = -0.3) + 
    labs( x = "Depth", y = "counts (Exons)", angle = 90) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

arranged <- grid.arrange(p1, p2, nrow = 1)
pdf(file=outfile, width=14, height=12)
	#grid.arrange(p1, p2, nrow = 1)
	plot(arranged)
dev.off()

