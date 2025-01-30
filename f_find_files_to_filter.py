import numpy as np
import pandas as pd
from pathlib import Path
from bgen_reader import open_bgen


class Var :
    chromosome = 'chromosome'
    start_pos = 'starting_position'
    filename = 'filename'

    cmd = 'cmd'
    tbi = 'tbi'


class Directory :
    proj_csf = '/Users/mmir/Library/CloudStorage/Dropbox/git/21A250115SF_WGS_imp_200_SNPS'
    proj_csf = Path(proj_csf)
    pf = proj_csf

    inp_csf = pf / 'inp'
    med_csf = pf / 'med'
    out_csf = pf / 'out'


class FilePath :
    d = Directory()
    v = Var()

    snps_200 = d.inp_csf / 'many_high_and_low_quality_snps_on_chr22.txt'
    rsid_list = d.med_csf / 'rsid_list.txt'
    coords = d.inp_csf / 'dragen_pvcf_coordinates.csv'
    lifted = d.med_csf / 'table_browser_output_lifted.txt'

    download_list = d.med_csf / 'download_list.txt'
    tabix_cmds = d.med_csf / 'tabix_cmds.txt'


def read_and_sort_coords() :
    pass

    ##
    fp = FilePath()
    v = Var()

    ##
    df = pd.read_csv(fp.coords)
    df = df.convert_dtypes()

    ##
    df = df.sort_values(by = v.start_pos)

    ##
    return df

##
def find_vcf_file_2_download(df_coords, chrom_n, pos) :
    """
    chrom_n = 'chr22'
    """

    ##
    def _test():
        pass

        ##
        chrom_n = 'chr22'
        pos = 49424656

        ##
        df_coords = read_and_sort_coords()
        df_coords

        ##
        find_vcf_file_2_download(df_coords,chrom_n, pos)

    ##
    v = Var()

    ##
    msk = df_coords[v.chromosome].eq(chrom_n)
    msk &= df_coords[v.start_pos].le(pos)

    df = df_coords[msk]

    ##
    try:
        return df.iloc[-1][v.filename]
    except IndexError:
        return None

##
def make_tabix_inputs_file() :
    pass

    ##
    fp = FilePath()
    v = Var()

    ##
    df_coords = read_and_sort_coords()

    ##
    df = pd.read_csv(fp.lifted, sep = '\t', header = None)

    ##
    dfo = df.copy()

    ##
    dfo[v.filename] = dfo.apply(lambda x : find_vcf_file_2_download(df_coords, x[0], x[1]), axis = 1)

    ##
    dfo[v.cmd] = dfo.apply(lambda x : f'tabix -h {x[v.filename]} {x[0]}:{x[2]}-{x[2]} > {x[3]}.vcf' , axis = 1)

    ##
    dfo[v.tbi] = dfo[v.filename] + '.tbi'

    ##
    dfo = dfo.dropna()

    ##
    df_files = dfo[[v.filename, v.tbi]]
    df_files = df_files.drop_duplicates()
    df_files = pd.concat([df_files[v.filename], df_files[v.tbi]], ignore_index = True)

    df_files.to_csv(fp.download_list, index = False, header = None)

    ##
    dfo[v.cmd].to_csv(fp.tabix_cmds, index = False, header = None)

    ##





    ##




    ##


    ##


##
