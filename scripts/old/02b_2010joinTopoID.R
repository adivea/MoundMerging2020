############################################################################################################
#             Creating a master 2010 verified mound dataset
# the main aim is to have a dataset that tells us something about mound morphology for chronological modelling
# This script is an intermediate step towards the master dataset of verified mounds in Yambol from field surveys 2009-2018, 
# as 2010 has been forked and needs conciliation. In this script we use Topo IDs to carve out a 2010 dataset.
# This 2010 verified dataset should not contain too many features whose dimensions are unknown or that don't have the potential of having once been a mound
# This 2010 dataset might contain all potential mounds (digitized from historical maps with TopoIDs and visited or remotely sensed)

# Goal, Inputs and Outputs

# As input this script takes the 2010 datasets created with 01_LoadData.R,
# specifically, mounds_adela and mounds_bara. 
# This script then helps generate one broad dataset of 2010 map mounds by a full-join of those 2010 records that have a TopoID.
# The final dataset topo_mounds is useful for analysis of survey and remote sensing methods, as it covers all map features and
# observations of their characteristics from both pedestrian survey and remote sensing in GoogleEarthPro.
# the output is a topo_mounds (n=289) dataset of all potential map mounds with attributes collected during groundtruthing. 
# It should encompass all mounds whether or not they got a TRAP ID and be a suitable input for 03_RScheck2010.Rmd.


# Process
# This procedure requires several steps: 
# 1) liberal full join of verified or attempted mounds of adela and bara's by TopoID
# 2) verifying and sanity checking of attributes such as mound IDs etc.
# 3) compare ground truthing data (LU, dimensions and CRM) between adela and bara and asses divergence. 
# LU in 2010 adela is from GEpro remote sensing, in bara it originates from scanned forms and photos (because forms are often incomplete or it is not clear whether they refer to on the top or around LU.
# 4) The output can be fed into the 03_RScheck2010.Rmd for further analysis


# A more conservative fork on this process is:
# 1) Merge only verified Type== mound features from adela and bara to cut to the chase
# 2) compare landuse among the with RS
# 3) Create a verified dataset where all mounds have a topo and TRAP ID.(n=290)


# Libraries
library(tidyverse)
library(here)


# Load the datasets
source("scripts/01_LoadDataG.R")


# PREREQUISITES 
# FOR MergING by TopoID 
# first I need to eliminate zeros, so the 0 does not permutate
mounds_b <- mounds_bara %>% 
  filter(TopoID>0)  # resulting in 297 obs
mounds_a <- mounds_adela %>% 
  filter(TopoID>0) # result in 292 obs


# the join hinges on the assumpetion that is there overlap in TopoIDs between the datasets
class(mounds_b$TopoID)
length(which(mounds_a$TopoID%in%mounds_b$TopoID)) # ok there were at least 249 shared topoids

# MERGE 
# lets try full join - to return all TopoIDs from both datasets with NA where either x or y dataset do not have a match
topo_mounds <- full_join(mounds_a, mounds_b, 
                            by = "TopoID", copy = FALSE, suffix = c(".as", ".bw")) # 340 observations, 
topo_mounds # 339 obs upon liberal merge, this is 100 TopoIDs are not shared among adela and bara datasets. 
# These 100 unshared TopoIDs represent map locations where nothing was found.


# QUICK CHECK - SKIP TO CLEANING IF NOT INTERESTED

# Checking what is the landuse situation and how much data is missing that we NEED from RS.
topo_mounds %>% 
  filter(is.na(LandUseAround)) %>%  # 52 features have unidentified landuse in Baras data, 43 in cleaned bara's data
  select(TRAP, TRAPCode, SomethingPresentOntheGround, LandUseAround, LanduseOn) %>% 
  group_by(SomethingPresentOntheGround) %>%   # what has no landuse?
  tally()  
# 35 mounds in Bara have no landuse, and 9 others


