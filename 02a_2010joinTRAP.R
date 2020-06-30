# Purpose

# This script helps generate a clean 2010 dataset, an intermediate step towards verified mounds in Yambol from field surveys 2009-2018. 
# The cleaning happens in 2 stages: 
# 1) it takes 2010 version adela and bara as two inputs. 
# 2) It merges via left join to adelas and compare two legacy datasets, address discrepancies, and extracts ground truthing information. 
# 3) it outputs a cleanish verified mound dataset called abmounds

# Libraries
library(tidyverse)

# Load the datasets
source(LoadData.R)

# Check for TRAP ID
summary(mounds_adela$TRAP)
summary(mounds_bara$TRAPCode)
mounds_bara %>% 
  filter(TRAPCode==0)

### Merge datasets to compare data quality
# https://dplyr.tidyverse.org/reference/join.html

######################################################################################################################

## PARTIAL JOIN - MEANINGFUL MOUNDS ABMOUNDS

## MERGE BY TRAP
# I consider my dataset better and so start with a left join to adela's table via TRAP id to preserve adela's data and append bara's
# all mounds should have TRAP number since they have been surveyed (in theory) and verified. 
#Line 21-22 shows that Bara's dataset has 10 mounds with missing TRAP ID. These are missing because mounds were not reachable/accessible in the field.

ableftj <- left_join(mounds_adela, mounds_bara, 
                       by = c("TRAP" = 'TRAPCode')) # 444 observations on the basis of 444 adelas
ableftj%>% 
  filter(TopoID.x==0) %>% 
  select(TRAP, SomethingPresentOntheGround, TopoID.x, TopoID.y, Width.x, Width.y)
# 444 mounds have been documented in 2010; 292 of adela's them have an equivalent in the map (features have TopoID). 


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


################################################################################################

## FULL JOIN AB2010

# now try a full join (both match). It can be an issue as erroneous data in bara is added, and needs to be filtered
ab2010 <- full_join(mounds_adela, mounds_bara[-which(mounds_bara$TRAPCode==1936),],   # 1936 is a wrong number (too low to have been used in Yambol)
                     by = c("TRAP" = 'TRAPCode'))

ab2010%>% 
  filter(SomethingPresentOntheGround == "mound") # same 406 records same as in conservative abmounds above

ab2010 %>% 
  select(TRAP, TopoID.x, TopoID.y, SomethingPresentOntheGround, Type, Height.x, Height.y, Length,`Length (max, m)`) %>% 
  group_by(Type, SomethingPresentOntheGround) %>% 
  tally()
# 50 additional features in Bara's record are mostly GC failed, nothing and other features. There are only 10 moundlike records. 
# Lets' look at them more closely.

ab2010 %>% 
  select(TRAP, TopoID.x, TopoID.y, SomethingPresentOntheGround, Type, Height.x, Height.y, Length,`Length (max, m)`) %>% 
  filter(is.na(SomethingPresentOntheGround)) %>% 
  filter(grepl("Mound",Type)) 

# 10 records here range from Burial Mound(?) to Extinct Burial Mound, 6/11 lack dimensions and show inconsistencies
# such as Extinct status but 5 m height. Topo ID of 1936 (not a range used in Yambol, )
# not worth it to use ab2010 grab these 10-11 remainders from bara. Continue with Adela 




