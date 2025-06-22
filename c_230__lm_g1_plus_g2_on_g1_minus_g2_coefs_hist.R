list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio", "arrow", "broom", "glue", "sjPlot", "writexl", "readxl", "gt", "ggplot2", "patchwork", "cowplot")
lapply(list.of.packages, library, character.only = TRUE)


models_coefs_dir <- "/Users/mmir/Library/CloudStorage/Dropbox/git/250115_CSF_A21_WGS_imp_200_SNPS/out/lm_g1_plus_g2_on_g1_minus_g2_models_coefficients"

df <- read_excel(glue("{models_coefs_dir}/lm_g1_plus_g2_on_g1_minus_g2_coefficients.xlsx"))
head(df)


# Calculate empirical means for each term and quality
empirical_means <- df %>%
  group_by(term) %>%
  summarize(mean_estimate = mean(estimate), .groups = "drop")

empirical_means

# Define custom colors for vertical lines (ensuring clear distinction)
vline_colors <- c(
  "Theoretical Mean" = "black"
)

# Create the combined plot with legend
combined_plot_minus <- ggplot(df, aes(x = estimate)) +
  geom_histogram(alpha = 0.4, position = "identity", bins = 30, color = "black", fill = "steelblue") +
  
  # Theoretical Mean Lines
  geom_vline(data = subset(df, term == "g1_minus_g2"),
             aes(xintercept = 0, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  
  scale_color_manual(name = "Vertical Lines", values = vline_colors, guide = guide_legend(override.aes = list(
    linetype = "solid",   # Solid lines in legend
    linewidth = 2,        # Thicker for visibility
    size = .6  # Custom height of short lines
  ))) +
  facet_wrap(~ term, scales = "free") +
  labs(title = "Histogram for g1 + g2 ~ g1 - g2", x = "Estimate", y = "Frequency") +
  theme_minimal() +
  theme(
    legend.position = "right",
    legend.spacing.y = unit(20, "pt"),
    legend.title = element_text(size = 12, face = "bold"),  
    legend.text = element_text(size = 10),
    legend.box = "vertical"
  )


print(combined_plot_minus)


ggsave(glue("{models_coefs_dir}/coefs_histograms.png"), plot = combined_plot_minus)



###
df <- read_excel(glue("{models_coefs_dir}/lm_g1_plus_g2_on_g1_minus_g2_coefficients.xlsx"))
head(df)

df <- df[df$term == "g1_minus_g2", ]
df$term <- 'Slope'
df=df[df$rsid != "rs11415427",]

plot <- ggplot(df, aes(x = estimate)) +
  geom_histogram(alpha = 0.4, position = "identity", bins = 30, color = "black", fill = "steelblue") +
  
  # Theoretical Mean Lines
  geom_vline(data = subset(df, term == "g1_minus_g2"),
             aes(xintercept = 0, color = "Theoretical Mean"), linewidth = 0.8, linetype = "dashed") +
  
  scale_color_manual(name = "Vertical Lines", values = vline_colors, guide = guide_legend(override.aes = list(
    linetype = "solid",   # Solid lines in legend
    linewidth = 2,        # Thicker for visibility
    size = .6  # Custom height of short lines
  ))) +
  labs(x = "Estimate", y = "Frequency") +
  theme_minimal() +
  theme(
    legend.position = "None",
    # Increase axis labels (Estimate & Frequency)
    axis.title = element_text(size = 14, face = "bold"),
    
    # Increase axis tick labels
    axis.text = element_text(size = 12),
    
  )

print(plot)

ggsave(glue("{models_coefs_dir}/coefs_histograms_slope.png"), plot = plot)

