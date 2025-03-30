list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue", "sjPlot", "writexl", "readxl", "gt", "ggplot2", "patchwork", "cowplot")
lapply(list.of.packages, library, character.only = TRUE)


models_coefs_dsg_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/250115_CSF_A21_WGS_imp_200_SNPS/out/models_coefficients_dsg"

df <- read_excel(glue("{models_coefs_dsg_dir}/models_coefficients_dsg.xlsx"))
head(df)

rsid_df <- read_parquet("/Users/mmir/Library/CloudStorage/Dropbox/git/250115_CSF_A21_WGS_imp_200_SNPS/med/model_data_1.parquet")
rsid_df

rsid_df_selected <- rsid_df %>% select(rsid, info_score)
rsid_df_selected

rsid_df_selected_unique <- rsid_df_selected %>% distinct(rsid, .keep_all = TRUE)

merged_df <- df %>% left_join(rsid_df_selected_unique, by = "rsid")
merged_df

df <- merged_df

df


df_minus <- df %>% filter(model_name == "minus")

# Calculate empirical means for each term and quality
empirical_means <- df_minus %>%
  group_by(term, quality) %>%
  summarize(mean_estimate = mean(estimate), .groups = "drop")

# Define custom colors for vertical lines (ensuring clear distinction)
vline_colors <- c(
  "Theoretical Mean" = "black",
  "Empirical Mean: High Quality" = "#D55E00",  # Distinct orange
  "Empirical Mean: Low Quality" = "#009E73"    # Distinct green
)

