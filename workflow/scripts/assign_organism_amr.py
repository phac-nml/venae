# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
#
# PURPOSE: 
# This script takes species identity assigned by sylph and outputs organism-
# specific parameters for AMR detection tools AMRFinderPlus and StarAMR.
# This script requires the species detection threshold, or the minimum proportion 
# of sequencing reads required for an organism to be reported. This value is 
# passed automatically via snakemake and is specified in the config/config.yaml 
# AUTHOR: Nicole Lerminiaux <nicole.lerminiaux@phac-aspc.gc.ca>
#
# COMMAND LINE USAGE:
#
# assign_organism_amr.py [species detection threshold integer] [output folder name] [path to sample list]
#
# EXAMPLE:
#
# assign_organism_amr.py 2 results/ config/samples.tsv
#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

#!/bin/python

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
output_folder = str(sys.argv[2])
sample_list = str(sys.argv[3])

# import sample_spp.tsv files and skip empty files
files = glob.glob(os.path.join(output_folder, "spp_sylph_profile.tsv"))
data = []

for i in range(0,len(files)):
    try:
        temp = pd.read_csv(files[i], sep="\t", header=None)
        data.append(temp)
    except pd.errors.EmptyDataError:
        continue

# if there is no data in any spp files, generate blank files and quit
if not data:
    with open(os.path.join(output_folder, "spp_assigned.tsv"), mode='w') as empty:
        pass
    with open(os.path.join(output_folder, "spp_fungi_samples.tsv"), mode='w') as empty:
        pass
    sys.exit(0)

# concat all sample_spp.tsv   
combined_file = pd.concat(data)

# get list of all samples 
sample_list = pd.read_csv(sample_list, sep="\t", header=0)
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
with open(os.path.join("resources", "pointfinder_organism.tsv"), mode='r') as infile:
    reader = csv.reader(infile, delimiter="\t")
    stardict = {rows[0]:rows[1] for rows in reader}

# query dictionary and add new column
qq = q.copy()
qq["pointfinder_organism"]=q["spp_ID"].apply(lambda x: stardict.get(x))

# clean up output to get unique values
q_nodup = qq.drop_duplicates()
collapsed = q_nodup.groupby("sample").first().reset_index()

# join to sample list 
all_samples_collapsed = pd.merge(samples, collapsed, on="sample", how = "left")

# output assigned species
all_samples_collapsed.to_csv(os.path.join(output_folder, "spp_assigned.tsv"), sep="\t", index=False)

# print fungi samples to separate file
fungi = ['Nakaseomyces glabratus', 'Candida albicans', 'Candida auris', 'Candida parapsilosis', 'Candida orthopsilosis']
fungi_df = qq[qq['spp_ID'].isin(fungi)]
fungi_df.to_csv(os.path.join(output_folder, "spp_fungi_samples.tsv"), sep="\t", index=False)
