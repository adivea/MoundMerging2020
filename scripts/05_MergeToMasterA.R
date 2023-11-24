############################################################################################################
#                                Creating MASTER verified feature dataset
############################################################################################################

# Goal
# Create a master dataset of all visited features in the Yambol province and surroundings from 2009-2018. 
# Such dataset can be used to generate subset data such as all visited features in Yambol, 
# all potential mounds in Yambol and surroundings, and all potential and all confirmed mounds in Yambol.
# This master dataset can be joined with spatial coordinates from GIS and used for analyses ranging from
# vulnerability assessment to temporal prediction and RS feasibility

# Prerequisites 
# 1) previously cleaned merging-ready datasets from 2009-2022 with shared column names
# 2) spatial data from GIS that contains TRAP IDs for 2009-2010 data
# 3) consistent but not necessarily perfect column content in 1 and 2

# Process 
# 1) load previously cleaned merging-ready datasets from 2009-2022 with shared column names
# 2) merge to create 2009-2022 master dataset with at least 10 essential columns  
# 3) merge to create 2017-2022 FAIMS master dataset with all consistent columns
# 4) do basic streamlining


# Library
library(tidyverse)
library(lubridate)
library(here)

################################## LOAD DATA ######################################################

# Load the inputs
<<<<<<< HEAD:scripts/05_MergeToMasterA.R
df_name <- c("m2009","m2010","m2017","m2018", "m2022")
script <- c("03_Clean2009.R","03_Clean2010.R","03_Clean2017.R","03_Clean2018.R","03_Clean2022.R")
=======
gs4_auth(email = adela@faims.edu.au) # select Google account with which you are downloading data
df_name <- c("m2009","m2010","m2017","m2018")
script <- c("03_Clean2009.R","03_Clean2010.R","03_Clean2017.R","03_Clean2018.R")
>>>>>>> 8571bf5677c420dec659bc30fe53c19d61118a7e:scripts/05_MergeToMaster.R
for (i in df_name){
   if (exists(i)){
    is.data.frame(get(i))
  }  else {
    source(paste0("scripts/",(script[contains(gsub("m","", i), vars = script)])))
  }
}

## Inputs - check what they look like at this point
colnames(m2009)  # 2009 dataset cleaned in GoogleDocs
colnames(m2010) # 2010 only mounds (n=406) based on TRAP number and left join to adela:  conservative dataset
colnames(m2017)  # 2017 FAIMS-collected features (413)
colnames(m2018)  # 2018 mounds (282)
colnames(m2022)  # 2022 FAIMS-collected features (310), 47 columns

#################################  REVIEW DATA AND GET SHARED COLUMNS ########################################################m2009
 
# There are 12 shared columns between 2010 and 2009 
dim(m2010) # 30 columns in 2010 dataset
names(m2009)[which(names(m2009)%nin%names(m2010))] # which are not shared?
m2009$TopoID 

# There are 11 shared columns between 2018 and 2009 
dim(m2018) # 40 columns in 2018 dataset
names(m2009)[which(names(m2009)%nin%names(m2018))]  # which are not shared?

# There are 11 shared columns between 2017 and 2009 
dim(m2017) # 38 columns

# There are 36 shared columns between 2018 and 2017 
dim(m2018) # 40 columns in 2018 dataset
dim(m2017) # 37 columns in 2017 dataset
names(m2018)[which(names(m2018)%nin%names(m2017))]

names_all <- names(m2009)[which(names(m2009)%in%names(m2017))]  # 11 shared columns (essential ones in there)
names_manual <- names(m2009)[which(names(m2009)%in%names(m2010))] # 12 shared in 2009-2010, (TopoID being extra)
names_faims <- names(m2018)[which(names(m2018)%in%names(m2017))] # 36 shared columns in 2017-2018 (richer data)

m2018[, names_all]

####################################  MASTER M DATASET FOR ALL SEASONS ############################################

## MASTER DATASET - conservative selection of mostly mounds in 2009-2010, liberal features in 2017-2018

m = NULL
m <- rbind(m2022[, names_all], m2010[, names_all], m2017[, names_all], m2018[, names_all],m2009[, names_all])
dim(m)

glimpse(m)
glimpse(m2009)
glimpse(m2010[, names_all])
glimpse(m2017[, names_all])
glimpse(m2018[, names_all])
glimpse(m2022[, names_all])
#write_csv(m, "output_data/merged2023.csv") # through 2022; previous merged.csv was for 2009-18

# 1181 records in the 2009-2018 master dataset with 11 variables
# 1491 records in the 2009-2022 master dataset
####################################  MASTER M_FAIMS DATASET FOR FAIMS SEASONS 2017 - 2018 #####################################

# MASTER DATASET FOR FAIMS YEARS

