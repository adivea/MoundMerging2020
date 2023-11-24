############################################################################################################
#             Creating a master 2010 verified mound dataset
############################################################################################################

# the main aim of this script is to have a master dataset that tells us something about mound morphology and surrounding landuse
# for chronological modeling and for vulnerability modeling
# This script is an intermediate step towards the master dataset of verified mounds in Yambol from field surveys 2009-2018, 
# as 2010 has been forked and needs conciliation. In this script we use TRAP IDs to carve out a 2010 dataset.
# 2010 verified dataset should not contain too many features whose dimensions are unknown or that don't have the potential of having once been a mound


############################################################################################################
# Goal, Inputs and Outputs

# As input this script takes the 2010 datasets created with 01_LoadData.R,
# specifically, mounds_adela and mounds_bara. This script then helps generate two clean datasets 
# of 2010 visited mounds for use in 05_MergingPrerequisites.R 
# 1) conservative mostly mounds  - mnd2010 dataset, and 
# 2) liberal, potential mounds - ableftj dataset (containing waterhouses, etc.). 
# There is also a third, broadest dataset, ab2010 that is a union of bara and adela, 
# but it's messy and therefore not of much use until a case study requires such broad dataset.


############################################################################################################
# Process

# The cleaning happens in the following stages: 
# 1) it takes 2010 version adela and bara dataset as two inputs. 
# 2) It merges via left join to adela's dataset via TRAP ID and compare two legacy datasets, 
#  address discrepancies, and extracts ground truthing information. 
# 3) it outputs a cleanish verified mound dataset called mnd2010. 
# These are all mounds that have a TRAP ID and could potentially represent mounds

# Libraries
library(tidyverse)
library(here)

############################################################################################################
# Load the inputs
df_name <- c("mounds_adela", "mounds_bara")
for (i in df_name){
if (exists(i)){
  is.data.frame(get(i))
}  else source("scripts/01_LoadDataG.R")
}

# Check for TRAP ID
summary(mounds_adela$TRAP)
summary(mounds_bara$TRAPCode)
mounds_bara %>% 
  filter(TRAPCode==0)  # 10 mounds lack TRAP ID in Bara's dataset

### Merge datasets to compare data quality
# https://dplyr.tidyverse.org/reference/join.html

######################################################################################################################
# LEFT JOIN BY TRAP - MEANINGFUL MOUNDS mnd2010 AND POTENTIAL MOUNDS ABLEFTJ
############################################################################################################
#
## Left join to adela's dataset
# I consider adela dataset slightly verified (from several sources) and so we start with a left join 
# of bara's to adela's data via TRAP ID to preserve adela's data and append bara's
# all mounds should have TRAP number since they have been surveyed (in theory) and verified. 
# Line 33-34 shows that Bara's dataset has 10 mounds with missing TRAP ID. 
# These are missing because mounds were not reachable/accessible in the field and field procedure was not fully determined 
# (we had not trusted the maps enough to give .

ableftj <- left_join(mounds_adela, mounds_bara, 
                       by = c("TRAP" = 'TRAPCode')) # 444 observations on the basis of 444 adela records

# What kind of features hide behind non-map-features (TopoIDs=0) in Adela and Bara? 
# How many non-map features were encountered in 2010 and what were they?
ableftj%>% 
  filter(TopoID.x==0) %>%   # 
  select(TRAP, SomethingPresentOntheGround, TopoID.x, TopoID.y, Width.x, Width.y) %>% 
  group_by(SomethingPresentOntheGround) %>% 
  tally()
# 444 features have received TRAP ID in 2010; 292 of adela's them have Topo ID, an equivalent in the map. 
# 152 of 444 features do not have TopoID, 146 of these 152 are mounds, and 6 are other. 


# Searching for a borderline between actual clearcut mounds, potential or extinct mounds and other features.

ableftj %>% 
  filter(SomethingPresentOntheGround == "mound") %>% 
  group_by(as.factor(Type)) %>% 
  tally()
# 406 out of 444 have an actual or extinct mound on the ground >> MOST MEANINGFUL
   

