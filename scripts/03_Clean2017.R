############################################################################################################
#            Creating merge-ready 2017 verified feature dataset
############################################################################################################

# Goal
# Create an analysis-ready dataset of all features visited in Yambol in 2017 on the basis of FAIMS-dataset

# Requires couple prerequisites, such as 
# 0) loading the 2017 dataset which has been generated via FAIMS app and cleaned in Open Refine
# 1) dropping and renaming columns to achieve consistency between datasets, fix date formatting
# 2) aggregating notes/annotations into fewer columns as FAIMS data have LOTS of annotations
# 3) eliminating columns irrelevant for the master dataset 
# 4) cleaning up datatypes, and checking the consistency of classifications

# Library
library(tidyverse)
library(lubridate)

# Load the inputs
df_name <- c("mnd2017")
if (exists(df_name)){
  is.data.frame(get(df_name))
}  else source("scripts/01_LoadDataG.R")  # change to LoadData.R i

############################################################################################################
#    2017 DATASET 

# Drop and rename columns
m2017 <- mnd2017 %>% 
  dplyr::select(-one_of("uuid","HandheldGPSPoint", "Elevation", "Photo")) %>%  # Uuid is corrupted by excel, and other fields are managerial mostly (refer to sqlite)
  rename(TRAP=identifier, LU_Around = LanduseAroundMound, LU_Top=LanduseOnTopOfMound)   

# Clean up the Date which currently only contains day and month and needs appending 2017 to it
glimpse(m2017)
# Implement with paste() function
m2017 <- m2017 %>% 
  mutate(nDate = paste(m2017$Date, sep="-","2017")) %>% 
  mutate(Date= gsub("Sep","09", nDate)) %>% 
  dplyr::select(-nDate) 

m2017$Date 

# Shape the date in ymd format
m2017 %>% 
  mutate(Date=as.Date(Date, "%d-%m-%Y")) %>% 
  #mutate(Date=ymd(Date)) %>% 
  glimpse()

m2017 <- m2017 %>% 
  mutate(Date=as.Date(Date, "%d-%m-%Y")) 

# Aggregate notes to two columns (using https://stackoverflow.com/questions/50845474/concatenating-two-text-columns-in-dplyr)
# Look where annotations and notes are distributed >> 7 columns
m2017 %>% 
  dplyr::select(grep(" 2",names(m2017)), grep("[Nn]ote",names(m2017)))

# Unite them into two columns for damage and generate with unite(x, y, sep = ",", remove = TRUE, na.rm = TRUE) function
m2017 <- m2017 %>% 
  unite(AllNotes, c(grep("[Nn]ote",names(m2017))), sep = ",", remove = TRUE, na.rm = TRUE) 
m2017$AllNotes
m2017 <- m2017 %>% 
  unite(DamageNotes, c(grep(" 2",names(m2017))), sep = ",", remove = TRUE, na.rm = TRUE)  # Damage notes have "2" in column name from OpenRefine
m2017$DamageNotes  # we have reduced the initial 46 to 37 variables


# Check the levels of Type 
levels(as.factor(m2017$Type))

# Finished cleaning 2017
glimpse(m2017)
