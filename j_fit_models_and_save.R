list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue")

lapply(list.of.packages, library, character.only = TRUE)

df <- read_parquet("/Users/mmir/Library/CloudStorage/Dropbox/git/21A250115SF_WGS_imp_200_SNPS/med/model_data_1.parquet")

colnames(df)

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
}

# Example usage
fit_and_save_models(
  data = df, 
  rsid_value = "rs362156"
)

# Get unique rsid values
unique_rsids <- unique(df$rsid)

# Loop through each unique rsid and apply the function
for (rsid in unique_rsids) {
  # Apply the function
  fit_and_save_models(
    data = df, 
    rsid = rsid
  )
  # Print a message to track progress
  cat("Processed rsid:", rsid, "\n")
}



