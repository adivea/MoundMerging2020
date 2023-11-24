############################################################################################################
#             Creating merge-ready 2018 verified feature dataset
############################################################################################################

# Goal
# Create an analysis-ready dataset of all features visited in Yambol in 2018 on the basis of FAIMS-dataset

# Requires couple prerequisites, such as 
# 0) loading the 2018 dataset which has been generated via FAIMS app and cleaned in Open Refine
# 1) dropping and renaming columns to achieve consistency between datasets, fix date formatting 
# 2) aggregating notes/annotations into fewer columns as FAIMS data have LOTS of annotations
# 3) eliminating columns irrelevant for the master dataset 
# 4) cleaning up datatypes, and checking the consistency of classifications

# Library
library(tidyverse)
library(lubridate)

# Load the inputs
df_name <- c("mnd2018")
if (exists(df_name)){
  is.data.frame(get(df_name))
}  else source("scripts/01_LoadDataG.R")

############################################################################################################
####              2018 DATASET 

names(mnd2018)

# Drop and rename columns
m2018 <- mnd2018 %>% 
  select(-one_of("File","uuid", "HandheldGPSPoint", "Elevation", "Photo", "modifiedBy", "modifiedAtGMT", "BurialMoundAuthor")) %>% 
  rename(TRAP=identifier, Timestamp=createdAtGMT, Type=Type_Adela, LU_Around = LanduseAroundMound, LU_Top=LanduseOnTopOfMound)# Uuid is corrupted by excel, and other fields are managerial mostly (refer to sqlite)

# Fix date
m2018 <- m2018 %>% 
  mutate(Date = date(Timestamp)) %>% 
  mutate(Date = ymd(Date))

# Aggregate notes to a single column (using https://stackoverflow.com/questions/50845474/concatenating-two-text-columns-in-dplyr)

# Look where notes are distributed > 12 notes columns here
m2018 %>% 
  select(grep("[Nn]ote",names(m2018)))

# I wish to distinguish between generic notes and damage comments
allnotes <- names(m2018[grep("[Nn]ote",names(m2018))])[c(1,6,2,3,4,5,7)] # generic notes reordered
damagenotes <- names(m2018[grep("[Nn]ote",names(m2018))])[8:12] # condition-related notes

# Apply these column names vectors to aggregate the columns as desired
m2018 <- m2018 %>% 
  unite(AllNotes, all_of(allnotes), sep = ",", remove = TRUE, na.rm = TRUE) 
m2018 <- m2018 %>% 
  unite(DamageNotes, all_of(damagenotes), sep = ",", remove = TRUE, na.rm = TRUE)  # Damage notes have "2" in column name from OpenRefine
dim(m2018)  # we have reduced the initial 58 columns to 40


rm(allnotes, damagenotes)

# Check Type
levels(as.factor(m2018$Type)) # there are some inconsistencies with 2009-2017, best fixed at master level

# All done with 2018
glimpse(m2018)

