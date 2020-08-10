############################################################################################################
#                   ENRICHING MASTER DATASET WITH SPATIAL DATA 
############################################################################################################
#

# Goal
# Enrich the master dataset of all visited features in the Yambol province and surroundings from 2009-2018 with spatial data. 
# Such dataset can be used to generate subset data such as all visited features in Yambol, 
# Have both attribute and spatial data for verified features and mounds - conservative and liberal, in Yambol and everywhere.
# Verify that we are catching all salvageable features by merging an attribute workflow from Excel and Open Refine with ArcGIS work; 
# these two workflows had been separate, which can contribute to error.

# Inputs
# 1) Attributes
# Master dataset from script 05 containing all verified features that have dimensions and have been groundtruthed and streamlined. 
# It needs further subsetting into mounds and other features and in/out of Yambol features and mounds, but that can happen as a result of 
# spatial overlay.

# 2) Shapefiles
# LARGEST: Verified 2009-2018 mound dataset, as a shapefile Ver09_18.shp and Verified0819.csv exported from ArcGIS on 22 July. It represents a combination of bara's conservative in-Yambol dataset
# with Sliven mounds added, as well as Malomirovo mounds from day 1 cut off, etc. 
# These datasets are 1033 long, and collate Baras verified data with my additions (all of 2010 or only a section>>)
# plus 2017 Sliven section of Elenovo dataset. It is on the conservative side when it comes to feature type.

# SMALLER: Spatially conservative and permit-covered shapefile
# 20092010VerifiedMounds (n = 887) [check that name has not changed?] - represents a bara's strictly in-Yambol dataset 2009-2018 
# without Sliven mounds from 2017 or Malomirovo mounds from day 1. It is data we expect to be in AKB national register of sites.


# Prerequisites 
# 1) previously cleaned master datasets from 2009-2018 with shared column names
# 2) spatial data from GIS that contains TRAP IDs 
# 3) consistent but not necessarily perfect column content in 1 and 2

# Process 
# 1) load master attribute dataset and large shapefile
# 2) design merging workflow
# 3) compare TRAP IDs and see the extent of mismatch between shapefile and attribute - is there anything we can salvage>
# 4) do basic streamlining


# Library
library(sf)
library(tidyverse)

##################################    LOAD SPATIAL DATA

# load mound/feature shapefile created in ArcGIS (1240 features, 1 known spatial duplicate, ~346 TopoIDs, 1240 TRAPids)
shapefile <- st_read("C:/Users/Adela/Documents/Professional/Projects/MQNS/GIS/Vectors/200918VisitedMax.shp") # large file compiled by Adela
plot(shapefile$geometry, col = "red")
plot(shapefile$geometry[which(shapefile$TRAP%in%master$TRAP)]) # difference of ca 60 points which lack dimensions
shapefilemin <- st_read("C:/Users/Adela/Documents/Professional/Projects/MQNS/GIS/Vectors/200918VisitedMinYam.shp") # conservative file from Bara
plot(shapefilemin$geometry, pch = 17, add =TRUE)

##################################    INVESTIGATE OVERLAP BETWEEN SPATIAL DATASETS AND ATTRIBUTE DATA

# a few diagnostics on matching TRAP ids between shapefiles 
# spatial
shapefilemin$TRAP[which(shapefilemin$TRAP%nin%shapefile$TRAP)]# 2 Bara's TRAP features 8229, 9454 are missing from adela's GIS shapefile or master  
master %>% filter(TRAP==9454) # tibble of 0
m2010

sort(shapefile$TRAP[which(shapefile$TRAP%nin%shapefilemin$TRAP)]) # over 300 adela TRAP features are missing from Bara (this makes sense, many are outside Yambol)

# attribute data and larger shapefile
length(which(shapefile$TRAP%in%master$TRAP)) # 1174 shapes from max shapefile have match in master dataset
length(which(shapefile$TRAP%nin%master$TRAP)) # 66 shapes from max shapefile are missing from master (makes sense as I excluded poor records, while they still have shape representation)
(missingshapes <- sort(shapefile$TRAP[which(shapefile$TRAP%nin%master$TRAP)])) # shapes with no attribute records 

