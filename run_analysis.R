################################################################################
############################# run_analysis.R ###################################
### Constructs datasets for cell phone data from Samsung and export the data 
### into a csv file to be easily read in. This was part of a project for the 
### Coursera Getting and Cleaning Data course from JHU
################################################################################

# setwd("Your directory here if you want to specify it")

if (!require("data.table")) {
  install.packages("data.table")
  library(data.table)
}

construct_data<- function (string){
  # construct datasets based on string
  #
  # Args: 
  #   string: string indicating whether test or training set
  #
  # Returns:
  #   DT: a data.table of test or training data, depending on string entered
  df_file <- paste0('./project/UCI_HAR_Dataset/', string,
                    '/X_', string,'.txt')
    
  action_file <- paste0('./project/UCI_HAR_Dataset/', string, 
                        '/Y_', string, '.txt')
    
  subject_file <- paste0('./project/UCI_HAR_Dataset/', string, 
                         '/subject_', string, '.txt')
    
  DT <- fread(df_file, sep = ' ')
  DT$subject <- fread(subject_file, sep=' ')
  DT$action <- fread(action_file, sep=' ')
  setnames(DT, c(features, "subject", "action"))
    
  return (DT)
}

# Create the project directory
if (!dir.exists('project')){dir.create('project')}

#if directory empty, download zip file and unzip it
if (length(dir('./project')) == 0){
    
  projectURL <- paste0('https://d396qusza40orc.cloudfront.net/',
                       'getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip')
  download.file(projectURL, destfile= './project/project.zip', 
                method='curl')
  datedownloaded = date()

  # unzip the contents & download the dataset.
  unzip('./project/project.zip', list=FALSE, exdir = './project')

  # rename file
  file.rename('./project/UCI HAR Dataset', './project/UCI_HAR_Dataset')
}

# Uncomment to see what's in file
# list.files('./project/UCI_HAR_Dataset')

# pull in the features.txt info for labels
features <- read.table("./project/UCI_HAR_Dataset/features.txt", 
                       sep = " ", colClasses = "character")[,2]

# construct each dataset 
testDT <- construct_data('test')
trainDT <- construct_data('train')

# append the datasets on proper variables
appendedDT <- rbindlist(list(testDT, trainDT))

rm(testDT, trainDT, features)

# clean up the dt_names
dt_names <- grep('mean|std', names(appendedDT), 
                 value=TRUE, ignore.case = TRUE)
dt_names <- append(dt_names, c('subject', 'action'))

# use dt_names to select those variables, switch to data.table notation 
appendedDT <- appendedDT[, dt_names, with=FALSE]

rm(dt_names)

# use activity_labels.txt to match numbers in dataset to the activities 
activity <- read.table('./project/UCI_HAR_Dataset/activity_labels.txt',
                       sep='', col.names = c("action", "activity_performed"))

mergedDT <- merge(appendedDT, activity, by='action')

rm(activity, appendedDT)

# Loop through and replace various components of the variable names rather than
# perform them manually. 
  
merged_names <- names(mergedDT)

keywords <- c('^t', '^f', '\\.*X', '\\.*Y', '\\.*Z', '\\.', 'mean','std','-')
strings <- c('time', 'freq', 'X', 'Y', 'Z', '', 'Mean', 'StdDev', '_')

for (i in 1:length(keywords)){
    merged_names <- gsub(keywords[i], strings[i], merged_names)
}

# change original names of DT (double check this)
setnames(mergedDT, merged_names) 

# group by activity and subject, and report the mean for each variable. 
DT <- mergedDT[, lapply(.SD, mean), by=c('subject', 'action')]

# Finally, write this dataset out into a .txt file. 
write.table(DT, "MeanData.txt", sep=' ', row.names = FALSE)


# remove objects in memory
rm(list = ls())

# if you want to delete the project folder after running, 
# uncomment the following line:
# unlink('./project', recursive = TRUE)

##############################################################################
