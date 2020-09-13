library(dplyr)
library(ggplot2)
library(gridExtra)

Arg=commandArgs()
Sample <- Arg[4]
outfile <- Arg[5]
counts <- read.table(Sample, sep="\t", header=FALSE, stringsAsFactors=FALSE)

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
  	theme_bw() +
  	geom_bar(fill = "lightgoldenrod", stat = "identity") +
  	geom_text(aes(label = counts), vjust = -0.3) +
    labs( x = "Depth", y = "counts (Peaks)", angle = 90) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

pdf(file=outfile, width=10, height=8)
print(p1)
dev.off()
