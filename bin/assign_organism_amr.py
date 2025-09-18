#!/usr/bin/env python3

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
#
# PURPOSE:
# This script takes species identity assigned by sylph and outputs organism-
# specific parameters for AMR detection tool StarAMR.
# This script requires the species detection threshold, or the minimum proportion
# of sequencing reads required for an organism to be reported. This value is
# passed automatically via snakemake and is specified in the config/config.yaml
# AUTHOR: Nicole Lerminiaux <nicole.lerminiaux@phac-aspc.gc.ca>
#
# COMMAND LINE USAGE:
#
# assign_organism_amr.py [species detection threshold integer] [path to sample list]
#
# EXAMPLE:
#
# assign_organism_amr.py 2
#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =


# import required libraries
import pandas as pd
import numpy as np
import csv
import glob
import os
import sys
import getopt

# Import sppproportion param, sequence abundances below this percent will be filtered out
sppproportion = int(sys.argv[1])
sample_file = str(sys.argv[2])

# import sample_spp.tsv files and skip empty files
files = glob.glob(os.path.join("profile.tsv"))
data = []

for i in range(0,len(files)):
    try:
        temp = pd.read_csv(files[i], sep="\t", skiprows=[0], header=None)
        data.append(temp)
    except pd.errors.EmptyDataError:
        continue

# if there is no data in any spp files, generate blank files and quit
if not data:
    with open(os.path.join("spp_assigned.tsv"), mode='w') as empty:
        empty.write('sample\tspp_ID\tpointfinder_organism')
        empty.close
        pass
    with open(os.path.join("spp_fungi_samples.tsv"), mode='w') as empty:
        empty.write('sample\tspp_ID\tpointfinder_organism')
        empty.close
        pass
    sys.exit(0)

# concat all sample_spp.tsv
combined_file = pd.concat(data)

# get list of all samples
sample_list = pd.read_csv(sample_file, sep="\t", header=0)
samples = sample_list.loc[:,('sample')]

# select columns and filter for spp proportion
subset = combined_file[[0,3,14]]
subset_filt = subset.loc[(subset[3] > sppproportion)]
q = subset_filt[[0,14]]

# trim strings in Sylph output to get only species name
q.columns = ['sample','spp_ID']
q.loc[:, ('sample')] = q['sample'].str.replace(r'.*.qc_reads.', '', regex=True)
q.loc[:, ('spp_ID')] = q['spp_ID'].str.replace(r'^\S+\.. | str.*$|_.$|MAG: |\[|\]|uncultured ', '', regex=True)
q.loc[:, ('spp_ID')] = q['spp_ID'].str.replace(r'^(\S+\s\S+)\s.*', r'\1', regex=True)

# import key-value list and create dictionary for staramr
with open(os.path.join("pointfinder_organism.tsv"), mode='r') as infile:
    reader = csv.reader(infile, delimiter="\t")
    stardict = {rows[0]:rows[1] for rows in reader}

# query dictionary and add new column
qq = q.copy()
qq["pointfinder_organism"]=q["spp_ID"].apply(lambda x: stardict.get(x))

# concatenate pointfinder results
q_pf = qq[qq['pointfinder_organism'].notnull()]
q_pf_concat = q_pf_concat = q_pf.groupby('sample')['pointfinder_organism'].apply(lambda x: ','.join(x)).reset_index()

# concatenate species ID
q_spp_concat = qq.groupby('sample')['spp_ID'].apply(lambda x: ','.join(x)).reset_index()

# join to samples list
q_spp_joined = pd.merge(samples, q_spp_concat, on="sample", how = "left")
collapsed = pd.merge(q_spp_joined, q_pf_concat, on="sample", how = "left")

# clean up output to get unique values
collapsed_nodup = collapsed.drop_duplicates()

# output assigned species
collapsed_nodup.to_csv(os.path.join("spp_assigned.tsv"), sep="\t", index=False)

# print fungi samples to separate file
fungi = ['Nakaseomyces glabratus', 'Candida albicans', 'Candida auris', 'Candida parapsilosis', 'Candida orthopsilosis']
fungi_df = qq[qq['spp_ID'].isin(fungi)]
fungi_df.to_csv(os.path.join("spp_fungi_samples.tsv"), sep="\t", index=False)