# Which are the salvageable features in 48 Bara's mounds that are missing from Adela table? Salvageable = have height and dimensions, LU)
topo_mounds %>% 
  filter(is.na(SomethingPresentOntheGround)) %>% # what's in bara's section (NA in ground)? 12 in clean; 48 in old have no record in Adela's table, 
  filter(Type != "GC Failed") %>%  # 10 failed GC in Bara's table, # 38 are exinct or dubitable
  filter(!is.na(Height.bw)) %>%   # 13 have NA as Height
  select(TRAPCode, Type, LandUseAround, Height.bw, Principal, Condition )  
# 12 mounds in Bara have height and merit salvage. Although several are spurioushaving no data on LU and heigh despite extinct status.
# Strangely, unidentified-non-mound feature 9460 has height of 3m!! # TRAPCode 9460 is strange and needs to be discarded.


# CLEANING

# Find those records that are missing critical data (dimensions) from both adela or bara datsets
discard <- topo_mounds %>% 
  filter(is.na(TRAP)) %>%   # 47 records in adela are missing TRAP (signalled as NA); but may have values in Bara 
  filter(is.na(Height.bw))  # problematic records that lack dimensions in bara
  
#19 records are missing TRAP number in bara (marked as  0 by convention from GIS)
#47 features have no TRAP number and are missing from adela's data. These are numbers that stand out since after reconciliation of bara and mine datasets. and overwriting?
#10 features have no TRAP number in bara's dataset and GC failed for them
# altogether 35 features should be discarded from the Topo mounds

# Delete undesirable missing rows from topo dataframe, a la https://www.tidyverse.org/blog/2020/05/dplyr-1-0-0-last-minute-additions/
topo_mounds <- topo_mounds %>%
  rows_delete(discard, by = 'TopoID')
  
topo_mounds %>%
  filter(TopoID != 200962)
# TopoID 200962 corresponds toTRAPCode==9460 and is being dropped now becuse # 9460 has no information in it    
# resulting tibble has 304 rows as expected (topo 339 - discard 35)

# ADDITIONAL FILTERS
# reference: https://dplyr.tidyverse.org/reference/filter.html
# Filter for NON-MOUNDS out of Adela and Bara. 
# Here is a diagnostic showing that nothing in adela can contain data in Bara.
# yes, it is mostly extinct mounds, but these may be useful for some spatial study
topo_mounds %>% 
  filter(SomethingPresentOntheGround == "nothing") %>%  # nothing in adela probably signifies an extinct burial mound in Bara; #24 of them here
  filter(grepl("Burial Mound", Type)) %>%   # looking for mounds in Bara, 14 of the adela::nothing have extinct or burial mound in bara datase
  select(TRAP, TRAPCode, SomethingPresentOntheGround, LandUseAround, LanduseOn, Type, Height.bw) # but htey lack any height, so useless except for vulnerability.

# Here is a comparison of the two Type categories in Bara and Adela
topo_mounds %>% 
  select(TRAP, TRAPCode, SomethingPresentOntheGround, LandUseAround, LanduseOn, Type, Height.as, Height.bw) %>% 
  group_by(Type, SomethingPresentOntheGround) %>% 
  tally()

# Look at the breakdown of non-mounds (tells, etc.) from both adela and bara but keep potential (extinct) mounds everywhere
topo_mounds %>% 
  filter(grepl("Burial Mound", Type) | SomethingPresentOntheGround == "mound") %>%   # looking for Burial Mounds in Bara and for mounds in Adela: 290 there  https://blog.exploratory.io/filter-data-with-dplyr-76cf5f1a258e
  select(TRAP, TRAPCode, SomethingPresentOntheGround, LandUseAround, LanduseOn, Type, Height.bw) %>% 
  group_by(Type, SomethingPresentOntheGround) %>% 
  tally()

# Creates a list of 289 mounds 
topo_mounds <- topo_mounds %>% 
  filter(grepl("Burial Mound", Type) | SomethingPresentOntheGround == "mound") %>%   # looking for Burial Mounds in Bara and for mounds in Adela  https://blog.exploratory.io/filter-data-with-dplyr-76cf5f1a258e
  select(TopoID, TRAP, TRAPCode, SomethingPresentOntheGround, Landuse_AroundRS, Landuse_TopRS, LandUseAround, LanduseOn, Type, Height.as, Height.bw, Length, `Length (max, m)`, Condition, Principal)