miss_atrap10 <- mounds_adela$TRAP[which(mounds_adela$TRAP%nin%mounds_bara$TRAPCode)] # 53 of adela's TRAP ids are not in Baras (and therefore missing from shapefile)
miss_btrap10 <- mounds_bara$TRAPCode[which(mounds_bara$TRAPCode%nin%mounds_adela$TRAP)] # 50 of bara's TRAP ids are not in Adela (and missing from master)
salvageableBara <- mounds_bara[which(mounds_bara$TRAPCode%nin%mounds_adela$TRAP),] %>% filter(Height > 0) # 7 (5 actually) salvageable mounds
salvageableBara %>% 
  select(TRAPCode, TopoID, Width, Height, Condition, Principal, LandUseAround, LanduseOn) # 8092 and 9460 are suspect, others seem ok

# which survey survey seasons are mismatches mostly from? 
length(which(missingshapes%in%mnd2009$TRAPCode)) # 3 come from 2009
length(which(missingshapes%in%mnd2010$TRAP)) # 0 come from 2010
length(which(missingshapes%in%miss_atrap10)) # 5 missing shapes come from 2010 adela  (uncertain or other features?)
length(which(missingshapes%in%miss_btrap10)) # 23 come from 2010 bara
length(which(missingshapes%in%mnd2017$identifier)) # 0 missing shapes come from 2017
length(which(missingshapes%in%mnd2018$identifier))# 0 missing shapes come from 2018

# some 31 missing shapes have been filtered out of the component attribute datasets because of missing dimensions or no data in landuse.
# ~30 shapes do not seem to have ever had an accompanying attribute record or were part of Bara's dataset 
# Five mounds may be worth saving (salvageableBara)


# Overlap between mound shapes in GIS and master dataset based on attributes.

master %>% 
  group_by(Type) %>% 
  tally()

master %>% 
  filter(grepl("Mound", Type)) %>% 
  group_by(Type) %>% 
  tally()

# 1055 of both certain, uncertain and extinct mounds

master %>%
  filter(Type == "Burial Mound" | Type == "Extinct Burial Mound")
# 832 mounds, 987 mound or extinct mounds

master %>% 
  filter(TRAP%in%shapefile$TRAP) %>% 
  #filter(Type == "Burial Mound")
  filter(Type == "Burial Mound" | Type == "Extinct Burial Mound")
# 829 mounds with a matching ID in shapefile, or 984 extinct and burial mounds 



##################################    MARGE ATTRIBUTE AND SPATIAL DATA MASTER_SP

master_sp <- shapefile %>% inner_join(master, c=by("TRAP"="TRAP")) # 1174 records
plot(master_sp$geometry)

master_sp %>% 
  filter(Type == "Burial Mound" | Type == "Extinct Burial Mound") %>% 
  plot()


##################################    MERGE ATTRIBUTE AND SPATIAL DATA AND PRINT TO LOCAL FILES


shapefile_coord <- cbind(shapefile, X = st_coordinates(shapefile)[,1], Y =st_coordinates(shapefile)[,2]) # extracting X, Y out of mound shapefile
shapefile_4236 <- st_transform(shapefile_coord, crs = 4326) # converting to Web Mercator, GSC in order to have Lat Long in addition to X, Y

######### MOUNDS ONLY

#### Mounds inside and outside Yambol
mounds_all <- master %>%
  filter(Type == "Burial Mound" | Type == "Extinct Burial Mound") %>% 
  inner_join(shapefile_coord, c=by("TRAP"="TRAP"))
write.csv(mounds_all, "output_data/mounds_all.csv")


#### Mounds in Yambol

#Lets look what falls inside the region and prep the overlay
plot(Y_region$geometry,  col = "pink")
plot(st_intersection(shapefile$geometry, Y_region), add = TRUE)
?st_intersection

# region polygon needs the attributes skipped to not clutter the final mound dataframe
Y_region <- Y_region %>% 
  select(OBJECTID, geometry)
shapefile_Yam <- st_intersection(shapefile_coord, Y_region)

# inner join
mounds_Yam <- master %>%
  filter(Type == "Burial Mound" | Type == "Extinct Burial Mound") %>% 
  inner_join(shapefile_Yam, c=by("TRAP"="TRAP"))%>% 
  select(-OBJECTID)
write.csv(mounds_Yam, "output_data/mounds_Yam.csv")

#### Features inside and outside Yambol
features_all <- master %>%
   inner_join(shapefile_coord, c=by("TRAP"="TRAP"))
write.csv(features_all, "output_data/features_all.csv")

#### Features inside Yambol
features_Yam <- master %>%
  inner_join(shapefile_Yam, c=by("TRAP"="TRAP"))
write.csv(features_Yam, "output_data/features_Yam.csv")

