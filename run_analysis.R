#Set your working directory before you do anything else
#setwd('your path name here')
#getwd('')

#Analysis done on mac OSX 10.10 using R version 3.2.2
#Please adjust directories or directory notation to fit windows if necessary

library(dplyr)

#Create the project directory and download the zip file
if (!dir.exists('project')){dir.create('project')}
projectURL <- paste0('https://d396qusza40orc.cloudfront.net/',
                     'getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip')
download.file(projectURL, destfile= './project/project.zip', method='curl')
datedownloaded = date()

#unzip the contents & download the dataset.
unzip('./project/project.zip', list=FALSE, exdir = './project')

#rename file and see what's in file
file.rename('./project/UCI HAR Dataset', './project/UCI_HAR_Dataset')
list.files('./project/UCI_HAR_Dataset')

###############Step 1: Merge datasets############################
#pull in the features.txt info for labels
features <- read.table('./project/UCI_HAR_Dataset/features.txt')[,2]

#construct each dataset by pulling in the X datasets with "features" as the column names, and then merge y and subject vectors named action and subject repsectively 
construct_data<- function (string){
    df_file <- paste0('./project/UCI_HAR_Dataset/', string,
                      '/X_', string,'.txt')
    action_file <- paste0('./project/UCI_HAR_Dataset/', string, 
                          '/Y_', string, '.txt')
    subject_file <- paste0('./project/UCI_HAR_Dataset/', string, 
                           '/subject_', string, '.txt')
    
    df <- read.table(df_file, sep = '', col.names = features)
    df$subject <- read.table(subject_file, sep='',  col.names="subject")[,1]
    df$action <- read.table(action_file, sep='', col.names='action')[,1]
    
    return (df)
}

test_df <- construct_data('test')
train_df <- construct_data('train')

#append the datasets on proper variables
appendedDF <- rbind(test_df, train_df)

rm(test_df, train_df, features)

##############################Step 2##########################################

#revist before submitting and make sure this is what they meant. 
df_names <- grep('*mean|*std', names(appendedDF), value=TRUE); df_names
df_names <- append(df_names, c('subject', 'action'))

#use df_names to select those variables
appendedDF <- appendedDF %>% select_(.dots=df_names)

rm(df_names)

#notice that this also satisfies step 4 as we assigned good names to the variables, though perhaps we could modify the column names some more. 


#############################Step 3##########################################
#use activity_labels.txt to match numbers in dataset to the activities 
activity <- read.table('./project/UCI_HAR_Dataset/activity_labels.txt'
                       ,sep='')

activity <- rename(activity, activity_performed = V2)

mergedDF <- merge(appendedDF, activity, by.x='action', by.y='V1')
#mergedDF$action <- NULL
mergedDF$activity_performed <- NULL
rm(activity, appendedDF)

############################Step 4############################################
#I believe this step was already completed in step 1 with using the features #vector as the header for the inputed datasets. However, we could expand on
#this and clean further if necessary. It's hard because there's the f vs. t
#aspect, the actual phenomena measured, X vs. Y vs. Z, and of course mean 
#vs. std dev. 

#Loop through and replace various components of the variable names rather than 
#perform them manually. Got the idea from:  
#http://stackoverflow.com/questions/9537797/r-grep-match-one-string-against-multiple-patterns
# remove f and t and replace with time and frequency, remove ...X,Y, or Z and
# replace with "_X,Y,Z", remove periods, upper case mean and upper case and
# expand on standard deviation.  

merged_names <- names(mergedDF); merged_names #already pretty solid

keywords <- c('^t', '^f', '\\.*X', '\\.*Y', '\\.*Z', '\\.', 'mean', 'std')
strings <- c('time', 'freq', '_X', '_Y', '_Z', '', 'Mean', 'StdDev')


for (i in 1:length(keywords)){
    merged_names <- gsub(keywords[i], strings[i], merged_names)
}

#make sure changes implemented 
merged_names  

#change original names of dataframe  
names(mergedDF) <- merged_names 

############################Step 5############################################
#group by activity and subject, and report the mean for each variable. 
meanDF <- mergedDF %>%
        group_by(subject, action) %>%
        summarise_each(funs(mean))

#check out the dataset 
head(tbl_df(meanDF))

#Should have 81 fields and 180 rows (6 actions by 30 subjects). 
dim(meanDF)#180

#Finally, write this dataset out into a csv file. 
write.csv(meanDF, "MeanData.csv")
#this step may have been irrelevant, I'm not sure. If not needed, comment out


########Uncomment the following line to delete everything from memory#########
rm(list = ls()); unlink('./project', recursive = TRUE)

##############################################################################
