import numpy as np
import pandas as pd
from pathlib import Path
from bgen_reader import open_bgen
from mirutil.ns import make_class_instance_fr_json_file


Env = make_class_instance_fr_json_file('b_000__ENV.json')


class Var :
    pass


class Directory :
    proj_csf = Env.csf
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


def list_of_rsid_s() :
    pass

    ##
    fp = FilePath()

    df = pd.read_csv(fp.snps_200 , sep = '\t' , header = None)

    ##
    df = df[[1]]

    df.to_csv(fp.rsid_list , header = None , index = False)

    ##


"""
after this I use https://genome.ucsc.edu/cgi-bin/hgTables 
I use dbSNP155, see screen shots for accurate settings
and then I copy the rsids list to the identifiers list 
and I get the output as a bed file which consists of the positions on
the chromosome 22 for the rsids in the list in the hg38 coordinates

Then I saved the output in the sf/med folder
"""



##
