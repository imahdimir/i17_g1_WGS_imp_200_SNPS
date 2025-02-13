list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue", "sjPlot", "writexl")
lapply(list.of.packages, library, character.only = TRUE)


csf_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/250115_CSF_A21_WGS_imp_200_SNPS"
models_data_dir <- glue("{csf_dir}/med")
out_dir <- glue("{csf_dir}/out")
simple_reg_summary_dir <- glue("{out_dir}/simple_reg_models_summary")


fit_and_save_models <- function(data, rsid_value) {
  # Step 1: Filter the dataframe for the given rsid
  filtered_data <- data %>% filter(rsid == rsid_value)
  print(nrow(filtered_data))
  quality <- filtered_data$quality[1]
  
  # Check if the filtered data is not empty
  if (nrow(filtered_data) == 0) {
    stop("No data found for the given rsid.")
  }
  
  model <- lm(g1_wgs ~ g1_imp, data = filtered_data)
  
  output_fp <- glue("{simple_reg_summary_dir}/{quality}_{rsid_value}.txt")
  
  sink(output_fp)  # Redirect output to the first file
  cat("Model Summary (Linear Regression):\n")
  print(summary(model))
  sink()  # Stop redirecting output
  
  return(model)
}


get_models_details <- function(model, rsid_value, coefs_df, model_metrics_df) {
  # Extract coefficients and statistics
  co_df <- tidy(model)
  co_df[["rsid"]] <- rsid_value
  
  # Extract model-level statistics
  metrics_df <- glance(model)
  metrics_df[["rsid"]] <- rsid_value
  
  # Concatenate co_df to coefs_df
  coefs_df <- rbind(coefs_df, co_df)
  
  # Concatenate metrics_df to model_metrics_df
  model_metrics_df <- rbind(model_metrics_df, metrics_df)
  
  # Return both updated dataframes as a list
  return(list(coefs_df = coefs_df, model_metrics_df = model_metrics_df))
}


# read models data
df <- read_parquet(glue("{models_data_dir}/model_data_1.parquet"))
head(df)

# Example usage
model <- fit_and_save_models(
  data = df, 
  rsid_value = "rs362156"
)
summary(model)

models_details <- get_models_details(model, "rs362156", data.frame(), data.frame())
models_details$coefs_df
models_details$model_metrics_df



# Get unique rsid values
unique_rsids <- unique(df$rsid)

combined_coef_dfs <- data.frame()
combined_model_metrics_df <- data.frame()


# Loop through each unique rsid and apply the function
for (rsid in unique_rsids) {
  # Apply the function
  m <- fit_and_save_models(data = df, rsid = rsid)
  
  # Print a message to track progress
  cat("Processed rsid:", rsid, "\n")
  
  models_details <- get_models_details(m, rsid, combined_coef_dfs, combined_model_metrics_df)
  combined_coef_dfs <- models_details$coefs_df
  combined_model_metrics_df <- models_details$model_metrics_df
}


write_xlsx(combined_coef_dfs, glue("{out_dir}/simple_reg_models_coefficients/simple_reg_coefficients.xlsx"))
write_xlsx(combined_model_metrics_df, glue("{out_dir}/simple_reg_models_metrics/simple_reg_metrics.xlsx"))

