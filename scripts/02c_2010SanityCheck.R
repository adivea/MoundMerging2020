###########################################################################################################

#### KNOWN PROBLEMS WITH CONSERVATIVE MEANINGFUL MOUNDS  (n=406)

# Prerequisites: 
# Objects mnd2010 (left join) and ab2010 (full join), which are the outputs of 02_2010DataTRAP.R 

# Check what hides in bara's dataset where it says 'mound' in adela's
mnd2010 %>% 
  select(TRAP, TopoID.x, TopoID.y, SomethingPresentOntheGround, Type, Height.x, Height.y, Length,`Length (max, m)`) %>% 
  group_by(Type, SomethingPresentOntheGround) %>% 
  tally()  # ouch at least one scatter!
mnd2010 %>% 
  # select(TRAP, TopoID.x, Type) %>% 
  filter(Type == "Surface Scatter") # mound 9042 might need an extra check; in Bara GIS: "stones". in GEPro a massive stony circle (a Tell, a flat site?)

## TopoIDs first    
checktopo <- if_else(mnd2010$TopoID.x == mnd2010$TopoID.y, "equal", "nonequal")
(checktopo[checktopo=="nonequal"])
mismatchTopo <- which(checktopo=="nonequal") # indeces of 8 problematic TopoId
problemTopo <- mnd2010[mismatchTopo,] 

# mnd2010 have 9 records with discrepant TopoIDs, where there is 0 in Bara there is a TopoID in Adela


## Length 
checklength <- if_else(mnd2010$Length == mnd2010$`Length (max, m)`, "equal", "nonequal")
checklength[checklength=="nonequal"] 
problemLength <- mnd2010[which(checklength=="nonequal"),] 
problemLength %>% 
  select(TRAP, TopoID.x, TopoID.y, Width.x,Width.y, Height.x, Height.y, Length,`Length (max, m)`) %>% 
  mutate(diff= as.numeric(`Length (max, m)`) - as.numeric(Length))
# 8 records in mnd2010 have non-matching width, which ranges from 5 to 50 m; 

## Width 
checkwidth <- if_else(mnd2010$Width.x == mnd2010$Width.y, "equal", "nonequal")
checkwidth[checkwidth=="nonequal"] 
problemWidth <- mnd2010[which(checkwidth=="nonequal"),] # 14 records have non-matching width
problemWidth %>% 
  select(TRAP, TopoID.x, TopoID.y, Height.x, Height.y, Width.x,Width.y ) %>% 
  mutate(diff= as.numeric(Width.y) - as.numeric(Width.x))
# 8 records in mnd2010 have non-matching width, which ranges from 5 to 50 m
# this is same as length as most mounds are round


## Heights 
checkheight <- if_else(mnd2010$Height.x == mnd2010$Height.y, "equal", "nonequal")
problemHeight <- mnd2010[which(checkheight=="nonequal"),]  # 26 obs have non-matching height

problemHeight %>% 
  select(TRAP, TopoID.x, TopoID.y, Height.x, Height.y) %>% 
  filter(as.numeric(Height.x) > 0) %>%  # need to make numeric as atlas numbers are coming as characters
  filter(as.numeric(Height.y) > 0) %>% 
  mutate(HeightDiff = as.numeric(Height.x) - as.numeric(Height.y)) %>% 
  tally(HeightDiff < 0)
# 20 records in merged dataset show discrepancy (4 don't have values in Adela, 2 lack values in bara) > remaining 20 values are split evenly between higher and smaller heights


# SUMMARY
# We have 444 linked records between A and B, out of which 406 are meaningful mounds called mnd2010 here, and additional 11 potential mounds. 
# 8 mounds have discrepancy in diameter, both length and width, between adela and bara
# 20 mounds show discrepancy in height between adela and bara, 6 have missing data (filled in from atlas)
# 20 genuine difference split evenly 10:10 larger or smaller than bara/adela



###############################################################################################################################################
###########################################################################################################

#### KNOWN PROBLEMS WITH FULL JOIN MOUNDS  (N=493)

# Check what hides in bara's dataset where it says 'mound' in adela's
ab2010 %>% 
  select(TRAP, TopoID.x, TopoID.y, SomethingPresentOntheGround, Type, Height.x, Height.y, Length,`Length (max, m)`) %>% 
  group_by(Type, SomethingPresentOntheGround) %>% 
  tally()  # ouch at least one scatter!
ab2010 %>% 
  # select(TRAP, TopoID.x, Type) %>% 
  filter(Type == "Surface Scatter") # mound 9042, 9053, 9458 might need an extra check; 
# in Bara GIS: "9042 stones". in GEPro a massive stony circle (a Tell, a flat site?)

## TopoIDs first    
checktopo <- if_else(ab2010$TopoID.x == ab2010$TopoID.y, "equal", "nonequal")
(checktopo[checktopo=="nonequal"])
mismatchTopo <- which(checktopo=="nonequal") # indeces of 8 problematic TopoId
problemTopo <- ab2010[mismatchTopo,] 

# ab2010 have 9 records with discrepant TopoIDs, where there is 0 in Bara there is a TopoID in Adela


## Length 
checklength <- if_else(ab2010$Length == ab2010$`Length (max, m)`, "equal", "nonequal")
problemLength <- ab2010[which(checklength=="nonequal"),] 
problemLength %>% 
  select(TRAP, TopoID.x, TopoID.y, Width.x,Width.y, Height.x, Height.y, Length,`Length (max, m)`) %>% 
  mutate(diff= as.numeric(`Length (max, m)`) - as.numeric(Length))
# 15 records in ab2010 have non-matching width, which ranges from 5 to 50 m; 

## Width 
checkwidth <- if_else(ab2010$Width.x == ab2010$Width.y, "equal", "nonequal")
problemWidth <- ab2010[which(checkwidth=="nonequal"),] # 14 records have non-matching width
problemWidth %>% 
  select(TRAP, TopoID.x, TopoID.y, Height.x, Height.y, Width.x,Width.y ) %>% 
  mutate(diff= as.numeric(Width.y) - as.numeric(Width.x))
# 14 records in ab2010 have non-matching width, which ranges from 5 to 50 m
# this is same as length as most mounds are round


## Heights 
checkheight <- if_else(ab2010$Height.x == ab2010$Height.y, "equal", "nonequal")
problemHeight <- ab2010[which(checkheight=="nonequal"),]  # 26 obs have non-matching height
problemHeight %>% 
  select(TRAP, TopoID.x, TopoID.y, Height.x, Height.y) %>% 
  filter(as.numeric(Height.x) > 0) %>%  # need to make numeric as atlas numbers are coming as characters
  filter(as.numeric(Height.y) > 0) %>% 
  mutate(HeightDiff = as.numeric(Height.x) - as.numeric(Height.y)) %>% 
  tally(HeightDiff < 0)
# 21 records in merged dataset show discrepancy (4 don't have values in Adela, 2 lack values in bara) > remaining 20 values are split evenly between higher and smaller heights


# SUMMARY
# ab2010 - with 22% more mounds (493 vs 406) I expect more discrepancies in measurements height (how is that possible?) than mnd2010

# 14-15 mounds have discrepancy in diameter, both length and width, between adela and bara; PRETTY BAD > 20% more mounds. 50% more errors
# 21 mounds show discrepancy in height between adela and bara, 6 have missing data (filled in from atlas) NOT BAD given 20% more mounds and only 5 % more error
# 21 genuine difference split evenly 10:10 larger or smaller than bara/adela