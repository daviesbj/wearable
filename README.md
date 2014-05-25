wearable
========

Wearable accelerometer analysis

All the real work is in __wearable_project_log.Rmd__

See my __Codebook.md__ for a description of the contents of the output files

Instructions to reproduce my work
---------------------------------

1. Clean out your environment
2. Load and run the file __run_analysis.R__. This will define a function __run_analysis__ and a few auxiliary functions.
3. Download the Samsung data. It comes in a file called __UCI HAR Dataset.zip__.
4. Save it by itself in a fresh directory. No need to unzip!
5. setwd() to that directory in R
6. Say __run_analysis()__ and admire the progress messages (I hope!) and ignore the warnings.

You will get a lot of progress messages. _There are also some warnings in the final phase of the analysis,
the calculation of aggrgates, which I haven't been able to eliminate but which are harmless_.

At the end, you should have the following files:

File                |     Contents
--------------------|---------------------------------------------------------------
UCI_HAR_means.csv   | Dataset stripped down to just the -means() and -std() features
UCI_HAR_summary.csv | Dataset further summarized to averages over subsject and activity




