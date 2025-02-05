list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue", "sjPlot", "writexl", "readxl", "gt", "ggplot2")
lapply(list.of.packages, library, character.only = TRUE)


models_coefs_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/21A250115SF_WGS_imp_200_SNPS/out/models_coefficients"

df <- read_excel(glue("{models_coefs_dir}/models_coefficients.xlsx"))
head(coefs_df)


df_plus <- df %>% filter(model_name == "plus")

# Plot the histograms for each term
plot <- ggplot(df_plus, aes(x = estimate, fill = quality)) +
  geom_histogram(alpha = 0.5, position = "identity") +
  scale_fill_manual(values = c("high" = "red", "low" = "blue")) +
  facet_wrap(~ term, scales = "free") +
  labs(title = "Histogram of Estimates by Term and Quality for plus models",
       x = "Estimate",
       y = "Frequency") +
  theme_minimal()

ggsave(glue("{models_coefs_dir}/plus_coefs_hist.png"), plot)


df_minus <- df %>% filter(model_name == "minus")

# Plot the histograms for each term
plot <- ggplot(df_minus, aes(x = estimate, fill = quality)) +
  geom_histogram(alpha = 0.5, position = "identity") +
  scale_fill_manual(values = c("high" = "red", "low" = "blue")) +
  facet_wrap(~ term, scales = "free") +
  labs(title = "Histogram of Estimates by Term and Quality for minus models",
       x = "Estimate",
       y = "Frequency") +
  theme_minimal()


ggsave(glue("{models_coefs_dir}/minus_coefs_hist.png"), plot)
