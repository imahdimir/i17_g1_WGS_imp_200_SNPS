#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description:
## ---------------------------------------------------------------------


##  ---------------------------------------------------------------------
## packages

# Try to load pacman using require(), If it's not found, installs it from CRAN
if (!require("pacman")) install.packages("pacman")
library("pacman")

# Installs any missing packages and loads them
pacman::p_load(readr, ggplot2, dplyr, tidyr, glue, readxl)

## ---------------------------------------------------------------------

proj_data_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/i16_g1_CF"


## ---------------------------------------------------------------------

## plot r2 vs info_score, simple g1~g1_imp model

fp <- file.path(proj_data_dir, 'out', 'simple_reg_models_coefficients' ,'coefs_with_snps_quality.xlsx')
df_coefs <- readxl::read_xlsx(fp, sheet = 1)

fp <- file.path(proj_data_dir, 'out', 'simple_reg_models_metrics', 'simple_reg_metrics.xlsx')
df_metrics <- readxl::read_xlsx(fp, sheet = 1)

# add r.squared to df_coefs match by rsid from df_metrics
df_coefs$rsq <- df_metrics[match(df_coefs$rsid, df_metrics$rsid), 'r.squared']

df_coefs$rsq

# Subset the data for 'g1_imp'
df_coefs = subset(df_coefs, term == 'g1_imp')

df <- data.frame(rsid = df_coefs$rsid,
             info_score = df_coefs$info_score,
             rsq = df_coefs$rsq)


# Create the plot
plot <- ggplot(df, aes(x = info_score, y = r.squared)) +
  geom_point(alpha = 0.6, color = "#1f77b4") +  # light blue points with some transparency
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
  labs(
    x = "INFO Score",
    y = expression(R^2)
  ) +
  coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) +
  theme_minimal() +
  theme(
    axis.text = element_text(size = 20),
    axis.title = element_text(size = 24, face = "bold"),
    panel.grid.major = element_line(color = "grey90"),
    panel.grid.minor = element_blank()
  )

print(plot)


fp <- file.path(proj_data_dir, 'out', 'INFO_vs_R2.pdf')
scale <- 1
ggsave(fp, plot = plot, dpi = 300, width = 8 * scale, height = 6 * scale)

fp <- file.path(proj_data_dir, 'out', 'INFO_vs_R2.png')
ggsave(fp, plot = plot, dpi = 300, width = 8 * scale, height = 6 * scale)



## ---------------------------------------------------------------------


## plot qq plot for plus models and add confidence intervals to it

# Low quality
png(glue('{out_dir}/plus_models_low_quality_dosages.png'), width=6, height=5, units='in', res=300)

dos_low = dos[dos$quality=='low' & dos$term=='g1_minus_g2_imp_dsg' & dos$model_name=='plus',]
qqnorm(dos_low$statistic)
abline(a=0,b=1,col=2)

dev.off()



##




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


