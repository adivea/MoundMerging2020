##################################
#             Merging verified mounds with remotely sensed mounds

# This procedure requires several steps: 
# 1) liberal merging of verified mounds of adela and bara's to get as much ground truthing data (dimensions and CRM) as possible
# 2) merging the result of 1 with RS mounds to compare LU and dimensions
# 3) verifying and sanity checking of the mounds

# Another approach is more conservative
# 1) Merge only verified Type== mound features from adela and bara to cut to the chase
# 2) compare lanuse with RS
# 3) merge results


# Libraries
library(tidyverse)
library(dplyr)

# Load the datasets
source(LoadData.R)


# PREREQUISITES 
# FOR MergING by TopoID 
# first I need to eliminate zeros, so the 0 does not permutate
mounds_b <- mounds_bara %>% 
  filter(TopoID>0)  # resulting in 297 obs
mounds_a <- mounds_adela %>% 
  filter(TopoID>0) # result in 292 obs

# MERGE 
# lets try full join - to return all TopoIDs from both datasets with NA where either x or y dataset do not have a match
topo_mounds <- full_join(mounds_a, mounds_b, 
                            by = "TopoID", copy = FALSE, suffix = c(".as", ".bw")) # 339 obs
topo_mounds # 339 obs upon liberal merge


# QUICK CHECK - SKIP TO CLEANING IF NOT INTERESTED

# Checking what is the landuse situation and how much data is missing that we NEED from RS.
topo_mounds %>% 
  filter(is.na(LandUseAround)) %>%  # 52 features have unidentified landuse in Baras data, 43 in cleaned bara's data
  select(Trap, TRAPCode, SomethingPresentOntheGround, LandUseAround, LanduseOn) %>% 
  group_by(SomethingPresentOntheGround) %>%   # what has no landuse?
  tally()  
# 34 mounds in Bara have no landuse, and 9 others


# Checking if there is anything salvageable in 47 Bara's mounds that are missing from Adela table
topo_mounds %>% 
  filter(is.na(SomethingPresentOntheGround)) %>% # 12 in clean; 47 in old have no record in Adela's table, so I want to see what's in bara's section
  filter(Type != "GC Failed") %>%  # 10 failed GC in Bara's table, # 37 are exinct or dubitable
  filter(!is.na(Height.bw)) %>%   # 12 in clean, 25 in old have NA as Height
  select(TRAPCode, Type, LandUseAround, Height.bw, Principal, Condition )  
# 12 mounds in Bara have height and merit salvage. Although several are spurioushaving no data on LU and heigh despite extinct status.
# Strangely, unidentified-non-mound feature 9460 has height of 3m!!

# CLEANING

# Find those records that are missing critical data (dimensions) from both adela or bara datsets
discard <- topo_mounds %>% 
  filter(is.na(Trap)) %>%   # 47 records in adela are missing TRAP (signalled as NA); but may have values in Bara 
  filter(is.na(Height.bw))  # problematic records that lack dimensions in bara
  #filter(TRAPCode==0)       #19 records are missing TRAP in bara (marked as  0 by convention from GIS)
#47 features have no TRAP number and are missing from adela's data. These are numbers that stand out since after reconciliation of bara and mine datasets. and overwriting?
#10 features have no TRAP number in bara's dataset and GC failed for them
# altogether 35 features should be discarded from the Topo mounds

# Delete undesirable missing rows from topo dataframe, a la https://www.tidyverse.org/blog/2020/05/dplyr-1-0-0-last-minute-additions/
topo_mounds <- topo_mounds %>%
  rows_delete(discard, by = 'TopoID')
# resulting tibble has 304 rows as expected (topo 339 - discard 35)


# ADDITIONAL FILTERS
# reference: https://dplyr.tidyverse.org/reference/filter.html
# Filter for NON-MOUNDS out of Adela and Bara. 
# Here is a diagnostic showing that nothing in adela can contain data in Bara.
# yes, it is mostly extinct mounds, but these may be useful for some spatial study
topo_mounds %>% 
  filter(SomethingPresentOntheGround == "nothing") %>% 
  filter(grepl("Burial Mound", Type)) %>%   # looking for mounds in Bara
  select(Trap, TRAPCode, SomethingPresentOntheGround, LandUseAround, LanduseOn, Type, Height.bw)

# Here is a comparison of the two Type categories in Bara and Adela
topo_mounds %>% 
  select(Trap, TRAPCode, SomethingPresentOntheGround, LandUseAround, LanduseOn, Type, Height.as, Height.bw) %>% 
  group_by(Type, SomethingPresentOntheGround) %>% 
  tally()

# Look at the breakdown of non-mounds (tells, etc.) from both adela and bara but keep potential (extinct) mounds everywhere
topo_mounds %>% 
  filter(grepl("Burial Mound", Type) | SomethingPresentOntheGround == "mound") %>%   # looking for Burial Mounds in Bara and for mounds in Adela  https://blog.exploratory.io/filter-data-with-dplyr-76cf5f1a258e
  select(Trap, TRAPCode, SomethingPresentOntheGround, LandUseAround, LanduseOn, Type, Height.bw) %>% 
  group_by(Type, SomethingPresentOntheGround) %>% 
  tally()

# Creates a list of 289 mounds 
topo_mounds <- topo_mounds %>% 
  filter(grepl("Burial Mound", Type) | SomethingPresentOntheGround == "mound") %>%   # looking for Burial Mounds in Bara and for mounds in Adela  https://blog.exploratory.io/filter-data-with-dplyr-76cf5f1a258e
  select(TopoID, Trap, TRAPCode, SomethingPresentOntheGround, LandUseAround, LanduseOn, Type, Height.as, Height.bw, Length, `Length (max, m)`, Condition, Principal)


# SUMMARY
# TOPO DATASET NOW CONTAINS MOSTLY MOUNDS, BUT MAY EXLCUDE SOME FROM ADELA'S DATASET BASED ON TRAP, MIGHT NEED TO RETURN TO RELIABLE MOUNDS FROM ABMOUNDS
# topo dataset is good to check consistency of RS readings on landuse with those of Bara' team.


#Overall number of mounds in different landuse categories before enrichment
topo_mounds %>% 
  select(Trap, TRAPCode, SomethingPresentOntheGround, LandUseAround, LanduseOn, Type) %>% 
  filter(SomethingPresentOntheGround == "mound") %>%  # checking landuse for the 260 confirmed mounds
  group_by(LandUseAround) %>%  
  tally()
# 34 mounds have unidentified Landuse, they likely represent Adela data from full join > these should be fixed by RS enrichment
# Annual and pasture dominate the LU with 109 AND 100 respectively

# which ones need the Landuse most?
missingLU <- topo_mounds %>% 
  filter(is.na(LandUseAround))%>% 
  select(TopoID, Trap, TRAPCode, SomethingPresentOntheGround, Type)
