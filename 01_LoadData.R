# Purpose
# This script helps me create cleanish data on burial mounds in Yambol based on legacy data from field surveys 2009-2018. 
# The cleaning happens in 2 stages: 
# 1) merge and compare two legacy datasets, address discrepancies, and extract ground truthing information. 
# 2) enrich the landuse and status categories with remotely sensed data where it was missing on discrepant.


# Libraries
library(tidyverse)


# Load the datasets
mounds_bara <- read_csv(file = "raw_data/2010-LGV-Bara-enrichedOR-20200619.csv")# 441 obs legacy data verification Bara version (streamlined manually in 2018) version
mounds_RS <- read_csv(file = "raw_data/RSMounds_Temporal20200526.csv") # 850 obs remote sensing data for verifying LU and presence of mound in map features
mounds_adela <- read_csv(file = "raw_data/2010-LGV-AdelaLU-20200629.csv") # 444 obs legacy data verification Adela (original 2017 but streamlined in Open Refine with LU supplied by and dimensions verified via GoogleEarth) version
mnd2017 <- read_csv(file = "raw_data/2017ElenovoAll.csv")
mnd2018 <- read_csv(file = "raw_data/2018Bolyarovo.csv") # 282 records cleaned in OR from annotations
mnd2009<- read_csv(file = "raw_data/2009Mounds_20200722.csv") # 83 records of 2009 survey and RS mounds that Adela verified in GEPro(exists on GDrive)



# REVIEW (OPTIONAL) Looking at the 'OR-cleaned' data

glimpse(mnd2017)  # everything is a double or character, we'll need to sort the dates
glimpse(mnd2018) # 2018MalomirMnds_AS needs cleaning of annotations, grab the OR 2018Bolyarovo dataset, 
glimpse(mnd2009)

length(unique(mnd2017$identifier))
length(unique(mnd2018$identifier))

# Checking IDs and data overlaps within datasets

length(which(mounds_adela$TopoID%in%mounds_bara$TopoID))
length(which(mounds_adela$TRAP%in%mounds_bara$TRAPCode))
which(mnd2017$identifier%in%mounds_bara) # any duplicates from 2010 in 2017 data?
which(mnd2018$identifier%in%mounds_bara) # any duplicates from 2010 in 2018 data?


# How much help is the RS dataset going to be? 
length(which(mounds_bara$TopoID%in%mounds_RS$TopoID)) # between 32 adn 38 mounds are shared in bara, adela and RS data. NOT MUCH
# revLU_b <-  mounds_bara$TopoID[which(mounds_bara$TopoID%in%mounds_RS$TopoID)]
# revLU_a <- mounds_adela$TopoID[which(mounds_adela$TopoID%in%mounds_RS$TopoID)]
# revLU <- c(revLU_a, revLU_b)     
# length(revLU)
# length(unique(revLU))

# Summary: 
# Clearly the RS dataset was complementary to the LGV data, not duplicating it. It is therefore not useful to crosscheck against bara data.
# Adela needs to add landuse data to 2010 via remote sensing to have a constrast/complement to bara landuse. DONE on 29 June And merged back in as mounds_adela from 2010_LGV_AdelaLU