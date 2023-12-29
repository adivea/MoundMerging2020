# Purpose
# This script helps me create analysis-ready data from observations of burial mounds in Yambol province, 
# based on field surveys during 2009-2018, collected using paper-digital hybrid workflow (2009-2010) and fully digital FAIMS-based workflow (2017-2018). 
# After data collection, these datasets have been cleaned in OpenRefine and outputs of this streamlining were placed in the raw_data folder

# The cleaning happens in 2 stages: [that was the original plan] 
# 1) merge and compare legacy datasets, address discrepancies, and extract ground truthing information. 
# 2) enrich the landuse and status categories with remotely sensed data where it was missing on discrepant.

# Revised plan
# This script helps load all the datasets for followup cleaning and streamlining, and eventual merging into master atribute data, 
# before joining with spatial data (points) from ARcGIS.
# This script uses links to Googlesheets which are either the products of OpenRefine (2010-2018) or deposits of manual processing from survey (2009)

# Libraries
library(tidyverse)
library(googlesheets4)

# I use Jenny Brian's guide at https://googlesheets4.tidyverse.org/

# Load the datasets
mounds_bara <- read_sheet("https://docs.google.com/spreadsheets/d/1YNylFmIQZ3oAIHdd2yxcHgre48J81K1nM0bhDG5j-bI/edit#gid=515219244", col_types = "nnccccccccccccccccncccccccnncnnnnccccncnn")# 441 obs legacy data verification Bara version (streamlined manually in 2018) version
# mounds_RS <- read_sheet(file = "raw_data/RSMounds_Temporal20200526.csv") # 850 obs remote sensing data for verifying LU and presence of mound in map features
mounds_adela <- read_sheet("https://docs.google.com/spreadsheets/d/11pwAdDNS6bpVg1aAhuUuz_Lgcxsze8Z_afLxAVs99wc/edit#gid=1826731021", col_types = "ddcccccDccnnncccccc") # 444 obs legacy data verification Adela (original 2017 but streamlined in Open Refine with LU supplied by and dimensions verified via GoogleEarth) version
mnd2017 <- read_sheet("https://docs.google.com/spreadsheets/d/1TyWsxAbRTqOBnim7Asg8qmYqlMcvV7Q0ZuBtWKCntdE/edit#gid=433356722", col_types = "ddcccccccccccdddddcdcccnnddccccccccccccccccccc")
mnd2018 <- read_sheet("https://docs.google.com/spreadsheets/d/1XCgQqd7ooP4CrDYQ2EmhR3_P1VDFpYlyTxywTB3PqWI/edit#gid=1326323943", col_types = "cddccccdccccccccccccccdddddcccccnnnncccccccccccccccccccccc") # 282 records cleaned in OR from annotations
mnd2009<- read_sheet("https://docs.google.com/spreadsheets/d/1FqqVPbK263RoOVEgSzvmQTi6U7xz5jekTvLCg1qMaEE/edit#gid=0",  col_types ="nccncccDnnnccnnnccccc" ) # this file contains 2009 survey and RS mounds that Adela check in GEPro (exists on GDrive)
#mnd2022 <- read_sheet("https://docs.google.com/spreadsheets/d/1oyCvhs4L1rOEHB1O_z10xjpW7iH_Vg7QQNDGAoyQn-M/edit#gid=720505485",col_types ="nc?ncccccccccccnnnnnnnccnnnnccccccccccccccccccL") # 310 features from 2022



# Looking at the open-refined data
class(mnd2009)
glimpse(mnd2017)  # only mounds in Yambol, bring in the whole dataset maybe? and check that it is cleaned up? > run through OR script?
glimpse(mnd2018) # 2018MalomirMnds_AS needs cleaning of annotations, grab the OR 2018Bolyarovo dataset, 
glimpse(mnd2009)
glimpse(mounds_adela)

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
