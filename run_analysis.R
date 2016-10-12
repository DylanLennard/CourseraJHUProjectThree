#setwd('your path name here')
#Install dplyr if not already installed on computer, then load it 
if (!require("dplyr")) {
    install.packages("dplyr")
}
library(dplyr)

if (!require("data.table")) {
    install.packages("data.table")
}
library(data.table)


#Create the project directory
if (!dir.exists('project')){dir.create('project')}

#if directory empty, download zip file and unzip it
#fix this to look for the actual zip file
if (length(dir('./project')) == 0){
projectURL <- paste0('https://d396qusza40orc.cloudfront.net/',
                     'getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip')
download.file(projectURL, destfile= './project/project.zip', method='curl')
datedownloaded = date()

#unzip the contents & download the dataset.
unzip('./project/project.zip', list=FALSE, exdir = './project')

#rename file
file.rename('./project/UCI HAR Dataset', './project/UCI_HAR_Dataset')
}

#Uncomment to see what's in file
#list.files('./project/UCI_HAR_Dataset')

###############Step 1: Merge datasets############################
#pull in the features.txt info for labels
# features <- read_delim('./project/UCI_HAR_Dataset/features.txt',
#                        delim = ' ', col_names = FALSE)[,2]

features <- fread("./project/UCI_HAR_Dataset/features.txt", 
                  sep = " ", select = 2)

#construct each dataset by pulling in the X datasets with "features" as the
#column names, and then merge y and subject vectors
construct_data<- function (string){
    df_file <- paste0('./project/UCI_HAR_Dataset/', string,
                      '/X_', string,'.txt')
    action_file <- paste0('./project/UCI_HAR_Dataset/', string, 
                          '/Y_', string, '.txt')
    subject_file <- paste0('./project/UCI_HAR_Dataset/', string, 
                           '/subject_', string, '.txt')
    
    df <- fread(df_file, sep = ' ', col.names = features)
    df$subject <- fread(subject_file, sep=' ', col.names="subject")[,1]
    df$action <- fread(action_file, sep=' ', col.names='action')[,1]
    
    return (df)
}

test_df <- construct_data('test')
train_df <- construct_data('train')

#append the datasets on proper variables
appendedDF <- rbind(test_df, train_df)

rm(test_df, train_df, features)

##############################Step 2##########################################

df_names <- grep('mean|std', names(appendedDF), 
                 value=TRUE, ignore.case = TRUE)
df_names <- append(df_names, c('subject', 'action'))

#use df_names to select those variables
appendedDF <- appendedDF %>% select_(.dots=df_names)

rm(df_names)

#############################Step 3##########################################
#use activity_labels.txt to match numbers in dataset to the activities 
activity <- read.table('./project/UCI_HAR_Dataset/activity_labels.txt'
                       ,sep='')

activity <- rename(activity, activity_performed = V2)

mergedDF <- merge(appendedDF, activity, by.x='action', by.y='V1')

mergedDF$activity_performed <- NULL
rm(activity, appendedDF)

############################Step 4############################################
#Loop through and replace various components of the variable names rather than 
#perform them manually. Got the idea from:  
#http://stackoverflow.com/questions/9537797/r-grep-match-one-string-against-multiple-patterns
  
merged_names <- names(mergedDF)

keywords <- c('^t', '^f', '\\.*X', '\\.*Y', '\\.*Z', '\\.', 'mean', 'std')
strings <- c('time', 'freq', '_X', '_Y', '_Z', '', 'Mean', 'StdDev')

for (i in 1:length(keywords)){
    merged_names <- gsub(keywords[i], strings[i], merged_names)
}

#change original names of dataframe  
names(mergedDF) <- merged_names 

############################Step 5############################################
#group by activity and subject, and report the mean for each variable. 
meanDF <- mergedDF %>%
        group_by(subject, action) %>%
        summarise_each(funs(mean))

#Finally, write this dataset out into a .txt file. 
write.table(meanDF, "MeanData.txt", sep=' ', row.names = FALSE)


######################Removing files and Objects###############################
#remove objects in memory
rm(list = ls())

#if you want to delete the project folder after running, 
#uncomment the following line:
#unlink('./project', recursive = TRUE)

##############################################################################
