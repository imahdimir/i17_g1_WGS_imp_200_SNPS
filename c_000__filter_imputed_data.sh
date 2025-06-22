#!/usr/bin/bash

pyenv activate dx

dx login
# enter user & password

# create a new instance
dx run --instance-type mem1_ssd1_v2_x8 app-cloud_workstation
dx ssh job-Gy42z48Jq1jqgbYjBKyP2kzq

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:

sudo apt install plink2
mkdir plink_out

# Downlad chr22 imputed data onto the instance by their ids from the RAP
# bgen
dx download file-FxY62b8JkF66qV4X0p7KGzgf
# bgi
dx download file-FxZ2f1jJkF6B5yVBPkVvZf1P
# sample
dx download file-Gqy8B4QJ5Yx3jGBky1kyGB50


dx download project-GqxPz1QJq1jfPFbKP8Jb8JKp:/projects_data/21A250115CSF_WGS_imp_200_SNPS/inp/many_high_and_low_quality_snps_on_chr22.txt
dx download project-GqxPz1QJq1jfPFbKP8Jb8JKp:/projects_data/21A250115CSF_WGS_imp_200_SNPS/inp/qualified_iids.txt


cwd=$(pwd)
bgen_fp="$cwd/ukb22828_c22_b0_v3.bgen"
sample_fp="$cwd/ukb22828_c22_b0_v3.sample"
iids="$cwd/qualified_iids.txt"
snps="$cwd/many_high_and_low_quality_snps_on_chr22.txt"
out_dir="$cwd/plink_out"

plink2 --bgen "$bgen_fp" ref-first --export bgen-1.2 --sample "$sample_fp" --keep "$iids" --extract "$snps" --out "$out_dir/200_snps_chr22"

cd plink_out
dx upload 200_snps_chr22.*
