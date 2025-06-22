list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue", "sjPlot", "writexl", "readxl", "gt")
lapply(list.of.packages, library, character.only = TRUE)

models_coefs_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/21A250115SF_WGS_imp_200_SNPS/out/models_coefficients"

coefs_df <- read_excel(glue("{models_coefs_dir}/models_coefficients.xlsx"))
head(coefs_df)

rsid_df <- read_parquet("/Users/mmir/Library/CloudStorage/Dropbox/git/21A250115SF_WGS_imp_200_SNPS/med/model_data_1.parquet")
rsid_df

rsid_df_selected <- rsid_df %>% select(rsid, info_score, quality)
rsid_df_selected

rsid_df_selected_unique <- rsid_df_selected %>% distinct(rsid, .keep_all = TRUE)

merged_df <- coefs_df %>% left_join(rsid_df_selected_unique, by = "rsid")
merged_df

write_xlsx(merged_df, glue("{out_folder_sf}/models_coefficients/models_coefficients.xlsx"))

# Group by model_name, quality, and term, then calculate summary statistics
summary_stats <- merged_df %>%
  group_by(model_name, quality, term) %>%
  summarize(
    mean_info_score = mean(info_score, na.rm = TRUE),
    median_info_score = median(info_score, na.rm = TRUE),
    sd_info_score = sd(info_score, na.rm = TRUE),
    mean_estimate = mean(estimate, na.rm = TRUE),
    median_estimate = median(estimate, na.rm = TRUE),
    sd_estimate = sd(estimate, na.rm = TRUE),
    mean_std.error = mean(std.error, na.rm = TRUE),
    median_std.error = median(std.error, na.rm = TRUE),
    sd_std.error = sd(std.error, na.rm = TRUE),
    mean_statistic = mean(statistic, na.rm = TRUE),
    median_statistic = median(statistic, na.rm = TRUE),
    sd_statistic = sd(statistic, na.rm = TRUE),
    mean_p.value = mean(p.value, na.rm = TRUE),
    median_p.value = median(p.value, na.rm = TRUE),
    sd_p.value = sd(p.value, na.rm = TRUE)
  ) %>%
  ungroup()

# View the summary statistics
print(summary_stats)

write_xlsx(summary_stats, glue("{models_coefs_dir}/models_coeffcients_summary_stats.xlsx"))


# Create a publication-ready table
publication_table <- summary_stats %>%
  gt() %>%
  tab_header(
    title = "Summary Statistics",
    subtitle = "Grouped by Model Name, Quality, and Term"
  ) %>%
  fmt_number(columns = everything(), decimals = 4)  # Format numbers to 4 decimal places

# Save the table as a PNG image
gtsave(publication_table, file = glue("{models_coefs_dir}/models_coeffcients_summary_stats.png"), 
       zoom = 2, expand = 10, vwidth = 3000, vheight = 800)


