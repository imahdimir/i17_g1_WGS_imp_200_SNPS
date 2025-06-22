library(dplyr)
library(gt)
library(ggplot2)
library(gridExtra)


models_coefs_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/250115_CSF_A21_WGS_imp_200_SNPS/out/models_coefficients"
models_coefs_t_stat <- "/Users/mmir/Library/CloudStorage/Dropbox/git/250115_CSF_A21_WGS_imp_200_SNPS/out/models_coefficients_t_stats"


df <- read_excel(glue("{models_coefs_dir}/models_coefficients.xlsx"))
head(df)


plus_models <- df %>% filter(model_name == "plus")
plus_models <- plus_models %>% filter(term == "g1_minus_g2_imp")
head(plus_models)

mean_t_stat_low <- mean(plus_models %>% filter(quality == "low") %>% pull(statistic), na.rm = TRUE)
var_t_stat_low <- var(plus_models %>% filter(quality == "low") %>% pull(statistic), na.rm = TRUE)

mean_t_stat_high <- mean(plus_models %>% filter(quality == "high") %>% pull(statistic), na.rm = TRUE)
var_t_stat_high <- var(plus_models %>% filter(quality == "high") %>% pull(statistic), na.rm = TRUE)

# Create a summary table
summary_table <- tibble(
  Group = c("Low Quality", "High Quality"),
  Mean_T_Stat = c(mean_t_stat_low, mean_t_stat_high),
  Variance_T_Stat = c(var_t_stat_low, var_t_stat_high)
)

# Save table as PNG
gt(summary_table) %>%
  gtsave(glue("{models_coefs_t_stat}/t_stat_summary.png"))


# Compute sum of squared t-statistics
chi_sq_low <- sum((plus_models %>% filter(quality == "low"))$statistic^2, na.rm = TRUE)
chi_sq_high <- sum((plus_models %>% filter(quality == "high"))$statistic^2, na.rm = TRUE)

# Get counts of SNPs for degrees of freedom
N_low <- plus_models %>% filter(quality == "low") %>% nrow()
N_high <- plus_models %>% filter(quality == "high") %>% nrow()

# Perform chi-square tests
p_value_low <- pchisq(chi_sq_low, df = N_low, lower.tail = FALSE)
p_value_high <- pchisq(chi_sq_high, df = N_high, lower.tail = FALSE)

# Create chi-square results table
chi_sq_table <- tibble(
  Group = c("Low Quality", "High Quality"),
  Chi_Sq_Stat = c(chi_sq_low, chi_sq_high),
  DF = c(N_low, N_high),
  P_Value = c(p_value_low, p_value_high)
)

# Save chi-square table as PNG
gt(chi_sq_table) %>%
  fmt_number(columns = c("P_Value"), decimals = 5) %>%
  gtsave(glue("{models_coefs_t_stat}/chi_sq_results.png"))


# Create a single histogram with facets
histogram_combined <- ggplot(plus_models, aes(x = statistic, fill = quality)) +
  geom_histogram(binwidth = 0.5, alpha = 0.7, color = "black", position = "identity") +
  scale_fill_manual(values = c("low" = "blue", "high" = "red"), name = "SNP Quality") +
  facet_wrap(~quality, ncol = 1, scales = "free_y") +
  labs(title = "Histograms of T-Statistics by Model Quality", 
       x = "T-Statistic", y = "Frequency") +
  theme_minimal() +
  theme(legend.position = "right")  # Move legend to bottom center

histogram_combined

# Save the combined plot
ggsave(glue("{models_coefs_t_stat}/t_statistics_hist.png"), histogram_combined, width = 8, height = 10)
