list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue", "sjPlot", "writexl", "readxl", "gt")
lapply(list.of.packages, library, character.only = TRUE)

models_metrics_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/21A250115SF_WGS_imp_200_SNPS/out/models_metrics"

metrics_df <- read_excel(glue("{models_metrics_dir}/models_metrics.xlsx"))
metrics_df

rsid_df <- read_parquet("/Users/mmir/Library/CloudStorage/Dropbox/git/21A250115SF_WGS_imp_200_SNPS/med/model_data_1.parquet")
rsid_df

rsid_df_selected <- rsid_df %>% select(rsid, info_score, quality)
rsid_df_selected

rsid_df_selected_unique <- rsid_df_selected %>% distinct(rsid, .keep_all = TRUE)

merged_df <- metrics_df %>% left_join(rsid_df_selected_unique, by = "rsid")
merged_df

write_xlsx(merged_df, glue("{out_folder_sf}/models_metrics/models_metrics.xlsx"))

# Calculate summary statistics for the new data frame, including info_score
summary_stats <- merged_df %>%
  group_by(model_name, quality) %>%
  summarize(
    # Summary for info_score
    mean_info_score = mean(info_score, na.rm = TRUE),
    median_info_score = median(info_score, na.rm = TRUE),
    sd_info_score = sd(info_score, na.rm = TRUE),
    
    # Summary for r.squared
    mean_r.squared = mean(r.squared, na.rm = TRUE),
    median_r.squared = median(r.squared, na.rm = TRUE),
    sd_r.squared = sd(r.squared, na.rm = TRUE),
    
    # Summary for adj.r.squared
    mean_adj.r.squared = mean(adj.r.squared, na.rm = TRUE),
    median_adj.r.squared = median(adj.r.squared, na.rm = TRUE),
    sd_adj.r.squared = sd(adj.r.squared, na.rm = TRUE),
    
    # Summary for sigma
    mean_sigma = mean(sigma, na.rm = TRUE),
    median_sigma = median(sigma, na.rm = TRUE),
    sd_sigma = sd(sigma, na.rm = TRUE),
    
    # Summary for statistic
    mean_statistic = mean(statistic, na.rm = TRUE),
    median_statistic = median(statistic, na.rm = TRUE),
    sd_statistic = sd(statistic, na.rm = TRUE),
    
    # Summary for p.value
    mean_p.value = mean(p.value, na.rm = TRUE),
    median_p.value = median(p.value, na.rm = TRUE),
    sd_p.value = sd(p.value, na.rm = TRUE),
    
    # Summary for logLik
    mean_logLik = mean(logLik, na.rm = TRUE),
    median_logLik = median(logLik, na.rm = TRUE),
    sd_logLik = sd(logLik, na.rm = TRUE),
    
    # Summary for AIC
    mean_AIC = mean(AIC, na.rm = TRUE),
    median_AIC = median(AIC, na.rm = TRUE),
    sd_AIC = sd(AIC, na.rm = TRUE),
    
    # Summary for BIC
    mean_BIC = mean(BIC, na.rm = TRUE),
    median_BIC = median(BIC, na.rm = TRUE),
    sd_BIC = sd(BIC, na.rm = TRUE),
    
    # Summary for deviance
    mean_deviance = mean(deviance, na.rm = TRUE),
    median_deviance = median(deviance, na.rm = TRUE),
    sd_deviance = sd(deviance, na.rm = TRUE),
    
    # Summary for df.residual
    mean_df.residual = mean(df.residual, na.rm = TRUE),
    median_df.residual = median(df.residual, na.rm = TRUE),
    sd_df.residual = sd(df.residual, na.rm = TRUE),
    
    # Summary for nobs
    mean_nobs = mean(nobs, na.rm = TRUE),
    median_nobs = median(nobs, na.rm = TRUE),
    sd_nobs = sd(nobs, na.rm = TRUE),
  ) %>%
  ungroup()

# View the summary statistics
print(summary_stats)

write_xlsx(summary_stats, glue("{models_metrics_dir}/models_metrics_summary_stats.xlsx"))


# Create a publication-ready table
publication_table <- summary_stats %>%
  gt() %>%
  tab_header(
    title = "Summary Statistics",
    subtitle = "Grouped by Model Name, Quality"
  ) %>%
  fmt_number(columns = everything(), decimals = 4)  # Format numbers to 4 decimal places

# Save the table as a PNG image
gtsave(publication_table, file = glue("{models_metrics_dir}/models_metrics_summary_stats.png"), 
       zoom = 2, expand = 10, vwidth = 5000, vheight = 800)

