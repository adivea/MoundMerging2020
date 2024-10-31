############################################################################################################
#             Creating a master 2010 verified mound dataset
############################################################################################################

# this script is one step towards a master dataset of mounds in Yambol province, built 
# for chronological and vulnerability modeling.
# Field data from 2010 has been forked during previous cleaning process and needs more 
# conciliation than data from 2009 or 2017-2022, hence this extra script. In this script we use TRAP IDs to carve out a 2010 dataset.
# 2010 verified dataset should not contain too many features whose dimensions are unknown or that don't have the potential of having once been a mound


############################################################################################################
# Goal, Inputs and Outputs

# As input this script takes the 2010 datasets created with 01_LoadData.R,
# specifically, mounds_adela and mounds_bara. This script then helps generate two clean datasets 
# of 2010 visited mounds for use in 05_MergingPrerequisites.R 
# 1) conservative mostly mounds  - mnd2010 dataset, and 
# 2) liberal, potential mounds - ab  dataset (containing waterhouses, etc.). 
# There is also a third, broadest dataset, ab2010 that is a union of Bara and Adela, 
# but it's messy and therefore not of much use until a case study requires such broad dataset.


############################################################################################################
# Process

# The cleaning happens in the following stages: 
# 1) it takes 2010 version Adela and Bara dataset as two inputs. 
# 2) It merges via left join to Adela's dataset via TRAP ID and compare two legacy datasets, 
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
}  else source("scripts/01_LoadData.R")
}

# Check for TRAP ID
summary(mounds_adela$TRAP)
summary(mounds_bara$TRAPCode)
mounds_bara %>% 
  filter(TRAPCode==0)  # 10 mounds lack TRAP ID in Bara's dataset

### Merge datasets to compare data quality
# https://dplyr.tidyverse.org/reference/join.html

######################################################################################################################
# LEFT JOIN BY TRAP - MEANINGFUL MOUNDS mnd2010 AND POTENTIAL MOUNDS ab
############################################################################################################
#
## Left join to Adela's dataset
# I consider Adela dataset slightly more verified (from several sources) and so we start with a left join 
# of Bara's to Adela's data via TRAP ID to preserve Adela's data and append Bara's
# All mounds should have a TRAP number since they have been surveyed (in theory) and verified. 
# Line 33-34 shows that Bara's dataset has 10 mounds with missing TRAP ID. 
# These are missing because mounds were not reachable/accessible in the field and field procedure was not fully determined 

ab  <- left_join(mounds_adela, mounds_bara, 
                       by = c("TRAP" = 'TRAPCode')) # 444 observations on the basis of 444 Adela records

# What kind of features hide behind non-map-features (TopoIDs=0) in Adela and Bara? 
# How many non-map features were encountered in 2010 and what were they?
ab %>% 
  filter(TopoID.x==0) %>%   # 
  dplyr::select(TRAP, SomethingPresentOntheGround, TopoID.x, TopoID.y, Width.x, Width.y) %>% 
  group_by(SomethingPresentOntheGround) %>% 
  tally()
# 444 features have received TRAP ID in 2010; 292 of Adela's them have Topo ID, an equivalent in the map. 
# 152 of 444 features do not have TopoID, 146 of these 152 are mounds, and 6 are other. 


# Searching for a borderline between actual clearcut mounds, potential or extinct mounds and other features.

ab  %>% 
  filter(SomethingPresentOntheGround == "mound") %>% 
  group_by(as.factor(Type)) %>% 
  tally()
# 406 out of 444 have an actual or extinct mound on the ground >> MOST MEANINGFUL
   

ab  %>%
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

# Some of these could be extinct mounds. For example, bunkers are best built in 
# former mound locations to confuse both the enemy and the locals,
# Waterhouses and tank emplacements also sometimes utilize existing mounds, 
# so we cannot guarantee moundlessness here in the past. 
# So to try the other way around, we can guarantee that a tell, or a 'nothing' is not a mound. 
# A liberal conception of a potential mound would be anything except these two elements
# and keep the others. A conservative measure would be to grab explicit 'mounds' only.

# Conservative mounds 2010
mnd2010 <- ab  %>% 
  filter(SomethingPresentOntheGround == "mound") 
# 406 results


# Potential mounds 2010 ("could have been a mound in the past") 
ab  %>%
  filter(SomethingPresentOntheGround != "nothing") %>% 
  filter(SomethingPresentOntheGround != "tell")
# >> 417 results

# Final notes on left join:
# Immediate product ab contains 444 features (same as Adela) and represents both verified mounds and potential mounds (that exist in maps, but were ambiguous or destroyed in the field)
# Filtered product of left join, mnd2010, contains 406 features that were classified as burial mounds on the ground.
# Both are usable: ab for analysis needing locations mostly and not dimensions, mnd2010 for analysis where dimensions are essential

############################################################################################################
#  FULL JOIN ab2010 - ALL ATTEMPTED MAP FEATURES FROM 2010
############################################################################################################
#
# full join of Adela and Bara (all TRAP ids from both), resulting in 493 rows. 
# Collating all TRAP IDs can be an issue as erroneous TRAP ids can seep in. ID 1936 needs to be filtered, for example.
ab2010 <- full_join(mounds_adela, mounds_bara[-which(mounds_bara$TRAPCode==1936),],   # 1936 is a wrong number (too low to have been used in Yambol)
                     by = c("TRAP" = 'TRAPCode'))

ab2010%>% 
  filter(SomethingPresentOntheGround == "mound") # same 406 records same as in conservative mnd2010 above

ab2010 %>% 
  dplyr::select(TRAP, TopoID.x, TopoID.y, SomethingPresentOntheGround, Type, Height.x, Height.y, Length.x,Length.y) %>% 
  group_by(Type, SomethingPresentOntheGround) %>% 
  tally()
# 50 additional features in Bara's record are mostly GC failed, nothing and other features. There are only 10 moundlike records. 
# Lets' look at them more closely.

ab2010 %>% 
  dplyr::select(TRAP, TopoID.x, TopoID.y, SomethingPresentOntheGround, Type, Height.x, Height.y, Length.x,Length.y) %>% 
  filter(is.na(SomethingPresentOntheGround)) %>% 
  filter(grepl("Mound",Type)) 

#########################################################################################################
# FINAL NOTES ON FULL JOIN

# There are issues with the full join final dataset, such as:
# - containing 50 unvisited features with no attributes, 
# - same (406) number of mounds as in the most conservative dataset of mnd2010 above
# - 10 records here range from Burial Mound(?) to Extinct Burial Mound, 
# - 6/11 lack dimensions and show inconsistencies such as Extinct status but 5 m height. 
# - TopoID of 1936 (not a range used in Yambol, )
# These faulty records were detected upon cursory review. There are probably more issues in 2010 data. 


#########################################################################################################
# SUMMARY

# All in all it not worth it to use the full-join product ab2010 (n=493) to grab 10-11 additional potential mounds from Bara, given the ~70 problematic features and the 
# same amount of 'mounds' (n=406). 
# ab2010 is only useful for remote sensing analysis, with 70 uncertain and 406 certain features. 
# Analysis depending on attributes should use mnd2010 or ab  from now on.
glimpse(mnd2010)



