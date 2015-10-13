
# The following code is in three parts.
# 	
#	Part one which is immediately below consists of several
#		calls to the system utilities sed and cat.
#   		It is recognized that the below operations
#		could be done using R functions rather than system
#		calls. (This could best be done via shell
#		scripting.) The approach here is to use the simpliest
#		tool which will accomplish the task.  Sed and cat
#		are simple, reliable, and effective.  (Windows 
#		machines would require that a version of these
#		unix utilities be loaded.)
#
#	Part two begins with the data.table function fread.
#		It should be noted that there is a column 
#		(variable) labeling error problem, as there are
#		a number of columns with duplicate names.  None
#		of these, however, are columns that are included
#		in the final data subset.  Therefore, the labeling
#		errors are ignored.  Were these to be included
#		in any analysis, this would have to be addressed.
# 
#	Part three is demo code to show the output of the
#		code developed in part two.


# Part one.
library(data.table)

# The following line of code is a regular expression
#	that is simply written to disk as a text file.	 
#   In the next 2 lines this regular expression
#	text file is passed to sed which then uses
#   it as instructions to clean the training
#	and testing data sets.
write("/^[ ]*/s///\n/  /s// /g","dataCmds.txt")

# This line cleans the training data as noted above.
system("sed -f dataCmds.txt train/X_train.txt > trainData.txt")

# This line cleans the testing data as noted above
system("sed -f dataCmds.txt test/X_test.txt > testData.txt")

# This line concatenates the two cleaned data files into a single file
system("cat trainData.txt testData.txt > aggregateData.txt")

# This is a 7 line set of regular expressions that are passed to
#	sed to do the following to the features.txt file:
#		Remove empty parenthesis
#       Replace commas with periods
#       Replace dashes with periods
#       Replace the fBody abbreviation at the beginning of names with the string freqBody
#       Replace the tBody abbreviation at the beginning of names with the string timeBody
#       Replace the tGravity abbreviation at the beginning of names with the string timeGravity
#       Remove a stray right parenthesis in line 556	 
write("/([ ]*)/s///g\n/,/s//./g\n/-/s//./g\n/fBody/s//freqBody/\n/tBody/s//timeBody/\n/tGravity/s//timeGravity/\n556 s/n)./n./","featureCmds.txt")

# This executes the cleaning of the feature.txt file producing the colNames.txt file.
#	It uses the featureCmds text file produced and written to disk
#	as noted in the obove comments
system("sed -f featureCmds.txt features.txt > colNames.txt")

# These two lines concatenate the two subject 
#	and activities files to a single 10299
#   line subject.txt file 
#	and an activities.txt file
system("cat train/subject_train.txt test/subject_test.txt > subjects.txt")
system("cat train/y_train.txt test/y_test.txt > activities.txt")

# Part two
# Get and read the single aggregated data file.
aggregateDT<-fread("aggregateData.txt")

# Get and read the activities file
activities<-fread("activities.txt")

# Get and read the subject file
subjects<-fread("subjects.txt")

# Get the column names.
colNamesDT<-fread("colNames.txt")
colNames<-colNamesDT[,V2]

# Set the column names for the aggregate data file
setnames(aggregateDT,colNames)

# The activities_labels.txt file has this sequence of activities associated
#	with the numbers 1 through 6. The formatting of the file is not
#	consistent with the the formatting used in the rest of this
#	data table.  Rather than using several lines of code to correct the 
#	formatting, it is more straight forward to simply use the following
#	to produce the correctly formatted activity vector.
activityVector<-c("Walking","WalkingUpStairs","WalkingDownStairs","Sitting","Standing","Laying")
activities<-sapply(activities,function(event) {activities[activities==event]<-activityVector[event]} )

# The following 2 lines add the activities and subjects columns to the table;
#	it now has 563 columns.  The table is clean, tidy, and ready for analysis.
aggregateDT[,activities:=activities]
aggregateDT[,subjects:=subjects]

# Gets the column numbers of the columns that contain the mean, std, activities, and subjects.
indexColumnsVec<-sort(c(grep("\\bmean\\b|\\bstd\\b|^activities|^subjects",names(aggregateDT))))

# Subsets the aggregateDT to the meanDT: it contains means, std, subjects, and activities columns.
meanDT<-aggregateDT[,indexColumnsVec,with=FALSE]

# Sets a double key on the meanDT data table.
#	This automatically sorts the data table first
#	by subjects then by activities.
setkey(meanDT,subjects,activities)

# The key is then used to aid the calculation of the mean of each 
# 	variable for each subject, thus producing the desired tidy data table.
meanDT<-meanDT[,lapply(.SD,mean),by=list(subjects,activities)]

# Modify the column names to reflect the variable contents
meanDTColNames<-names(meanDT)
meanDTColNames[3:68]<-sub('^',"Mean\\.",meanDTColNames[3:68])

# Set the modified column names
setnames(meanDT,meanDTColNames)

# Now write the table to a text file.  The meanDT data.table is the desired
#	objective of this code (the assignment).
write.table(meanDT,"meanDT.txt",row.names=FALSE)


# Part three
# The following is Demonstration code.

workSpace<-ls()
if("meanDT" %in% workSpace){rm(meanDT,workSpace)}
colNums<-c(1:3,68)
rowNums<-c(1:12,180)
meanDT<-fread("meanDT.txt")
meanDT[rowNums,colNums,with=FALSE]

# This produces the first 12 rows and the last row 
#	of columns 1 through 3, and 68, the last column
#
#     subjects        activities Mean.timeBodyAcc.mean.X Mean.freqBodyBodyGyroJerkMag.std
#  1:        1            Laying               0.2215982                       -0.9326607
#  2:        1           Sitting               0.2612376                       -0.9870496
#  3:        1          Standing               0.2789176                       -0.9946711
#  4:        1           Walking               0.2773308                       -0.3816019
#  5:        1 WalkingDownStairs               0.2891883                       -0.3919199
#  6:        1   WalkingUpStairs               0.2554617                       -0.6939305
#  7:        2            Laying               0.2813734                       -0.9894927
#  8:        2           Sitting               0.2770874                       -0.9896329
#  9:        2          Standing               0.2779115                       -0.9777543
# 10:        2           Walking               0.2764266                       -0.5581046
# 11:        2 WalkingDownStairs               0.2776153                       -0.3436990
# 12:        2   WalkingUpStairs               0.2471648                       -0.6218202
# 13:       30   WalkingUpStairs               0.2714156                       -0.7913494

