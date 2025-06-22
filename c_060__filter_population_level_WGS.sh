#!/usr/bin/bash

dx run --instance-type mem2_ssd2_v2_x48 app-cloud_workstation
dx ssh job-GvzpgxjJq1jk2237Y19P5Yy7

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:

sudo apt install tabix -y
sudo apt install parallel
sudo apt install bcftools -y
sudo apt install vcftools -y
sudo apt install plink2

path="project-GqxPz1QJq1jfPFbKP8Jb8JKp:/Bulk/DRAGEN WGS/DRAGEN population level WGS variants, pVCF format [500k release]/chr22/"

dx download project-GqxPz1QJq1jfPFbKP8Jb8JKp:/projects_data/21A250115SF_WGS_imp_200_SNPS/med/download_list.txt
dx download project-GqxPz1QJq1jfPFbKP8Jb8JKp:/projects_data/21A250115SF_WGS_imp_200_SNPS/med/tabix_cmds.txt

num_cores=$(nproc)

# download all the vcf files in the list /TODO: I should try to use remote filtering using curl or something like that
xargs -n 1 -P "$num_cores" -I {} dx download "${path}{}" < download_list.txt

# run all the tabix commands in parallel
parallel -j "$(nproc)" < tabix_cmds.txt

# check one of the vcf files
bcftools query -f '%CHROM\t%POS\n' rs10448608.vcf
vcf-validator rs10448608.vcf
plink2 --vcf rs10448608.vcf --freq --out rs10448608_allele_counts
bcftools norm -m- rs10448608.vcf -Oz -o rs10448608_split.vcf
bcftools query -f '%CHROM\t%POS\n' rs10448608_split.vcf
plink2 --vcf rs10448608_split.vcf --freq --out rs10448608_split_allele_counts
bcftools view -i 'AF>=0.01' rs10448608_split.vcf -Oz -o rs10448608_common.vcf.gz
plink2 --vcf rs10448608_common.vcf.gz --freq --out rs10448608_common_allele_counts

rm rs10448608_split.vcf
rm rs10448608_common.vcf.gz

# Define the name of the output zip file
output_tar_gz="144_filtered_vcf_files.tar.gz"

# Check if there are any .vcf files in the current directory
if ls *.vcf >/dev/null 2>&1; then
  echo "Compressing all .vcf files into $output_tar_gz..."
  # Create a zip archive containing all .vcf files
  tar -czvf "$output_tar_gz" *.vcf
  echo "Done: $output_tar_gz created."
else
  echo "No .vcf files found in the current directory."
fi

dx-set-timout 0h
