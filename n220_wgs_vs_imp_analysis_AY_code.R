setwd('~/Dropbox/SSGAC/family_based_imputation/')
require(readxl)
require(glue)

out_dir <- '~/Dropbox/git/250115_CSF_A21_WGS_imp_200_SNPS/out/qq_plots'

d = read_xlsx('models_coefficients (1).xlsx',sheet=1)
# plus model
d_low = d[d$quality=='low' & d$term=='g1_minus_g2_imp' & d$model_name=='plus',]
d_high = d[d$quality=='high' & d$term=='g1_minus_g2_imp' & d$model_name=='plus',]

d_high$q = p.adjust(d_high$p.value,method='BH')

d_high[d_high$q<0.1,]

plot(d_high$info_score,d_high$q)

# minus model
hist(as.matrix(d[d$quality=='low' & d$term=='g1_minus_g2_imp' & d$model_name=='minus','estimate']))


### Dosages
dos = read_xlsx('models_coefficients_dsg.xlsx',sheet=1)


# High quality
png(glue('{out_dir}/plus_models_high_quality_dosages.png'), width=6, height=5, units='in', res=300)

dos_high = dos[dos$quality=='high' & dos$term=='g1_minus_g2_imp_dsg' & dos$model_name=='plus',]
qqnorm(dos_high$statistic)
abline(a=0,b=1,col=2)

dev.off()


# Low quality
png(glue('{out_dir}/plus_models_low_quality_dosages.png'), width=6, height=5, units='in', res=300)

dos_low = dos[dos$quality=='low' & dos$term=='g1_minus_g2_imp_dsg' & dos$model_name=='plus',]
qqnorm(dos_low$statistic)
abline(a=0,b=1,col=2)

dev.off()


## Minus model

# High quality
png(glue('{out_dir}/minus_models_high_quality_dosages.png'), width=6, height=5, units='in', res=300)

dos_high_minus = dos[dos$quality=='high' & dos$term=='g1_minus_g2_imp_dsg' & dos$model_name=='minus',]
dos_high_minus
qqnorm(dos_high_minus$statistic)
abline(a=0,b=1,col=2)

dev.off()

# Low quality
png(glue('{out_dir}/minus_models_low_quality_dosages.png'), width=6, height=5, units='in', res=300)

dos_low_minus = dos[dos$quality=='low' & dos$term=='g1_minus_g2_imp_dsg' & dos$model_name=='minus',]
qqnorm(dos_low_minus$statistic)
abline(a=0,b=1,col=2)

dev.off()



### Simple g1~g1_imp model 
d_simp = data.frame(read_xlsx('coefs_with_snps_quality.xlsx',sheet=1))
# Merge with metrics
metrics_simp = data.frame(read_xlsx('simple_reg_metrics.xlsx'),sheet=1)
d_simp$rsq = metrics_simp[match(d_simp$rsid,metrics_simp$rsid),'r.squared']
# low quality
d_simp_low = d_simp[d_simp$quality=='low' & d_simp$term=='g1_imp',]
plot(d_simp_low$info_score,d_simp_low$rsq)
# high quality
d_simp_high = d_simp[d_simp$quality=='high' & d_simp$term=='g1_imp',]
plot(d_simp_high$info_score,d_simp_high$rsq)
abline(a=0,b=1,col=2)
# Combined plot
pdf('~/Dropbox/family_based_imputation/INFO_vs_R2.pdf',height=5,width=6)
plot(d_simp[d_simp$term=='g1_imp','info_score'],d_simp[d_simp$term=='g1_imp','rsq'],
     xlab='INFO Score',ylab='R^2 between imputed and WGS',xlim=c(0,1),ylim=c(0,1))
abline(a=0,b=1,col=2)
dev.off()


### WGS sib comparison
wgs = data.frame(read_xlsx('wgs_g1_plus_g2_on_g1_minus_g2_coefficients.xlsx',sheet=1))
wgs_outlier = wgs[wgs$rsid=='rs11415427',]
wgs = wgs[wgs$rsid!='rs11415427',]
wgs
wgs$freq = wgs[wgs$term=='(Intercept)','estimate']/4
wgs = wgs[wgs$term=='g1_minus_g2',]
plot(wgs$freq,wgs$statistic)
cor.test(wgs$statistic,wgs$freq)

png(glue('{out_dir}/WGS_Sib_Plus_Minus_Reg_Statistics.png'),width=6,height=5, units = 'in', res=300)

qqnorm(wgs$statistic)
abline(a=0,b=1,col=2)

dev.off()
