# For getting coverage per SNPs
perl ../scripts/CoveragePerSnpParallel.pl 2L.fa vcf_info.bed 20 20 600

# For calculating power and counting SNPs per features using GTF file
perl ../scripts/PowerAndFeatureCounts.pl ../scripts/PlottingPowerSim.R ../scripts/CountsFeaturesscRNA.R test.gtf dataType=rna AnnoType=GTF

# # For calculating power and counting SNPs per features using SAF file
perl ../scripts/PowerAndFeatureCounts.pl ../scripts/PlottingPowerSim.R ../scripts/CountsFeaturesscRNA.R test.saf dataType=rna AnnoType=SAF
