list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue", "sjPlot", "writexl", "readxl", "gt", "ggplot2", "patchwork", "cowplot")
lapply(list.of.packages, library, character.only = TRUE)


models_coefs_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/250115_CSF_A21_WGS_imp_200_SNPS/out/models_coefficients"

df <- read_excel(glue("{models_coefs_dir}/models_coefficients.xlsx"))
head(df)


# Filter data for "minus" models
df_minus <- df %>% filter(model_name == "minus")

# Create the combined histogram plot for "minus" models
combined_plot_minus <- ggplot(df_minus, aes(x = estimate, fill = quality)) +
  geom_histogram(alpha = 0.5, position = "identity") +
  scale_fill_manual(values = c("high" = "red", "low" = "blue")) +
  facet_wrap(~ term, scales = "free") +
  labs(title = "Combined Histogram for Minus Models",
       x = "Estimate",
       y = "Frequency") +
  theme_minimal()

# Create the histogram plot for "high" quality (minus models)
high_plot_minus <- ggplot(df_minus %>% filter(quality == "high"), aes(x = estimate)) +
  geom_histogram(fill = "red", alpha = 0.5) +
  facet_wrap(~ term, scales = "free") +
  labs(title = "High Quality Estimates for Minus Models",
       x = "Estimate",
       y = "Frequency") +
  theme_minimal()

# Create the histogram plot for "low" quality (minus models)
low_plot_minus <- ggplot(df_minus %>% filter(quality == "low"), aes(x = estimate)) +
  geom_histogram(fill = "blue", alpha = 0.5) +
  facet_wrap(~ term, scales = "free") +
  labs(title = "Low Quality Estimates for Minus Models",
       x = "Estimate",
       y = "Frequency") +
  theme_minimal()

# Arrange the plots in a 3x2 layout
final_plot_minus <- combined_plot_minus / high_plot_minus / low_plot_minus +
  plot_layout(nrow = 3, heights = c(1, 1, 1))

# Display the final plot
print(final_plot_minus)


ggsave(glue("{models_coefs_dir}/minus_coefs_hist.png"), final_plot_minus)



