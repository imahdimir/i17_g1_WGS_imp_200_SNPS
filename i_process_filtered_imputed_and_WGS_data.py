import numpy as np
import pandas as pd
from pathlib import Path
from bgen_reader import open_bgen
from mirutil.compress import compress_and_split_parallel


class Var :
    iid = 'IID'
    rsid = 'rsid'
    gt = 'gt'
    g1_imp = 'g1_imp'
    g2_imp = 'g2_imp'
    id1 = 'ID1'
    id2 = 'ID2'
    inf_type = 'infType'
    g1_wgs = 'g1_wgs'
    g2_wgs = 'g2_wgs'
    g1_minus_g2 = 'g1_minus_g2'
    g1_plus_g2 = 'g1_plus_g2'
    g1_minus_g2_imp = 'g1_minus_g2_imp'
    info = 'info_score'
    quality = 'quality'


class Directory :
    proj_csf = '/Users/mmir/Library/CloudStorage/Dropbox/git/21A250115SF_WGS_imp_200_SNPS'
    proj_csf = Path(proj_csf)
    pf = proj_csf

    inp_csf = pf / 'inp'
    med_csf = pf / 'med'
    out_csf = pf / 'out'

    imputed_data = med_csf / 'imputed_data'
    wgs_data = med_csf / 'wgs_data'


class FilePath :
    d = Directory()
    v = Var()

    impupted_data_bgen = d.imputed_data / '200_snps_chr22.bgen'
    imputed_data_parquet = d.med_csf / 'imputed_data.parquet'
    wgs_data_parquet = d.med_csf / 'wgs_data.parquet'
    wgs_data_parquet_zst = d.med_csf / 'wgs_data.parquet.zst'
    model_data_0 = d.med_csf / 'model_data_0.parquet'
    rels = d.inp_csf / 'ukb_rel_with_infType_fs.csv'
    snps_data = d.inp_csf / 'many_high_and_low_quality_snps_on_chr22.txt'
    model_data_1 = d.med_csf / 'model_data_1.parquet'


def create_sibs_df() :
    pass

    ##
    d = Directory()
    fp = FilePath()
    v = Var()

    ##
    df = pd.read_csv(fp.rels)

    ##
    msk = df[v.inf_type].eq('FS')
    df = df[msk]

    ##
    df = df[[v.id1 , v.id2]]

    ##
    df = df.astype('Int64').astype('string')

    ##
    df = df.drop_duplicates()

    ##
    return df

    ##


def prepare_imputed_data() :
    pass

    ##
    d = Directory()
    fp = FilePath()
    v = Var()

    ##
    bgn = open_bgen(fp.impupted_data_bgen)

    ##
    sample = bgn.samples
    len(sample)

    ##
    _dct = {
            v.iid : sample
            }

    df_iid = pd.DataFrame(_dct)

    ##
    df_iid[v.iid] = df_iid[v.iid].str.split('_').str[1]

    ##
    nd = bgn.read()
    nd.shape

    ##
    gt = np.argmax(nd , axis = 2)
    gt.shape

    ##
    # Extract variant information
    variants = bgn.rsids
    variants.shape

    ##
    df_gt = pd.DataFrame(gt , columns = variants , index = df_iid[v.iid])
    df_gt.value_counts()

    ##
    df_gt = df_gt.reset_index()

    ##
    melted_df = pd.melt(df_gt ,
                        id_vars = [v.iid] ,
                        var_name = v.rsid ,
                        value_name = v.gt)

    ##
    df_sibs = create_sibs_df()

    df_rsids = pd.DataFrame(variants)

    ##
    df_imp = df_sibs.merge(df_rsids , how = 'cross')
    df_imp = df_imp.rename(columns = {
            0 : v.rsid
            })

    ##
    df_imp = pd.merge(df_imp ,
                      melted_df ,
                      left_on = [v.id1 , v.rsid] ,
                      right_on = [v.iid , v.rsid] ,
                      how = 'left')

    ##
    df_imp = df_imp.rename(columns = {
            v.gt : v.g1_imp
            })
    df_imp = df_imp.drop(columns = [v.iid])

    ##
    df_imp = pd.merge(df_imp ,
                      melted_df ,
                      left_on = [v.id2 , v.rsid] ,
                      right_on = [v.iid , v.rsid] ,
                      how = 'left')

    ##
    df_imp = df_imp.rename(columns = {
            v.gt : v.g2_imp
            })
    df_imp = df_imp.drop(columns = [v.iid])

    ##
    df_imp.to_parquet(fp.imputed_data_parquet , index = False)

    ##


