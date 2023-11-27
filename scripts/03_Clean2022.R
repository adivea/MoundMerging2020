############################################################################################################
#            Creating merge-ready 2022 verified feature dataset
############################################################################################################

# Goal
# Create an analysis-ready dataset of all features visited in Yambol in 2017 on the basis of FAIMS-dataset

# Requires couple prerequisites, such as 
# 0) loading the 2022 dataset which has been generated via FAIMS app and cleaned in Open Refine
# 1) dropping and renaming columns to achieve consistency between datasets, fix date formatting
# 2) aggregating notes/annotations into fewer columns as FAIMS data have LOTS of annotations
# 3) eliminating columns irrelevant for the master dataset 
# 4) cleaning up datatypes, and checking the consistency of classifications

# Library
library(tidyverse)
library(lubridate)


# Merge FAIMS data

# Uncomment these lines if you need to recreate from scratch and
# redo some OpenRefining
# mounds22_1 <- read_csv("../data/20220921BurialMoundOne-csv.csv")
# mounds22_2 <- read_csv("../data/20220930BurialMoundTwo-csv.csv")
# 
# mounds22 <- rbind(mounds22_1,mounds22_2)
# table(mounds22$TypeClean)
# names(mounds22)
# write.csv(mounds22, "../data/2022Elhovo.csv")

## Load 2022 data

# 2022 data was freshly collected via FAIMS app in September 2022
# and cleaned with the 2022_Elhovo_ORcleaningscript to clean up data from the Elhovo 2022 Burial module first (https://docs.google.com/document/d/1Xcq5yuQOrQpVOkGF2fp3ZeK4ynyaTVa3sZZ41NI7ZF8/edit) and 
# deposited the exported spreadsheets in the data/ folder

m2022 <- read_csv("raw_data/2022Elhovo.csv")
names(m2022)
glimpse(m2022)


# Fix date
m2022 <- m2022 %>% 
  mutate(Date = date(createdAtGMT)) %>% 
  mutate(Date = ymd(Date))

### Merge notes into one or two columns

m2022 <- m2022 %>% 
  dplyr::select(-NotesAndPhotoID) %>% 
  dplyr::select(-'...1')

m2022 %>% 
  dplyr::select(grep(" 2",names(m2022)), grep("Note",names(m2022))) 


# Unite them into two columns for damage and generate with unite(x, y, sep = ",", remove = TRUE, na.rm = TRUE) function
m2022 <- m2022 %>% 
  unite(AllNotes, c(grep("[Nn]ote",names(m2022))), sep = ",", remove = TRUE, na.rm = TRUE) 
m2022$AllNotes
m2022 <- m2022 %>% 
  unite(DamageNotes, c(grep(" 2",names(m2022))), sep = ",", remove = TRUE, na.rm = TRUE)  # Damage notes have "2" in column name from OpenRefine
m2022$DamageNotes  # we have reduced the initial 52 to 48 variable
names(m2022)

# Rename columns & Reduce cols to 2009-2010 data

m2022 <- m2022 %>%
  dplyr::rename(TRAP=MoundID, Type=TypeClean, LU_Around = LanduseAroundMound, LU_Top = LanduseOnTopOfMound) # %>% 
  # dplyr::select(TRAP, Source, createdBy, Date, Type, LU_Around, LU_Top, PositionInTheLandscape,
  #               Prominence, DiameterMax, HeightMax, HeightMin, DiameterMin,
  #               Condition, PrincipalSourceOfImpact,  
  #               AllNotes, DamageNotes,Northing, Easting, geospatialcolumn)


# sanity check - view the mounds
# library(mapview)
# library(sf)
# convert to a simple feature
# mn22 <- st_as_sf(m2022, coords = c("Easting", "Northing"), crs = 32635)
#mapview(mn22, zcol = "Type")

# looking for ca 30 features on 29 Sep
# mn22 %>% dplyr::filter(Date == "2022-09-29") %>% 
#   mapview()


# Ensure dimensions are numeric
m2022$HeightMin <- as.numeric(m2022$HeightMin)
m2022$DiameterMax <- as.numeric(m2022$DiameterMax)
m2022$DiameterMin <- as.numeric(m2022$DiameterMin)
glimpse(m2022)