m_Faims <- NULL
m_Faims <- rbind(m2017[, names_faims], m2018[, names_faims],m2022[, names_faims])
dim(m_Faims)  # 1005 records and 36 cols in 2022
glimpse(m_Faims)
write_csv(m_Faims, "output_data/mergedfaims2023.csv") 

####################################  STREAMLINE M INTO MASTER FOR ALL SEASONS ##################################################

####  We will need fields such as Type, Height, Landuse and others streamlined before analysis

## Create a new object called master so as to differentiate streamlined data from the product of merger
master <- m

## Streamline Type
levels(as.factor(master$Type))
master$Type[master$Type=="Uncertain Mound"] <- "Burial Mound?"

## Streamline Landuse 
master %>% 
  group_by(LU_Around) %>% 
  tally()

master %>% 
  group_by(LU_Top) %>% 
  tally()

master$LU_Around[master$LU_Around =="Fallow"] <- "Annual agriculture"
master$LU_Around[master$LU_Around =="Annual"] <- "Annual agriculture"
master$LU_Around[master$LU_Around =="Pasture/Scrub"] <- "Scrub"

master$LU_Top[master$LU_Top =="Fallow"] <- "Annual agriculture"
master$LU_Top[master$LU_Top =="Annual"] <- "Annual agriculture"
master$LU_Top[master$LU_Top =="Annual/Pasture"] <- "Annual agriculture"
master$LU_Top[master$LU_Top =="Pasture/Scrub"] <- "Scrub"


# Fill in missing Landuse - substituting with Adela's RS values where missing in Bara's
# 45 mounds lack LU values
master %>% 
  group_by(LU_Around) %>% 
  tally()

master %>% 
  group_by(LU_Top) %>% 
  tally()

# lets see where LU is missing
LUmissing <- master %>% 
  filter(is.na(LU_Around)) %>% 
  select(TRAP)

LUTmissing <- master %>% 
  filter(is.na(LU_Top)) %>% 
  select(TRAP)

LUmissing$TRAP%in%LUTmissing$TRAP

LUmiss_subs <- m2010 %>% 
  filter(TRAP %in% LUmissing$TRAP) %>% 
  select(TRAP, LU_AroundRS, LU_TopRS) %>% 
  rename(LU_Around =LU_AroundRS,LU_Top=LU_TopRS)
 
# # DOES NOT WORK YET: Apply rows_patch(x,y) to update/change NA values in LU_Around and LU_Top in master dataset
# ?rows_update
# 
# # select the rows from master dataset which contain the NAs
# names(master[which(is.na(master$LU_Around)),c(1,4,5)])
# master[which(master$TRAP%in%LUTmissing$TRAP),c(4)]
# # confirm the column names in both datasets are identical
# names(LUmiss_subs)%in%names(master[which(is.na(master$LU_Around)),c(1,4,5)])
# 
# # rows_patch() is not working
# # master %>% 
# #   rows_patch(tibble(
# #     a = master[which(is.na(master$LU_Around)),c(1,4,5)],  
# #     b = LUmiss_subs), )
# #     #by = c("TRAP","TRAP")) # R complains so I hid the by =
# #                     # R complains that columns in y are not contained in x (they are)
# End of row_patch experiment

# Use case_when to update specific values by TRAP IDs, 

# add also "Nodata" TRAPids to the LUmiss_subs vector with NA TRAP ids
ableftj %>% 
  filter(LandUseAround == "Nodata") %>% 
  select(TRAP, LandUseAround,Landuse_AroundRS, Landuse_TopRS)

# in LU Around  
LUmiss_subs$LU_Around
scrub <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Around == "Scrub")], 9411,9412)
annual <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Around == "Annual agriculture")],9419,9423)
pasture <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Around == "Pasture")],9420)

# in LU Top
levels(as.factor(LUmiss_subs$LU_Top))
Scrub <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Top == "Scrub")], 9411,9419)
Annual <- LUmiss_subs$TRAP[which(LUmiss_subs$LU_Top == "Annual agriculture")]
Pasture <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Top == "Pasture")], 9412,9420,9423)

master <- master %>% 
  #filter(is.na(master$LU_Around)|is.na(master$LU_Top)) %>% 
  mutate(LU_Around = case_when(TRAP%in%scrub ~  "Scrub", 
                              TRAP%in%pasture ~ "Pasture",
                              TRAP%in%annual ~ "Annual agriculture", 
                              TRAP%nin%c(scrub,pasture,annual)~ LU_Around), # LU_Around streamlined
         LU_Top = case_when(TRAP%in%Scrub ~  "Scrub", 
                             TRAP%in%Pasture ~ "Pasture",
                             TRAP%in%Annual ~ "Annual agriculture",
                             TRAP%nin%c(Scrub,Pasture,Annual)~ LU_Top)) # LU_Top streamlined


# Review Landuse: there should be no "Nodata" or NA's as it was replaced with RS data, where it exists. 

