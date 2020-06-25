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
mounds_adela <- read_csv(file = "raw_data/2010-LGV-20200608.csv") # 444 obs legacy data verification Adela (original 2017 but OR streamlined) version
mnd2017 <- read_csv(file = "raw_data/2017ElenovoMoundsAll.csv")
mnd2018 <- read.csv(file = "raw_data/2018Bolyarovo.csv",stringsAsFactors = FALSE) # 282 records cleaned in OR from annotations
mnd2009<- read.csv(file = "raw_data/2009Mounds_20200430.csv",stringsAsFactors = FALSE) # this file contains 2009 survey and RS mounds that Adela check in GEPro (exists on GDrive)



# Checking the 'clean'data

glimpse(mnd2017)  # only mounds in Yambol, bring in the whole dataset maybe? and check that it is cleaned up? > run through OR script?
glimpse(mnd2018) # 2018MalomirMnds_AS needs cleaning of annotations, grab the OR 2018Bolyarovo dataset, 
glimpse(mnd2009)

length(unique(mnd2017$identifier))
length(unique(mnd2018$identifier))

# Data overlaps and relation to RS data

which(mnd2017$identifier%in%mounds_bara) # any duplicates from 2010 in 2017 data?
which(mnd2018$identifier%in%mounds_bara) # any duplicates from 2010 in 2018 data?
length(which(mounds_adela$TopoID%in%mounds_RS$TopoID))
revLU_b <-  mounds_bara$TopoID[which(mounds_bara$TopoID%in%mounds_RS$TopoID)]
revLU_a <- mounds_adela$TopoID[which(mounds_adela$TopoID%in%mounds_RS$TopoID)]
revLU <- c(revLU_a, revLU_b)     
length(revLU)
length(unique(revLU))
