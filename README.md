# README  

## Summary  
run_analysis.R runs a script which transforms the data using no manual steps. The code runs in the following sequential order:  
1) creates a project directory  
2) downloads the necessary zip file into the project directory  
3) unzips this file, and accesses necessary datafiles in new folder  
3) creates the merged test and train datasets with variable names    
4) appends these two datasets into one  
5) creates new dataset by extracting only variables involving mean or standard deviation of a variable referred to as the mean dataframe   
6) matches numbers in the activities files to their corresponding action (in other words, change values from numeric values to descriptive strings)  
7) further cleans the title of each variable  
8) creates a new dataset consisting of each subject and activity combination and mean values for each variable in the mean dataframe  

