list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue", "sjPlot", "writexl")
lapply(list.of.packages, library, character.only = TRUE)


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
  
  model1 <- lm(g1_plus_g2 ~ g1_minus_g2_imp, data = filtered_data)
  model2 <- lm(g1_minus_g2 ~ g1_minus_g2_imp, data = filtered_data)
  
  models_summary = "/Users/mmir/Library/CloudStorage/Dropbox/git/21A250115SF_WGS_imp_200_SNPS/out/models_summary"
  
  output_file_1 <- glue("{models_summary}/{quality}_plus_{rsid_value}.txt")
  
  sink(output_file_1)  # Redirect output to the first file
  cat("Model 1 Summary (Linear Regression):\n")
  print(summary(model1))
  sink()  # Stop redirecting output
  
  output_file_2 <- glue("{models_summary}/{quality}_minus_{rsid_value}.txt")
  # Save Model 2 summary to the second file
  sink(output_file_2)  # Redirect output to the second file
  cat("Model 2 Summary (Logistic Regression):\n")
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
df <- read_parquet("/Users/mmir/Library/CloudStorage/Dropbox/git/21A250115SF_WGS_imp_200_SNPS/med/model_data_1.parquet")


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


# Loop through each unique rsid and apply the function
for (rsid in unique_rsids) {
  # Apply the function
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

out_folder_sf <- "/Users/mmir/Library/CloudStorage/Dropbox/git/21A250115SF_WGS_imp_200_SNPS/out"

write_xlsx(combined_coef_dfs, glue("{out_folder_sf}/models_coefficients/models_coefficients.xlsx"))
write_xlsx(combined_model_metrics_df, glue("{out_folder_sf}/models_metrics/models_metrics.xlsx"))