# Create the combined plot with legend
combined_plot_minus <- ggplot(df_minus, aes(x = estimate, fill = quality)) +
  geom_histogram(alpha = 0.4, position = "identity", bins = 30, color = "black") +
  
  # Theoretical Mean Lines
  geom_vline(data = subset(df_minus, term == "(Intercept)"),
             aes(xintercept = 0, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus, term == "g1_minus_g2_imp_dsg"),
             aes(xintercept = 1, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  
  # Empirical Mean Lines (High Quality)
  geom_vline(data = empirical_means %>% filter(quality == "high"),
             aes(xintercept = mean_estimate, color = "Empirical Mean: High Quality"), linewidth = 0.8, linetype = "dashed") +
  
  # Empirical Mean Lines (Low Quality)
  geom_vline(data = empirical_means %>% filter(quality == "low"),
             aes(xintercept = mean_estimate, color = "Empirical Mean: Low Quality"), linewidth = 0.8, linetype = "dashed") +
  
  scale_fill_manual(name = "Imputation Quality", values = c("high" = "red", "low" = "blue")) +  
  scale_color_manual(name = "Vertical Lines", values = vline_colors, guide = guide_legend(override.aes = list(
    linetype = "solid",   # Solid lines in legend
    linewidth = 2,        # Thicker for visibility
    size = .6  # Custom height of short lines
  ))) +
  facet_wrap(~ term, scales = "free") +
  labs(title = "Combined Histogram for Minus Models - Imputed Dosages Data", x = "Estimate", y = "Frequency") +
  theme_minimal() +
  theme(
    legend.position = "right",
    legend.spacing.y = unit(20, "pt"),
    legend.title = element_text(size = 12, face = "bold"),  
    legend.text = element_text(size = 10),
    legend.box = "vertical"
  )

high_plot_minus <- ggplot(df_minus %>% filter(quality == "high"), aes(x = estimate)) +
  geom_histogram(fill = "red", alpha = 0.4, bins = 30, color = "black") +
  geom_vline(data = subset(df_minus, term == "(Intercept)"),
             aes(xintercept = 0, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus, term == "(Intercept)"),
             aes(xintercept = empirical_means %>% filter(term == "(Intercept)", quality == "high") %>% pull(mean_estimate), color = "Empirical Mean: High Quality"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus, term == "g1_minus_g2_imp_dsg"),
             aes(xintercept = 1, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus, term == "g1_minus_g2_imp_dsg"),
             aes(xintercept = empirical_means %>% filter(term == "g1_minus_g2_imp_dsg", quality == "high") %>% pull(mean_estimate), color = "Empirical Mean: High Quality"), linewidth = 0.8, linetype = "dashed") +
  labs(title = "High Quality Estimates for Minus Models", x = "Estimate", y = "Frequency") +
  facet_wrap(~ term, scales = "free") +
  scale_color_manual(name = "Vertical Lines", values = vline_colors) +
  theme_minimal() +
  theme(legend.position = "none")  # Remove redundant legends

low_plot_minus <- ggplot(df_minus %>% filter(quality == "low"), aes(x = estimate)) +
  geom_histogram(fill = "blue", alpha = 0.4, bins = 30, color = "black") +
  geom_vline(data = subset(df_minus, term == "(Intercept)"),
             aes(xintercept = 0, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus, term == "(Intercept)"),
             aes(xintercept = empirical_means %>% filter(term == "(Intercept)", quality == "low") %>% pull(mean_estimate), color = "Empirical Mean: Low Quality"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus, term == "g1_minus_g2_imp_dsg"),
             aes(xintercept = 1, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus, term == "g1_minus_g2_imp_dsg"),
             aes(xintercept = empirical_means %>% filter(term == "g1_minus_g2_imp_dsg", quality == "low") %>% pull(mean_estimate), color = "Empirical Mean: Low Quality"), linewidth = 0.8, linetype = "dashed") +
  labs(title = "Low Quality Estimates for Minus Models", x = "Estimate", y = "Frequency") +
  facet_wrap(~ term, scales = "free") +
  scale_color_manual(name = "Vertical Lines", values = vline_colors) +
  theme_minimal() +
  theme(legend.position = "none")  # Remove redundant legends

# Arrange the plots in a 3-row layout
final_plot_minus <- combined_plot_minus / high_plot_minus / low_plot_minus +
  plot_layout(guides = "collect")


# Display the final plot
print(final_plot_minus)


ggsave(glue("{models_coefs_dsg_dir}/minus_coefs_hist_dsg.png"), final_plot_minus)


######

df_minus <- df %>% filter(model_name == "minus")
df_minus <- df_minus[df_minus$term == "g1_minus_g2_imp_dsg",]
df_minus$term[df_minus$term == "g1_minus_g2_imp_dsg"] <- "Slope"
df_minus

# Calculate empirical means for each term and quality
empirical_means <- df_minus %>%
  group_by(term, quality) %>%
  summarize(mean_estimate = mean(estimate), .groups = "drop")

# Define custom colors for vertical lines (ensuring clear distinction)
vline_colors <- c(
  "Theoretical Mean" = "black",
  "Empirical Mean: High Quality" = "#D55E00",  # Distinct orange
  "Empirical Mean: Low Quality" = "#009E73"    # Distinct green
)

# Create the combined plot with legend
combined_plot_minus <- ggplot(df_minus, aes(x = estimate, fill = quality)) +
  geom_histogram(alpha = 0.4, position = "identity", bins = 30, color = "black") +
  
  # Theoretical Mean Lines
  geom_vline(data = subset(df_minus, term == "(Intercept)"),
             aes(xintercept = 0, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus, term == "g1_minus_g2_imp_dsg"),
             aes(xintercept = 1, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  
  # Empirical Mean Lines (High Quality)
  geom_vline(data = empirical_means %>% filter(quality == "high"),
             aes(xintercept = mean_estimate, color = "Empirical Mean: High Quality"), linewidth = 0.8, linetype = "dashed") +
  
  # Empirical Mean Lines (Low Quality)
  geom_vline(data = empirical_means %>% filter(quality == "low"),
             aes(xintercept = mean_estimate, color = "Empirical Mean: Low Quality"), linewidth = 0.8, linetype = "dashed") +
  
  scale_fill_manual(name = "Imputation Quality", values = c("high" = "red", "low" = "blue")) +  
  scale_color_manual(name = "Vertical Lines", values = vline_colors, guide = guide_legend(override.aes = list(
    linetype = "solid",   # Solid lines in legend
    linewidth = 2,        # Thicker for visibility
    size = .6  # Custom height of short lines
  ))) +
  facet_wrap(~ term, scales = "free") +
  labs(x = "Estimate", y = "Frequency") +
  theme_minimal() +
  theme_minimal() +
  theme(
    legend.position = "none",
    
    # Increase facet label (Intercept & Slope)
    strip.text = element_text(size = 14, face = "bold"),  
    
    # Increase axis labels (Estimate & Frequency)
    axis.title = element_text(size = 14, face = "bold"),
    
    # Increase axis tick labels
    axis.text = element_text(size = 12)
  )

combined_plot_minus

ggsave(glue("{models_coefs_dsg_dir}/minus_coefs_hist_dsg_lab_meet.png"), combined_plot_minus)



