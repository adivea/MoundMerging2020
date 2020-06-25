# Purpose
# This script helps me create cleanish data on burial mounds in Yambol based on legacy data from field surveys 2009-2018. 
# The cleaning happens in 2 stages: 
# 1) it takes 2010 version adela and bara as two inputs. 
# 2) It merges via left join to adelas and compare two legacy datasets, address discrepancies, and extracts ground truthing information. 
# 3) it outputs a cleanish verified mound dataset called abmounds

# Libraries
library(tidyverse)

# Load the datasets
source(LoadData.R)

# Check for TRAP ID
summary(mounds_adela$Trap)
summary(mounds_bara$TRAPCode)
mounds_bara %>% 
  filter(TRAPCode==0)

### Merge datasets to compare data quality
# https://dplyr.tidyverse.org/reference/join.html


## MERGE BY TRAP
# I consider my dataset better and so start with a left join to adela's table via TRAP id to preserve adela's data and append bara's
# all mounds should have TRAP number since they have been surveyed (in theory) and verified. 
#Line 21-22 shows that Bara's dataset has 10 mounds with missing TRAP ID. These are missing because mounds were not reachable/accessible in the field.

ableftj <- left_join(mounds_adela, mounds_bara, 
                       by = c("Trap" = 'TRAPCode')) # 444 observations on the basis of 444 adelas
ableftj%>% 
  filter(TopoID.x==0) %>% 
  select(Trap, SomethingPresentOntheGround, TopoID.x, TopoID.y, Width.x, Width.y)
# 444 mounds have been documented in 2010; 292 of adela's them have an equivalent in the map (features have TopoID). 


## MEANINGFUL MOUNDS
# filtering out meaningful mounds
ableftj %>% 
  #filter(SomethingPresentOntheGround == "mound") # 406 out of 441 have a mound on the ground >> MOST MEANINGFUL
   filter(SomethingPresentOntheGround != "mound") %>%  # 38 are not immedaitely identifiable as a mound on the ground
   group_by(as.factor(SomethingPresentOntheGround)) %>% 
   tally()

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

abmounds <- ableftj %>% 
  filter(SomethingPresentOntheGround == "mound") 
# 406 results

# Potential mounds 2020 ("could have been a mound in the past") 
ableftj %>%
  filter(SomethingPresentOntheGround != "nothing") %>% 
  filter(SomethingPresentOntheGround != "tell")
# >> 417 results

# now try a full join (both match) 
ab2010 <- full_join(mounds_adela, mounds_bara, 
                     by = c("Trap" = 'TRAPCode'))

ab2010%>% 
  filter(SomethingPresentOntheGround == "mound") # same 406 records 

ab2010 %>% 
  select(Trap, TopoID.x, TopoID.y, SomethingPresentOntheGround, Type, Height.x, Height.y, Length,`Length (max, m)`) %>% 
  group_by(Type, SomethingPresentOntheGround) %>% 
  tally()
# 50 additional features in Bara's record are mostly GC failed, nothing and other features. There are only 10 moundlike records. 
# Lets' look at them more closely.

ab2010 %>% 
  select(Trap, TopoID.x, TopoID.y, SomethingPresentOntheGround, Type, Height.x, Height.y, Length,`Length (max, m)`) %>% 
  filter(is.na(SomethingPresentOntheGround)) %>% 
  filter(grepl("Mound",Type)) #  

# 11 records here range from Burial Mound(?) to Extinct Burial Mound, 6/11 lack dimensions and show inconsistencies
# such as Extinct status but 5 m height. Topo ID of 1936 (not a range used in Yambol, )
# not worth it to use ab2010 grab these 10-11 remainders from bara. Continue with Adela 


#### KNOWN PROBLEMS WITH MEANINGFUL MOUNDS

# Check what hides in bara's dataset where it says 'mound' in adela's
abmounds %>% 
  select(Trap, TopoID.x, TopoID.y, SomethingPresentOntheGround, Type, Height.x, Height.y, Length,`Length (max, m)`) %>% 
  group_by(Type, SomethingPresentOntheGround) %>% 
  tally()
abmounds %>% 
 # select(Trap, TopoID.x, Type) %>% 
  filter(Type == "Surface Scatter") # mound 9042 might need an extra check

## TopoIDs first    
checktopo <- if_else(abmounds$TopoID.x == abmounds$TopoID.y, "equal", "nonequal")
(checktopo[checktopo=="nonequal"])
mismatchTopo <- which(checktopo=="nonequal") # indeces of 8 problematic TopoId
problemTopo <- abmounds[mismatchTopo,] 

# ABmounds have 8 records with discrepant TopoIDs, where there is 0 in Bara there is a TopoID in Adela


## Length 
checklength <- if_else(abmounds$Length == abmounds$`Length (max, m)`, "equal", "nonequal")
checklength[checkwidth=="nonequal"] 
problemLength <- abmounds[which(checkwidth=="nonequal"),] 
problemLength %>% 
  select(Trap, TopoID.x, TopoID.y, Width.x,Width.y, Height.x, Height.y, Length,`Length (max, m)`,) %>% 
  mutate(diff= as.numeric(`Length (max, m)`) - as.numeric(Length))

# 8 records in abmounds have non-matching width, which ranges from 5 to 50 m

## Width 
checkwidth <- if_else(abmounds$Width.x == abmounds$Width.y, "equal", "nonequal")
checkwidth[checkwidth=="nonequal"] 
problemWidth <- abmounds[which(checkwidth=="nonequal"),] # 14 records have non-matching width
problemWidth %>% 
  select(Trap, TopoID.x, TopoID.y, Height.x, Height.y, Width.x,Width.y ) %>% 
  mutate(diff= as.numeric(Width.y) - as.numeric(Width.x))
# 8 records in abmounds have non-matching width, which ranges from 5 to 50 m
# this is same as length as most mounds are round


## Heights 
checkheight <- if_else(abmounds$Height.x == abmounds$Height.y, "equal", "nonequal")
problemHeight <- abmounds[which(checkheight=="nonequal"),]  # 26 obs have non-matching height

problemHeight %>% 
  select(Trap, TopoID.x, TopoID.y, Height.x, Height.y) %>% 
  filter(as.numeric(Height.x) > 0) %>%  # need to make numeric as atlas numbers are coming as characters
  filter(as.numeric(Height.y) > 0) %>% 
  mutate(HeightDiff = as.numeric(Height.x) - as.numeric(Height.y)) #%>% 
 # tally(HeightDiff < 0)
 # 26 records in merged dataset show discrepancy (4 don't have values in Adela, 2 lack values in bara) > remaining 20 values are split evenly between higher and smaller heights


# SUMMARY
# We have 444 linked records between A and B, out of which 406 are meaningful mounds, and additional 11 potential mounds. 
 # 8 mounds have discrepancy in diameter, both length and width, between adela and bara
 # 26 mounds show discrepancy in height between adela and bara, 6 have missing data (filled in from atlas)
 # 20 genuine difference split evenly 10:10 larger or smaller than bara/adela

