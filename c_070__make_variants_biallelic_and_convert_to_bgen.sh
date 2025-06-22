#!/usr/bin/bash

dx run --instance-type mem1_ssd1_v2_x8 app-cloud_workstation
dx ssh job-xxx

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:

sudo apt install bcftools -y

filtered_vcf_files_path="project-GqxPz1QJq1jfPFbKP8Jb8JKp:/projects_data/21A250115SF_WGS_imp_200_SNPS/out/144_filtered_vcf_files.tar.gz"

dx download "$filtered_vcf_files_path"

mkdir vcf_files

tar -xvzf 144_filtered_vcf_files.tar.gz -C vcf_files

# Define input and output directories
input_dir="vcf_files"
output_dir="vcf_splitted"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through all .vcf files in the input directory
for vcf_file in "$input_dir"/*.vcf; do
  # Extract the base filename (without directory and extension)
  base_name=$(basename "$vcf_file" .vcf)

  # Define the output file path
  output_file="$output_dir/${base_name}_split.vcf.gz"

  # Run the bcftools norm command
  echo "Processing $vcf_file -> $output_file..."
  bcftools norm -m- "$vcf_file" -Oz -o "$output_file"

  # Check if the command succeeded
  if [ $? -eq 0 ]; then
    echo "Done: $output_file created."
  else
    echo "Error: Failed to process $vcf_file."
  fi
done


# Define input and output directories
input_dir="vcf_splitted"
output_dir="vcf_biallelic"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through all .vcf files in the input directory
for vcf_file in "$input_dir"/*.vcf.gz; do
  # Extract the base filename (without directory and extension)
  base_name=$(basename "$vcf_file" .vcf.gz)

  # Define the output file path
  output_file="$output_dir/${base_name}_biallelic.vcf.gz"

  # Run the bcftools view command
  echo "Processing $vcf_file -> $output_file..."
  bcftools view -i 'AF>=0.01' "$vcf_file" -Oz -o "$output_file"

  # Check if the command succeeded
  if [ $? -eq 0 ]; then
    echo "Done: $output_file created."
  else
    echo "Error: Failed to process $vcf_file."
  fi
done

# just to manually check the results
plink2 --vcf rs10448608_split_biallelic.vcf.gz --freq --out test_allele_counts


input_dir="vcf_biallelic"
output_dir="bgen_files"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through all .vcf.gz files in the input directory
for vcf_file in "$input_dir"/*.vcf.gz; do
  # Extract the base filename (without directory and extension)
  base_name=$(basename "$vcf_file" .vcf.gz)

  # Define the output file prefix (used for .bgen and related files)
  output_prefix="$output_dir/$base_name"

  # Run the plink2 command
  echo "Processing $vcf_file -> $output_prefix.bgen..."
  plink2 --export bgen-1.2 ref-first --out "$output_prefix" --vcf "$vcf_file"

  # Check if the command succeeded
  if [ $? -eq 0 ]; then
    echo "Done: $output_prefix.bgen created."
  else
    echo "Error: Failed to process $vcf_file."
  fi
done

tar -czvf bgen_files.tar.gz bgen_files/
dx upload bgen_files.tar.gz


# terminate the instance
dx-set-timeout 0h
