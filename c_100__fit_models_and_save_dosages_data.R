list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue", "sjPlot", "writexl")
lapply(list.of.packages, library, character.only = TRUE)


csf_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/250115_CSF_A21_WGS_imp_200_SNPS"
models_data_dir <- glue("{csf_dir}/med")
models_sum_dir <- glue("{csf_dir}/out/models_summary_dsg")
out_dir <- glue("{csf_dir}/out")
models_coefs_dsg_dir <- glue("{out_dir}/models_coefficients_dsg")
models_metrics_dsg_dir <- glue("{out_dir}/models_metrics_dsg")

# Define the function
fit_and_save_models <- function(data, rsid_value) {
  
  # Step 1: Filter the dataframe for the given rsid
  filtered_data <- data %>% filter(rsid == rsid_value)
  print(nrow(filtered_data))
  quality <- filtered_data$quality[1]
  
  # Check if the filtered data is not empty
  if (nrow(filtered_data) == 0) {
    stop("No data found for the given rsid.")
  }
  
  model1 <- lm(g1_plus_g2 ~ g1_minus_g2_imp_dsg, data = filtered_data)
  model2 <- lm(g1_minus_g2 ~ g1_minus_g2_imp_dsg, data = filtered_data)
  
  output_file_1 <- glue("{models_sum_dir}/{quality}_plus_{rsid_value}_dsg.txt")
  
  sink(output_file_1)  # Redirect output to the first file
  print(summary(model1))
  sink()  # Stop redirecting output
  
  
  output_file_2 <- glue("{models_sum_dir}/{quality}_minus_{rsid_value}_dsg.txt")

  sink(output_file_2)  # Redirect output to the second file
  print(summary(model2))
  sink()  # Stop redirecting output
  
  return(list(m1 = model1, m2=model2))
}


get_models_details <- function(model, rsid_value, model_name, coefs_df, model_metrics_df) {
  # Extract coefficients and statistics
  co_df <- tidy(model)
  co_df[["rsid"]] <- rsid_value
  co_df[["model_name"]] <- model_name

  # Extract model-level statistics
  metrics_df <- glance(model)
  metrics_df[["rsid"]] <- rsid_value
  metrics_df[["model_name"]] <- model_name 
  
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
out_models <- fit_and_save_models(
  data = df, 
  rsid_value = "rs362156"
)

models_details <- get_models_details(out_models$m1, "rs362156", "plus", data.frame(), data.frame())
models_details$coefs_df
models_details$model_metrics_df



# Get unique rsid values
unique_rsids <- unique(df$rsid)

combined_coef_dfs <- data.frame()
combined_model_metrics_df <- data.frame()


# Loop through each unique rsid
for (rsid in unique_rsids) {
  out_models <- fit_and_save_models(data = df, rsid = rsid)
  
  # Print a message to track progress
  cat("Processed rsid:", rsid, "\n")
  
  models_details <- get_models_details(out_models$m1, rsid, "plus", combined_coef_dfs, combined_model_metrics_df)
  combined_coef_dfs <- models_details$coefs_df
  combined_model_metrics_df <- models_details$model_metrics_df
  
  models_details <- get_models_details(out_models$m2, rsid, "minus", combined_coef_dfs, combined_model_metrics_df)
  combined_coef_dfs <- models_details$coefs_df
  combined_model_metrics_df <- models_details$model_metrics_df
}


write_xlsx(combined_coef_dfs, glue("{models_coefs_dsg_dir}/models_coefficients_dsg.xlsx"))
write_xlsx(combined_model_metrics_df, glue("{models_metrics_dsg_dir}/models_metrics_dsg.xlsx"))


