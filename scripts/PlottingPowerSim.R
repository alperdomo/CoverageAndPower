# USAGE:
# R --vanilla --args sample1 powerDetectingAE.pdf
library(ggplot2) # for plotting power curves

Arg=commandArgs()
sample <- Arg[4] ## coverage file. Format: chr  pos depth
outfile <- Arg[5]

df <- read.table(sample)
# df<-read.table("AT04_38Aligned.out.markdup.filtered.sorted.bam.cov.bed")
df$cluster = sample

clusterIDs <- unique(df$cluster)
effect <- c(0.63,0.68,0.74,0.79,0.84) # this values can be modified based on the Allelic imbalanced willing to be mesured for 
for (k in seq_along(clusterIDs)) {
  result <- data.frame()
  x <- clusterIDs[k] == df$cluster
  x <- df[x,]
  x <- x$V3
  x1 <- max(x)
  if (x1 <= 500){
      depth <- 1:x1
  }
  if (x1 >=500) {
      depth <- 1:500
      x1 <- 500 
  }
  p0 <- 1/2
  alpha2 <- 0.01
  for (i in seq_along(depth)){
      for (j in seq_along(effect)){
        #print (depth[i])
        n <- depth[i]
        ic <- 1-pbinom(x-1, n, p0) < alpha2 
        xm <- min(x[ic])
        pp1 <- 1-pbinom(xm-1,depth[i],effect[j])
        pp1 <- cbind(effect[j],pp1,depth[i])
        result <- rbind(result, pp1)
      }
    }

    subset <- data.frame()
    for (i in seq_along(effect)) { 
        subsets <- effect[i] == result$V1
        subsets <- result[subsets,]
        order <- order(subsets$pp1)
        subsets0 <- cbind(subsets$pp1,i)
        subsets0 <- subsets0[order,]
        subsets <- cbind(subsets$V3,subsets0)
        subset <- rbind(subset,subsets)
    }

    colnames(subset) <- c("x","y","col")
    subset$col <- factor(subset$col, levels = c("1","2","3","4","5"))
    colores=c("1"="#7f0000", "2"="#fdd49e", "3"="#fdbb84", "4"="#fc8d59", "5"="#ef6548")
    p3 <- ggplot(subset,aes(x=x,y=y,group=col,colour=factor(col))) + 
              geom_line() + 
              theme_bw() + 
              scale_color_manual("Imbalance",values= colores, labels = c("63/37, 1.7 fold","68/32, 2.1 fold","74/26, 2.8 fold","79/21, 3.7 fold","84/16, 5.2 fold")) +
              theme(axis.text=element_text(size=14), 
                   axis.title=element_text(size=14), 
                  legend.text=element_text(size=14))+
              scale_x_continuous(limits=c(0, x1+10), breaks = seq(0, x1, by = 50)) + 
              labs( x = "Depth", y = "Power(Probability p < 10^-2)", angle = 90) +
              geom_hline(yintercept = 0.8, linetype = 2, col="black") + 
              ggtitle(clusterIDs[k]) 
        pdf(file=outfile, width=10, height=12)
        print(p3)
        dev.off()
}

