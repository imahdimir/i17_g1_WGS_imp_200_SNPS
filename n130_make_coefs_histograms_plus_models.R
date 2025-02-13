list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue", "sjPlot", "writexl", "readxl", "gt", "ggplot2", "patchwork", "cowplot")
lapply(list.of.packages, library, character.only = TRUE)


models_coefs_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/250115_CSF_A21_WGS_imp_200_SNPS/out/models_coefficients"

df <- read_excel(glue("{models_coefs_dir}/models_coefficients.xlsx"))
head(df)


# Plus Models

# Parameter to control the height of short lines in the legend
legend_line_height <- 0.6  # Adjust this value as needed

# Filter the data for "plus" models and the specific term "g1_minus_g2_imp"
df_plus <- df %>% filter(model_name == "plus", term == "g1_minus_g2_imp")

# Calculate mean estimates for high and low quality
mean_high <- mean(df_plus %>% filter(quality == "high") %>% pull(estimate))
mean_low <- mean(df_plus %>% filter(quality == "low") %>% pull(estimate))

# Define custom colors for vertical lines (ensuring clear distinction)
vline_colors <- c(
  "Theoretical Mean" = "black",
  "Empirical Mean: High Quality" = "#D55E00",  # Distinct orange
  "Empirical Mean: Low Quality" = "#009E73"    # Distinct green
)

# Function to create histograms without legend
create_histogram <- function(data, fill_color, mean_value, mean_label, title_text) {
  ggplot(data, aes(x = estimate)) +
    geom_histogram(fill = fill_color, alpha = 0.4, bins = 30, color = "black") +
    geom_vline(aes(xintercept = 0, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
    geom_vline(aes(xintercept = mean_value, color = mean_label), linewidth = 0.8, linetype = "dashed") +
    labs(title = title_text, x = "Estimate", y = "Frequency") +
    scale_color_manual(name = "Vertical Lines", values = vline_colors) +
    theme_minimal() +
    theme(legend.position = "none")  # Remove legend
}

# Create combined plot (with legend)
combined_plot <- ggplot(df_plus, aes(x = estimate, fill = quality)) +
  geom_histogram(alpha = 0.4, position = "identity", bins = 30, color = "black") +
  geom_vline(aes(xintercept = 0, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(aes(xintercept = mean_high, color = "Empirical Mean: High Quality"), linewidth = 0.8, linetype = "dashed") +
  geom_vline(aes(xintercept = mean_low, color = "Empirical Mean: Low Quality"), linewidth = 0.8, linetype = "dashed") +
  scale_fill_manual(name = "Imputation Quality", values = c("high" = "red", "low" = "blue")) +  # Quality legend above
  scale_color_manual(name = "Vertical Lines", values = vline_colors, guide = guide_legend(override.aes = list(
    linetype = "solid",   # Solid lines in legend
    linewidth = 2,        # Thicker for visibility
    size = legend_line_height  # Custom height of short lines in the legend
  ))) +
  labs(title = "Combined Histogram for Plus Models (g1_minus_g2_imp)", x = "Estimate", y = "Frequency") +
  theme_minimal() +
  theme(
    legend.position = "right",
    legend.spacing.y = unit(20, "pt"),  # Increased spacing further
    legend.title = element_text(size = 12, face = "bold"),  # Make legend title stand out
    legend.text = element_text(size = 10),  # Improve readability of legend text
    legend.box = "vertical"  # Stack legends vertically
  )

# Create individual plots without legends
high_plot <- create_histogram(df_plus %>% filter(quality == "high"), "red", mean_high, "Empirical Mean: High Quality", "High Quality Estimates")
low_plot <- create_histogram(df_plus %>% filter(quality == "low"), "blue", mean_low, "Empirical Mean: Low Quality", "Low Quality Estimates")

# Arrange the plots in a 3-row layout
final_plot <- combined_plot / high_plot / low_plot +
  plot_layout(guides = "collect")  # Keep the legend only for the first plot

# Display the final plot
print(final_plot)

ggsave(glue("{models_coefs_dir}/plus_coef_hist.png"), final_plot)

