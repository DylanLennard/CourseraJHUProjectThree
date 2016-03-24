# README  

### Technical Specs  
Analysis done on mac OSX 10.10 using R version 3.2.2. Please adjust directories or directory notation in run_analysis.R to fit windows if necessary.  

### Before running code
Explicitly set your working directory. You can do this in R yourself, or set pathname in the run_analysis.R

### Summary  
run_analysis.R transforms the Samsung Galaxy S cell phone acceleromter data so that it outputs a dataset which gives the mean of all fields measuring mean or standard deviation for all 30 subjects by each action they can perform. The code runs the following steps sequentially:  
1) creates the 'project' directory  
2) downloads the necessary zip file into the project directory  
3) unzips this file, and accesses necessary datafiles in new folder  
3) creates the merged test and train datasets with variable names    
4) appends these two datasets into one  
5) creates new dataset by extracting only variables involving mean or standard deviation of a variable referred to as the mean dataframe   
6) matches numbers in the activities files to their corresponding action (in other words, change values from numeric values to descriptive strings)  
7) further cleans the title of each variable  
8) creates a new dataset consisting of each subject and activity combination and mean values for each variable in the mean dataframe  

To run the dataset, simply make sure dplyr is installed on your machine, then run source('run_analysis.R') in R. The output will produce a csv file with the dataset which is a mean of all variables representing means and standard deviations.  

To see the original datasets that were used in the creation of the output of this script, simply comment out the final line of code in run_analysis.R, and run the script. 

### Variables  
For information on the variables and names, see the codebook.  