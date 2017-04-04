install.packages("dplyr")
library("dplyr")

# 0: Load the data in RStudio
df_Features <- read.csv("UCI HAR Dataset/features.txt", sep = "", header = FALSE, col.names = c("featureId", "featureLabel"))
df_Features <- cbind(df_Features, featureLabelsClean = gsub("\\(\\)-|\\(\\)|-", "_", df_Features$featureLabel))
df_X_Test <- read.csv("UCI HAR Dataset/test/X_test.txt", sep = "", header = FALSE, col.names = df_Features$featureLabelsClean)
df_X_Train <- read.csv("UCI HAR Dataset/train/X_train.txt", sep = "", header = FALSE, col.names = df_Features$featureLabelsClean)
df_SubjectNames_Test <- read.csv("UCI HAR Dataset/test/subject_test.txt", sep = "", header = FALSE, col.names = c("subjectNames"))
df_SubjectNames_Train <- read.csv("UCI HAR Dataset/train/subject_train.txt", sep = "", header = FALSE, col.names = c("subjectNames"))
df_Activity_Test <- read.csv("UCI HAR Dataset/test/y_test.txt", sep = "", header = FALSE, col.names = c("activity"))
df_Activity_Train <- read.csv("UCI HAR Dataset/train/y_train.txt", sep = "", header = FALSE, col.names = c("activity"))
df_Activity_Labels <- read.csv("UCI HAR Dataset/activity_labels.txt", sep = "", header = FALSE, col.names = c("activity", "activityLabel"))

# 1: Join Activity with Activity Labels to load activityLabels
df_Activity_Test <- left_join(df_Activity_Test, df_Activity_Labels)
df_Activity_Train <- left_join(df_Activity_Train, df_Activity_Labels)

#2 Append dataSrc, subjectNames to the data tables
df_X_Test <- cbind(dataSrc = data.frame(1:length(df_SubjectNames_Test$subjectNames), "Test")$X.Test, df_SubjectNames_Test, df_Activity_Test, df_X_Test)
df_X_Train <- cbind(dataSrc = data.frame(1:length(df_SubjectNames_Train$subjectNames), "Train")$X.Train, df_SubjectNames_Train, df_Activity_Train, df_X_Train)

#3 Merge Test and Train data
df_X <- bind_rows(df_X_Test, df_X_Train)

#4 Calculate and add Mean and SD for the measurements as new columns
df_X_Mean_SD <- select (df_X, starts_with("t")) %>% summarise_all( funs(mean, sd))
df_X <- cbind(df_X, df_X_Mean_SD)

#5 Create a dataset with averages of each measurement for each subject and activity combination
df_Avg_X <- df_X %>% group_by (dataSrc, subjectNames, activity, activityLabel) %>% summarise_all(funs(mean = mean))
#View(df_Avg_X)

#6 Write back to CSV file
write.csv(df_X, file = "HAR.csv")
write.csv(df_Avg_X, file = "HAR_Avg.csv")