# SUMMARY
# TOPO_MOUNDS DATASET NOW CONTAINS MOSTLY MOUNDS, BUT MAY EXCLUDE SOME FROM ADELA'S DATASET BASED ON TRAP, 
# MIGHT NEED TO RETURN TO RELIABLE MOUNDS FROM ABMOUNDS
# topo dataset is good to check consistency of RS readings on landuse with those of Bara' team.



##############################################################################
# LANDUSE COMPARISON OF ADELA's (RS) DATA WITH BARA'S (SURVEY) DATA

# Overall number of mounds in different landuse categories according to bara/forms from 2010
topo_mounds %>% 
  select(TRAP, TRAPCode, SomethingPresentOntheGround, LandUseAround, LanduseOn, Type) %>% 
  filter(SomethingPresentOntheGround == "mound") %>%  # checking landuse for the 260 confirmed mounds
  group_by(LandUseAround) %>%  
  tally()
# 34 mounds have unidentified Landuse, they likely represent Adela data from full join > these should be fixed by RS enrichment
# Annual and pasture dominate the LU with 109 AND 100 respectively

# which ones need the Landuse most?
missingLU <- topo_mounds %>% 
  filter(is.na(LandUseAround))%>% 
  select(TopoID, TRAP, TRAPCode, SomethingPresentOntheGround, Type)

### LANDUSE AROUND

# LU_AroundRS according to remote sensing in  GEPro
LUa <- topo_mounds %>% 
  filter(SomethingPresentOntheGround == "mound") %>%  # checking landuse for the 260 confirmed mounds
  group_by(Landuse_AroundRS) %>%  
  tally()
LUb <- topo_mounds %>% 
  filter(SomethingPresentOntheGround == "mound") %>%  # checking landuse for the 260 confirmed mounds
  group_by(LandUseAround) %>%  
  tally()

LU <- full_join(LUa, LUb, by= c("Landuse_AroundRS"= "LandUseAround"),suffix = c(".as", ".bw") )
# Summary: 
# there is considerable discrepancy in assignment of LuAround between bara and adela, esp, scrub vs meadow, and forest. 
# Scrub and pasture are roughly equally split in the RS adela mounds, while bara mounds have pasture dominating (100) and scrub scarce (3).
# Forest is also more numerous in adelas record (14 as opposed to 8)
# Sources of bias: vegetation change, birds eye versus personal experience


### LANDUSE ON TOP
# After LU_AroundRS added to Adela data on basis of GEPro
LUTa <- topo_mounds %>% 
  filter(SomethingPresentOntheGround == "mound") %>%  # checking landuse for the 260 confirmed mounds
  group_by(Landuse_TopRS) %>%  
  tally()
LUTb <- topo_mounds %>% 
  filter(SomethingPresentOntheGround == "mound") %>%  # checking landuse for the 260 confirmed mounds
  group_by(LanduseOn) %>%  
  tally()

LUT <- full_join(LUTa, LUTb, by= c("Landuse_TopRS"= "LanduseOn"),suffix = c(".as", ".bw") )
# Summary:
# differences between Top assignment persist but are not as dramatic as in LU between adela (RS) and bara (ground truthing()
# there is suprising agreement in scrub on top, which is nearly identical
# there are a lot of NA in bara dataset

# LANDUSE CONCLUSION

# bara double categories need to be decoupled. Bara's around categories can be accepted as birds eyes view is more removed.
# Adelas categories can also be accepted as they are consistent. It is clear that adela marked meadown with bushes as scrub more often than bara. 
# This means that scrub and grassland can be coupled for the purpse of stati. analysis



# Apply case_when to transform LU into something more consistent/https://stackoverflow.com/questions/38649533/case-when-in-mutate-pipe
topo_mounds %>% 
#  filter(LanduseOn == 'Pasture/Scrub') %>% 
  mutate(LU_Top = LanduseOn) %>% 
  #mutate(LU_Top = case_when(LanduseOn == 'Pasture/Scrub' ~ 'Scrub',
                            # LanduseOn == 'Annual/Pasture' ~ 'Annual agriculture',
                            # LanduseOn == 'Pasture/Scrub' ~ 'Scrub'
                            