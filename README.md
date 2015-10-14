---
output: html_document
---
## README.md

The code, run_analysis.R, is extensively commented.  


#### Part One
The data files are all text files.  Unix and Unix-like systems have a rich set of mature text manipulation and managements tools. Two of those tools, sed and cat, are used here to clean and manipulate the data and associated files.  Those tools are called via the R system() command. On Windows machines the cygwin set provides similar capabilities.  

The initial file cleaning steps are done to remove undesired, inconsistent spacing in the the data files and to increase the human readability of the feature.txt file. The modified features.txt file is saved as colNames.txt. The two data files are then concatenated to form a single file for the data, aggregateData.txt. The y_train.txt and y_test.txt file are concatenated to produce the acivities.txt file. The subject_train.txt and subject_test.txt files are concatenated to produce the subject.txt file. These steps facilitate the subsequent reading and manipulation of the files using the data.table library. The use of the data.table library is desirable due to the increased versatility of the data.table functions over those of the data frame. Further, the data.table functions improve execution speed and use less memory.

All produced files where checked to insure complete data.  No missing data was found. The colNames.txt was found to have three sets of duplicate file names. This is potentially a problem, but was not encountered as the duplicated columns were not used to generate the desired subset. Therefore, the duplicates were ignored.

#### Part Two

The aggregateData.txt, activities.txt, subject.txt and colNames.txt are then loaded using the data.table fread command.

The colName.txt file is used to name the data columns of the aggregateDT.

The activities file is modified to replace the numerical activity entries with human readable text entries. The activities and subjects are each added to the aggregrateDT file to become the 562 and 563 variables in each record observation.

Next the aggregateDT is subsetted to obtain a data table which contains the columns that are the mean and std of each measurement. Grep is used to return the column numbers of the mean and std columns.  These are used as an index to subset the aggregateDT data table.

A double key, subjects and activities, is set for the aggregateDT table. The grouping and use of functions in the column selection produces means for each activity for each subject. Here is an important reason the previous work was done to allow the data.table library to be used.  One command gives the desired clean, tidy data table, meanDT. It has 180 records, 6 activity records for each of the 30 subjects.  This is saved to disk as a text file (the objective of the assignment).

#### Part Three

The last 6 lines of code are used to demonstrate an example of the contents of the meanDT data table. The meanDT data.tables is first removed from the work space, then fread from the saved file back into the work space. Several rows and columns of each are then read to stdout to show the results of having generated the data.table.




