list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue", "sjPlot", "writexl", "readxl", "gt", "ggplot2", "patchwork", "cowplot")
lapply(list.of.packages, library, character.only = TRUE)


models_coefs_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/250115_CSF_A21_WGS_imp_200_SNPS/out/models_coefficients"


df <- read_excel(glue("{models_coefs_dir}/models_coefficients.xlsx"))
head(df)


# Parameter to control the height of short lines in the legend
legend_line_height <- 0.6  # Adjust this for better visibility

# Filter data for "minus" models
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
  geom_vline(data = subset(df_minus, term == "g1_minus_g2_imp"),
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
    size = legend_line_height  # Custom height of short lines
  ))) +
  facet_wrap(~ term, scales = "free") +
  labs(title = "Combined Histogram for Minus Models", x = "Estimate", y = "Frequency") +
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
  geom_vline(data = subset(df_minus, term == "g1_minus_g2_imp"),
             aes(xintercept = 1, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus, term == "g1_minus_g2_imp"),
             aes(xintercept = empirical_means %>% filter(term == "g1_minus_g2_imp", quality == "high") %>% pull(mean_estimate), color = "Empirical Mean: High Quality"), linewidth = 0.8, linetype = "dashed") +
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
  geom_vline(data = subset(df_minus, term == "g1_minus_g2_imp"),
             aes(xintercept = 1, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus, term == "g1_minus_g2_imp"),
             aes(xintercept = empirical_means %>% filter(term == "g1_minus_g2_imp", quality == "low") %>% pull(mean_estimate), color = "Empirical Mean: Low Quality"), linewidth = 0.8, linetype = "dashed") +
  labs(title = "Low Quality Estimates for Minus Models", x = "Estimate", y = "Frequency") +
  facet_wrap(~ term, scales = "free") +
  scale_color_manual(name = "Vertical Lines", values = vline_colors) +
  theme_minimal() +
  theme(legend.position = "none")  # Remove redundant legends

# Arrange the plots in a 3-row layout
final_plot_minus <- combined_plot_minus / high_plot_minus / low_plot_minus +
  plot_layout(guides = "collect")  # Keep the legend only for the first plot

# Display the final plot
print(final_plot_minus)


ggsave(glue("{models_coefs_dir}/minus_coefs_hist.png"), final_plot_minus)



df_minus_1 <- df %>% filter(model_name == "minus")
df_minus_1$term[df_minus$term == "g1_minus_g2_imp"] <- "Slope"

# Calculate empirical means for each term and quality
empirical_means <- df_minus_1 %>%
  group_by(term, quality) %>%
  summarize(mean_estimate = mean(estimate), .groups = "drop")


# Create the combined plot with legend
combined_plot_minus <- ggplot(df_minus_1, aes(x = estimate, fill = quality)) +
  geom_histogram(alpha = 0.4, position = "identity", bins = 30, color = "black") +
  
  # Theoretical Mean Lines
  geom_vline(data = subset(df_minus_1, term == "(Intercept)"),
             aes(xintercept = 0, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus_1, term == "Slope"),
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
    size = legend_line_height
  ))) +
  facet_wrap(~ term, scales = "free") +
  labs(x = "Estimate", y = "Frequency") +
  theme_minimal() +
  theme(
    legend.position = "right",
    legend.spacing.y = unit(20, "pt"),
    legend.title = element_text(size = 12, face = "bold"),  
    legend.text = element_text(size = 15),
    legend.box = "vertical",
    
    # Increase facet label (Intercept & Slope)
    strip.text = element_text(size = 14, face = "bold"),  
    
    # Increase axis labels (Estimate & Frequency)
    axis.title = element_text(size = 14, face = "bold"),
    
    # Increase axis tick labels
    axis.text = element_text(size = 12)
  )

combined_plot_minus

ggsave(glue("{models_coefs_dir}/minus_coefs_hist_combined_for_TAGC_conference.png"), combined_plot_minus)


# Assuming 'correlations' is your vector of 1000 correlation values
mean_cor <- 0.49845532
se_cor <- 0.021872553 / sqrt(998)
null_value <- 0.5  # Null hypothesis value
t_stat <- (mean_cor - null_value) / se_cor
p_value <- 2 * pt(-abs(t_stat), df = 997)

# Output results
list(mean = mean_cor, se = se_cor, t_stat = t_stat, p_value = p_value)
format(p_value, scientific = TRUE)


##########

df_minus_1 <- df[df$model_name == "minus" & df$term == "g1_minus_g2_imp",]
df_minus_1$term[df_minus_1$term == "g1_minus_g2_imp"] <- "Slope"

# Calculate empirical means for each term and quality
empirical_means <- df_minus_1 %>%
  group_by(term, quality) %>%
  summarize(mean_estimate = mean(estimate), .groups = "drop")


# Create the combined plot with legend
combined_plot_minus <- ggplot(df_minus_1, aes(x = estimate, fill = quality)) +
  geom_histogram(alpha = 0.4, position = "identity", bins = 30, color = "black") +
  
  # Theoretical Mean Lines
  geom_vline(data = subset(df_minus_1, term == "(Intercept)"),
             aes(xintercept = 0, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(data = subset(df_minus_1, term == "Slope"),
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
    size = legend_line_height
  ))) +
  facet_wrap(~ term, scales = "free") +
  labs(x = "Estimate", y = "Frequency") +
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

ggsave(glue("{models_coefs_dir}/minus_coefs_lab_meeting_present.png"), combined_plot_minus)

