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
--------------------|-----------------------------------------------------------------
UCI_HAR_means.csv   | Dataset stripped down to just the -means() and -std() features
UCI_HAR_summary.csv | Dataset further summarized to averages over subject and activity

Note on interpretation of the assignment
----------------------------------------

I assumed the instruction _Extracts only the measurements on the mean and standard deviation for each
measurement_ meant to select only the columns corresponding to features ending in __-mean()__ and __-std()__. These
come in pairs, one of each. There are also features like __fBodyBodyGyroJerkMag-meanFreq()__ and __angle(Z,gravityMean)__
that seem differently specied. If it were necessary to include them, the place to make the necessary changes
is highlighted in __run_analysis.R__