ableftj %>%
  filter(SomethingPresentOntheGround != "mound") %>%  # 38 are not immediately identifiable as a mound on the ground
  group_by(as.factor(SomethingPresentOntheGround)) %>% 
   tally()
# out of 444 features, 38 are classified as something else than a burial mound: 

# A tibble: 8 x 2
# `as.factor(SomethingPresentOntheGround)`     n
# <fct>                                    <int>
#   1 bunker                                       3
# 2 nothing                                     24
# 3 pile of stones                               2
# 4 robber trenches                              1
# 5 tank emplacement nearby                      1
# 6 tell                                         3
# 7 transmitter                                  1
# 8 waterhouse                                   3

# Some of these could be extinct mounds. For example, bunkers are best built in former mound locations to confuse enemy (and locals too),
# waterhouses and tank emplacements also soemtimes utilize existing mounds, so we cannot guarantee moundlessness here in the past. 
# So to try the other way around, we can guarantee that a tell, or a 'nothing' is not amound. 
# A liberal conception of a potential mound would be anything except these two elements
# and keep the others. A conservative measure would be to grab explicit 'mounds' only.

#Conservative mounds 2010
mnd2010 <- ableftj %>% 
  filter(SomethingPresentOntheGround == "mound") 
# 406 results


# Potential mounds 2020 ("could have been a mound in the past") 
ableftj %>%
  filter(SomethingPresentOntheGround != "nothing") %>% 
  filter(SomethingPresentOntheGround != "tell")
# >> 417 results

# Final notes on left join:
# Immediate product ableftj contains 444 features (same as Adela) and represents both verified mounds and potential mounds (that exist in maps, but were ambiguous or destroyed in the field)
# Filtered product of left join, mnd2010, contains 406 features that were classified as burial mounds on the ground.
# Both are usable, ableftj for analysis needing locations mostly and not dimensions, mnd2010 for analysis where dimensions are essential

############################################################################################################
#  FULL JOIN AB2010 - ALL ATTEMPTED MAP FEATURES FROM 2010
############################################################################################################
#
# full join of adela and bara (all TRAP ids from both), resulting in 493 rows. 
# Collating all TRAP IDs can be an issue as erroneous TRAP ids can seep in. ID 1936 needs to be filtered, for example.
ab2010 <- full_join(mounds_adela, mounds_bara[-which(mounds_bara$TRAPCode==1936),],   # 1936 is a wrong number (too low to have been used in Yambol)
                     by = c("TRAP" = 'TRAPCode'))

ab2010%>% 
  filter(SomethingPresentOntheGround == "mound") # same 406 records same as in conservative mnd2010 above

ab2010 %>% 
  select(TRAP, TopoID.x, TopoID.y, SomethingPresentOntheGround, Type, Height.x, Height.y, Length.x,Length.y) %>% 
  group_by(Type, SomethingPresentOntheGround) %>% 
  tally()
# 50 additional features in Bara's record are mostly GC failed, nothing and other features. There are only 10 moundlike records. 
# Lets' look at them more closely.

ab2010 %>% 
  select(TRAP, TopoID.x, TopoID.y, SomethingPresentOntheGround, Type, Height.x, Height.y, Length.x,Length.y) %>% 
  filter(is.na(SomethingPresentOntheGround)) %>% 
  filter(grepl("Mound",Type)) 

#########################################################################################################
# FINAL NOTES ON FULL JOIN

# There are issues with the full join final dataset, such as:
# - containing 50 unvisited features with no attributes, 
# - same (406) number of mounds as in the most conservative dataset of mnd2010 above
# - 10 records here range from Burial Mound(?) to Extinct Burial Mound, 
# - 6/11 lack dimensions and show inconsistencies such as Extinct status but 5 m height. 
# - Topo ID of 1936 (not a range used in Yambol, )
# These were detected upon cursory review and probably contain more issues. 


#########################################################################################################
# SUMMARY

# All in all it not worth it to use the full-join product ab2010 (n=493) to grab 10-11 additional potential mounds from bara, given the ~70 problematic features and the 
# same amount of 'mounds' (n=406). 
# ab2010 is only useful for remote sensing analysis, with 70 uncertain and 406 certain features. 
# Analysis depending on attributes should use mnd2010 or ableftj from now on.




