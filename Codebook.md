Codebook for Brian Davies' Wearable Computing course project
============================================================

Processing Chain
----------------

This is implemented in run_analysis in the R file of the same name.

1. Load __test__ dataset as a frame using __assemble_dataset__
  1. Check availability of all files in __file_info__
  2. Load activity dta and convert from numerics to descriptive strings
  3. Load subject data
  4. Load feature data and add descriptive row headings
  5. Load sensor data, 9 sets of 128 measurements per experiment, generate headings
  6. As these are loaded, merge into a single frame
2. Repeat for __train__ dtaset
3. Merge __test__ and __train__ into a single frame
4. Optionally output a CSV with entire merged dataset
5. Select only activity and subject columns plus features ending in __-mean()__ and __-std()__
6. By default, output
7. Summarize by taking feature averages over activity and subject
8. By default, output

Output files
------------

The __means__ and __summary__ files are the defaults, but can be changed as input parameters
for __run_analysis()__. The full-dataset filename has to be specified using the __full_csv=\<string\>__
parameter of __run_analysis__ or it won't be written.

Parameter     |   Default name    |    Description
--------------|-------------------|---------------
__means_csv=__  |  __UCI_HAR_means.csv__   | One record per run, __subject__, __activity__ and all features ending in __-mean()__ and __-std()__
__summary_csv=__  |  __UCI_HAR_summary.csv__   | One record per __subject__+__activity__ combination, features summarized by average
__full_csv=__  | _blank_  | Full dataset, one record per run, all computed features and raw data

How to reload the files
-----------------------

Just use __read.csv()__ to replicate the dataframes thse files were written from.

Contents of the __full_csv=__ and means files
---------------------------------------------

These files contain one record per experiment, with the following fields. As described below, not
all fields are present in the __means_csv=__ file.

Field         |     Description
subject            | Numerical subject identifier
activity           | Factor describing activity
Features           | 561 fields with names like __tBodyAcc-mean()-X__ -- These are the computed features
Raw data           | 9 sets of 128 fields with names like __body_acc_x.001__.

The __means__ file contains only the features with names ending in __-mean()__ and __-std()__,
and no raw data.

The raw data represents 128 successive sets of measurements from three three-axis transducers used in the experiment.

Contents of the summary file
----------------------------

This summarizes the data in the __means__ file, aggregated by subject and activity and summarized as an average. The
column headings correspond to the __means__ file but there is only one record for each activity_subject pair.
