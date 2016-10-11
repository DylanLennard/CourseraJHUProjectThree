import os
import pandas as pd
import numpy as np
#from numpy import loadtext
import requests, zipfile, StringIO, re
os.getcwd()
home = os.path.expanduser("~")
os.chdir(home+"/Desktop/Statistical_Programming/"+
            "Coursera/Getting_And_Cleaning_Data/Project_Three")
#dir = 'project'

URL = 'https://d396qusza40orc.cloudfront.net/' +\
    'getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

#create directory if it doesn't exist
if not os.path.exists('./project'):
    os.makedirs('project')

os.listdir("./")

#if project folder empty, download file
if not os.path.exists('./project/UCI_HAR_Dataset'):

    #download zip and write to disk
    print "This download will take a while..."
    response = requests.get(URL)
    with open('./project/project.zip','wb') as fout:
        fout.write(response.content)
    del(response)

    #get the download date
    date = response.headers['Date']

    #unzip
    zf = zipfile.ZipFile('./project/project.zip')
    zf.extractall('./project')


    #rename the unzipped file
    os.rename('./project/UCI HAR Dataset',
        './project/UCI_HAR_Dataset')

#see what's in the file
#os.listdir('./project')

############Step 1: Merge Datasets###########################

features = pd.read_table('./project/UCI_HAR_Dataset/features.txt',
                header = True, delim_whitespace=True,
                usecols=[1], squeeze=True)



def construct_data(string):
    df_file = './project/UCI_HAR_Dataset/'+ string+'/X_'+ \
                    string+'.txt'
    action_file = './project/UCI_HAR_Dataset/'+string+'/Y_'+ \
                        string+'.txt'
    subject_file = './project/UCI_HAR_Dataset/'+string+'/subject_'+\
                        string+'.txt'

    df = pd.read_table(df_file, delim_whitespace=True,
                    header = None, names = features)
    df['subject'] = pd.read_table(subject_file, delim_whitespace=True,
                    squeeze=True,
                    header = None, names=['subject'])
    df['action'] = pd.read_table(action_file, delim_whitespace=True,
                    squeeze=True,
                    header = None, names=['action'])

    return df

test_df = construct_data('test')
train_df = construct_data('train')

appendedDF = test_df.append(train_df)


#remove unnecessary objects from memory
del(test_df, train_df)


#later on to get column names
#list(df_name.columns.values)

################Step 2: Grab only mean/std. dev data###########

##figure out why this isn't working, also figure out why GREP didn't catch
##some of the variables that this one is catching.
feature_test = filter(lambda x:
                re.search(r'[*mean|*std|\bsubject\b|\baction\b]', x),
                    features)
feature_test = filter(lambda x: re.search(r'[mean]', x), features)

feature_test = []
for item in features:
    print re.search(r'[mean]', item)


####################Step 3: assign labels and subjects to data##########
# activity <- read.table('./project/UCI_HAR_Dataset/activity_labels.txt'
#                       ,sep='')

activity = pd.read_table('./project/UCI_HAR_Dataset/activity_labels.txt',
                header = None, delim_whitespace=True,
                usecols=[1], squeeze=True)

# activity <- rename(activity, activity_performed = V2)

# mergedDF <- merge(appendedDF, activity, by.x='action', by.y='V1')

# mergedDF$activity_performed <- NULL


################Step 4: Clean up names in data################


##############Step 5: Get dataset of means of each var########


###########WRite out a text file of data from step 5##########

#########Remove Objects from memory#######################