master %>% 
  group_by(LU_Top) %>% 
  tally()
master %>% 
  group_by(LU_Around) %>% 
  tally() %>% 
  mutate(perc = round(n/sum(n)*100,2)) %>% 
  arrange(perc)

 
###  Eliminate duplicates (revisited mounds)

# Find duplicate TRAP ids
master$TRAP[duplicated(master$TRAP)] 
# [1] 8051 9338 9071 9400  # need to be dealt with
master[which(duplicated(master$TRAP)),]
# [1]  80 778 779 839

dupl_rows <- master %>% 
  group_by(TRAP) %>% 
  filter(n()>1) %>% 
  arrange(TRAP) %>% 
  filter(Condition == 5) 

# Delete duplicate rows
dim(master)
master <- master %>% 
  rows_delete(dupl_rows,by = c("TRAP", "Condition")) # as the TRAP ids are duplicated, I specify Condition as the differentiating column
dim(master)

# Delete no-longer needed temps
rm(scrub, Scrub, pasture, Pasture, annual, Annual)
rm(LUmiss_subs, LUmissing, LUTmissing)
rm(dupl_rows)

####################################### ADDITIONAL EDITS (OPTIONAL)

#### STREAMLINE CONDITION
# Condition is expressed on Likert scale 1 - 5 with verbose description 
# of each number, e.g. 1-pristine, 5 - extinct, as a character
unique(master$Condition)

# Clean the Condition to numbers only
master <- master %>%
  mutate(Condition = str_extract(Condition, "\\d")) %>%
  mutate(Condition = case_when(Condition == 0 ~ NA,
                               Condition == 6 ~ "5",
                               Condition != 0 ~ Condition)) #%>%
  #distinct(Condition)

master$Condition <- factor(master$Condition, levels = c("1","2","3","4","5","NA"))
hist(as.numeric(master$Condition))
master$Condition[master$Condition=="NA"] <- NA

head(master$Condition)


#### STREAMLINE HEIGHT

# Height is mostly numeric, but a few missing values were reconstructed from old atlases,
# and entered as text. e.g.[454] "2 acc to topomap". These four entries can be either made NAs,
# as they are reconstructions, or digits can be extracted with regexes.

# Checking height measures
class(master$HeightMax)
hist(as.numeric(master$HeightMax))
mean(as.numeric(master$HeightMax), na.rm = TRUE)

# Missing Heights in original master dataset
length(which(is.na(master$HeightMax))) # 18 missing heights in 
# [1]  460  964  970 1076 1086 1088 1116 1117 1118 1119 1120 1121 1122 1123 1124
# [16] 1125 1126 1127

# Additional 4 NAs if we force text to number for indeces 130  456  459 461
length(which(is.na(as.numeric(master$HeightMax)))) # 22 missing heights

# 454ff have text with reconstructios from an atlas instead of the numbers, 
# create a version with the numbers reconstructed, or force to NAs
master_reconstr_heights <- master %>%
  mutate(HeightMax = str_extract(HeightMax,"\\d\\.?\\d?"),
         HeightMax = as.numeric(HeightMax))
master <- master %>%
  mutate(HeightMax = as.numeric(HeightMax))

mean(master$HeightMax, na.rm = TRUE)
mean(master_reconstr_heights$HeightMax, na.rm = TRUE)

hist(master$HeightMax)
hist(master_reconstr_heights$HeightMax, col= "pink", add = TRUE, alpha = 0.5)

# Output the cleaned master dataset
write.csv(master, "output_data/mergedclean.csv")
write.csv(master, "../MoundHealth/data/master.csv")
write.csv(master_reconstr_heights, "../MoundHealth/data/master_reconstr_heights.csv")
####################################  NEXT STEPS #############################################

# NEXT STEPS: Streamline m_Faims
# NEXT STEPS: ADD SPATIAL DATA > NEW SCRIPT 06
# NEXT STEPS: CONTINUE THINKING: WHAT OTHER COLUMNS DO I NEED IN MASTER? OR WHAT CHECKS ARE NEEDED?

# - geospatial can be extracted from GIS
# - TopoID can be extracted from GIS (but exists in 2009-2010)
# BEWARE: 9313 geospatial info in m2010 may be wrong as is inconsistent with image (road on image, none in GE)



# REVIEW DIMENSIONS AND TYPE CONCORDANCE
# mXXXX %>%
#   select(TRAP, Source, DiameterMax, DiameterMin, HeightMax, Condition, Notes, Type) %>%
#   filter(HeightMax<0.6 | DiameterMax <15 | DiameterMin < 15) %>%
#   tail(13)
# mutate(Type = "Extinct Burial Mound") %>%
#   filter(HeightMax == 0) %>%
#   mutate(Type = "Uncertain Mound")
# 
>>>>>>> 8571bf5677c420dec659bc30fe53c19d61118a7e:scripts/05_MergeToMaster.R
