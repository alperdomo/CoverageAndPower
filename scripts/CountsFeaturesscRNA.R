
library(dplyr)
library(ggplot2)
library(gridExtra)

Arg=commandArgs()
font_size <- 10
Sample <- Arg[4]

if (Sample != "^.*.GTF"){
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
		geom_line() +
	  	theme_bw() +
	  	geom_bar(fill = "lightgoldenrod", stat = "identity") +
	  	geom_text(aes(label = counts), vjust = -0.3) +
	    labs( x = "Depth", y = "counts (Genes)", angle = 90) +
	    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

	arranged <- p1
	pdf(file=outfile, width=14, height=12)
	plot(arranged)
	dev.off()
} else {
	Sample2 <- Arg[5]
	outfile <- Arg[6]
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
	  plot(arranged)
	dev.off()
	}
}
