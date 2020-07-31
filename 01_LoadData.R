# Purpose
# This script helps me create analysis-ready data from observations of burial mounds in Yambol province, 
# based on field surveys during 2009-2018, collected using paper-digital hybrid workflow (2009-2010) and fully digital FAIMS-based workflow (2017-2018). 
# After data collection, these datasets have been cleaned in OpenRefine and outputs of this streamlining were placed in the raw_data folder

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
mnd2009<- read_csv(file = "raw_data/2009Mounds_20200722.csv") # this file contains 2009 survey and RS mounds that Adela check in GEPro (exists on GDrive)



# Looking at the open-refined data

glimpse(mnd2017)  # only mounds in Yambol, bring in the whole dataset maybe? and check that it is cleaned up? > run through OR script?
glimpse(mnd2018) # 2018MalomirMnds_AS needs cleaning of annotations, grab the OR 2018Bolyarovo dataset, 
glimpse(mnd2009)

# Checking IDs and data overlaps within datasets in 2010, 2017, 2018

length(which(mounds_adela$TopoID%in%mounds_bara$TopoID)) # 401 records share TopoID between 2010 bara and adela 
length(which(mounds_adela$TRAP%in%mounds_bara$TRAPCode)) # 391 records share TrapID between 2010 bara and adela
which(mnd2017$identifier%in%mounds_bara) # any duplicates from 2010 in 2017 data? None
which(mnd2018$identifier%in%mounds_bara) # any duplicates from 2010 in 2018 data? None


# Summary
# 2010 datasets need serious work
# 2009, 2017, 2018 datasets need work on convergence of column names and content datatype. 
# RS dataset is not useful for 2010. It was complementary to 2010 LGV data, not duplicating/enriching it. 
# As a result, Adela needed to review landuse data for 2010 features in Google Earth Pro to have a 
# comparison to landuse encoded by bara' (potentially flawed or inconsistent). This remote sensing was DONE on 29 June 2020 
# And merged back in as mounds_adela from 2010_LGV_AdelaLU.