##
def get_all_wgs_filenames() :
    pass

    ##
    d = Directory()

    ##
    bgn_files = list(d.wgs_data.rglob('*.bgen'))

    ##
    bgn_basenames = [bgn_file.name for bgn_file in bgn_files]

    ##
    rsids = [bgn_basename.split('_')[0] for bgn_basename in bgn_basenames]

    ##
    return rsids


##
def read_wgs_by_rsid(rsid) :
    pass

    ##
    def _test() :
        pass

        ##
        rsid = 'rs130825'

    ##
    d = Directory()
    fp = FilePath()
    v = Var()

    ##
    print(rsid)

    ##
    bgn = open_bgen(d.wgs_data / f'{rsid}_split_biallelic.bgen')

    ##
    sample = bgn.samples
    sample.shape

    ##
    _dct = {
            v.iid : sample
            }

    df_gt = pd.DataFrame(_dct)

    ##
    nd = bgn.read()
    nd.shape

    ##
    gt = np.argmax(nd , axis = 2)
    gt.shape

    ##
    if gt.shape != (sample.shape[0] , 1) :
        print('Error')
        return pd.DataFrame()

    ##
    df_gt[v.rsid] = rsid

    ##
    df_gt[v.gt] = gt

    ##
    return df_gt


##
def combine_all_wgs_data() :
    pass

    ##
    fp = FilePath()

    ##
    rsids = get_all_wgs_filenames()
    rsids

    ##
    df = pd.DataFrame()

    ##
    for rsid in rsids :
        df_rs = read_wgs_by_rsid(rsid)
        df = pd.concat([df , df_rs])

    ##
    df.to_parquet(fp.wgs_data_parquet , index = False)

    ##


##
def combine_imputed_and_wgs_data() :
    pass

    ##
    d = Directory()
    fp = FilePath()
    v = Var()

    ##
    df_imp = pd.read_parquet(fp.imputed_data_parquet)

    ##
    df_wgs = pd.read_parquet(fp.wgs_data_parquet)

    ##
    df_imp = pd.merge(df_imp ,
                      df_wgs ,
                      left_on = [v.id1 , v.rsid] ,
                      right_on = [v.iid , v.rsid] ,
                      how = 'left')

    ##
    df_imp = df_imp.rename(columns = {
            v.gt : v.g1_wgs
            })

    ##
    df_imp = df_imp.drop(columns = [v.iid])

    ##
    df_imp = df_imp.dropna()

    ##
    df_imp = pd.merge(df_imp ,
                      df_wgs ,
                      left_on = [v.id2 , v.rsid] ,
                      right_on = [v.iid , v.rsid] ,
                      how = 'left')

    ##
    df_imp = df_imp.rename(columns = {
            v.gt : v.g2_wgs
            })
    df_imp = df_imp.drop(columns = [v.iid])

    ##
    df_imp = df_imp.dropna()

    ##
    df = df_imp

    ##
    # reverse the coding for the WGS data
    df[v.g1_wgs] = 2 - df[v.g1_wgs]
    df[v.g2_wgs] = 2 - df[v.g2_wgs]

    ##
    df[v.g1_minus_g2] = df[v.g1_wgs] - df[v.g2_wgs]
    df[v.g1_plus_g2] = df[v.g1_wgs] + df[v.g2_wgs]
    df[v.g1_minus_g2_imp] = df[v.g1_imp] - df[v.g2_imp]

    ##
    df.to_parquet(fp.model_data_0 , index = False)

    ##


def add_info_to_model_data() :
    pass

    ##
    d = Directory()
    fp = FilePath()
    v = Var()

    ##
    df = pd.read_parquet(fp.model_data_0)

    ##
    df_info = pd.read_csv(fp.snps_data , sep = '\s' , header = None)

    ##
    df_info = df_info.rename(columns = {
            1 : v.rsid ,
            7 : v.info
            })

    ##
    df_info = df_info[[v.rsid , v.info]]

    ##
    df_info.describe()

    ##
    df_info[v.quality] = np.where(df_info[v.info].ge(0.8) , 'high' , 'low')

    ##
    df = pd.merge(df , df_info , on = v.rsid)

    ##
    df.to_parquet(fp.model_data_1 , index = False)

    ##


def get_some_basic_stats_on_model_data() :
    pass

    ##
    d = Directory()
    fp = FilePath()
    v = Var()

    ##
    df = pd.read_parquet(fp.model_data_1)

    ##
    df.describe()

    ##
    df[[v.id1 , v.id2]].drop_duplicates().count()

    ##
    df[v.rsid].nunique()

    ##
    df[[v.rsid , v.quality]].drop_duplicates().groupby(v.quality).count()

    ##


##
def compress_wgs_data_to_archive_on_github() :
    pass

    ##
    d = Directory()
    fp = FilePath()

    ##
    compress_and_split_parallel(fp.wgs_data_parquet)

    ##

    ##
    
    ##
