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

    #get the download date
    date = response.headers['Date']
    del(response)

    #unzip
    zf = zipfile.ZipFile('./project/project.zip')
    zf.extractall('./project')


    #rename the unzipped file
    os.rename('./project/UCI HAR Dataset',
        './project/UCI_HAR_Dataset')

#see what's in the file
#os.listdir('./project')

####################Step 1: Combine Datasets########################################
features = pd.read_table('./project/UCI_HAR_Dataset/features.txt',
                header = None, delim_whitespace=True,
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

####################Step 2: Grab only mean/std. dev data############################

# try to restructure using lambda function perhaps, or list comprehension 
# feature_test = filter(lambda x:
#                 re.search(r'[*mean|*std|\bsubject\b|\baction\b]', x),
#                     features)
# feature_test = filter(lambda x: re.search(r'[mean]', x), features)
    
feature_test = []
for item in features:
    match = re.search(r"[M|m]ean|[S|s]td", item)
    if match:
        feature_test.append(item)
        
features = feature_test
features.append('action')
features.append('subject')
appendedDF = appendedDF[features]

####################Step 3: assign labels and subjects to data######################
activity = pd.read_table('./project/UCI_HAR_Dataset/activity_labels.txt',
                names = ["action","activity_performed"], header = None, 
                delim_whitespace=True,squeeze=True)

mergedDF = pd.merge(appendedDF, activity,  on='action', how='inner')

del(activity, appendedDF)

####################Step 4: Clean up names in data##################################
merged_names = mergedDF.columns.values

keywords = ['^t', '^f', '\\.*X', '\\.*Y', '\\.*Z', '\\.', 'mean', 'std', '-']
strings  = ['time', 'freq', 'X', 'Y', 'Z', '', 'Mean', 'StdDev', '_']

for i in xrange(len(merged_names)):
    for j in xrange(len(keywords)):
        merged_names[i] = re.sub(keywords[j], strings[j], merged_names[i])

mergedDF.columns = merged_names

####################Step 5: Get dataset of means of each var########################
#group by activity and subject, and report the mean for each variable. 
meanDF = mergedDF.groupby(["subject", 'action']).mean()


###################Write out a text file of data####################################
meanDF.to_csv(r'./project/MeanData.txt', header= meanDF.columns.values, \
                index=None, sep=' ', mode='w')

####################Remove Objects from memory######################################
for name in dir():
    if not name.startswith('_'):
        del globals()[name]

#if you want to delete the project folder after running, 
#uncomment the following line:
#fill with command to delete contents and folder in python 

##############################################################################