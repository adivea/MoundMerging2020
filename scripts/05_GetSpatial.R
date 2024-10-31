############################################################################################################
#                   CONNECTING MASTER DATASET WITH SPATIAL DATA 
############################################################################################################
#

# Goal
# Enrich the master dataset of all visited features in the Yambol province and surroundings from 2009-2022 with spatial data. 
# Such dataset can be used to generate subset data such as all visited features in Yambol, 
# Have both attribute and spatial data for verified features and mounds - conservative and liberal, in Yambol and everywhere.
# Verify that we are catching all salvageable features by merging attributes cleaned in Open Refine with ArcGIS work; 
# Deal with problems that arose from a separate attribute and spatial data cleaning workflows.

# Prerequisites 
# 1) previously cleaned master datasets from 2009-2018 with shared column names
# 2) spatial data from GIS that contains TRAP IDs 
# 3) consistent but not necessarily perfect column content in 1 and 2

# Inputs
# 1) Attributes
# Master dataset from script 04_MergeToMaster containing all verified features that have dimensions and have been groundtruthed and streamlined. 
# It needs further subsetting into mounds and other features and in/out of Yambol features and mounds, but that can happen later in
# spatial overlay.

# 2) Shapefiles
# Verified 2009-2018 mound dataset, as a shapefile 200918VisitedMax.shp exported from ArcGIS on 22 July 2020. 
# It is a conservative reading of field-verified mounds in Yambol and Sliven 
# as well as Malomirovo mounds excluding day 1.  
# Spatial points in these datasets combine Bara's verified data with my additions. 
# There is all of 2010 data plus 2017 data including Sliven section. It is on the conservative side
# when it comes to feature type. Errors discovered in location (e.g. 8142) are fixed before spatialization

# Process 
# 1) load master attribute dataset and the verified shapefile
# 2) design merging workflow and clean up coordinates where known as wrong
# 3) compare TRAP IDs and see the extent of mismatch between shapefile and attribute - is there anything we can salvage>
# 4) do basic streamlining

# Outputs
# 4 objects: master_sp, mnd_sp32635, mnd_sp4326, 
# 2 loaded datasets mnd_shp, and mnd_shpmin(not used further)

# Library
library(sf)
library(tidyverse)

#################    LOAD SPATIAL DATA
input <- "master"
if (exists(input)){
  print("file exists")
  get(input)
}  else  {
  print("file doesnot exist")
  print("so we load it from rds")
  source("scripts/04_MergeToMaster.R")
  
  #master <- readRDS("output_data/interim/mergedcleanfeatures2023.rds")
}


glimpse(master)

##################    LOAD SPATIAL DATA from 2009-2018. 2022 comes later

# load mound/feature shapefile created in ArcGIS (1240 features from 2009-2018, 1 known spatial duplicate, ~346 TopoIDs, 1240 TRAPids)
mnd_shp <- st_read("input_data/Vectors/200918VisitedMax.shp") # large file compiled by Adela
plot(mnd_shp$geometry, col = "red")

paste("plotting 1240 points from 2009-2018 master")

plot(mnd_shp$geometry[which(mnd_shp$TRAP%in%master$TRAP)]) # difference of ca 60 points which lack dimensions [coordinates?]


##################    EXTRACT COORDINATES FROM SPATIAL 09-18 DATA 

# As simple features don't advertise coordinates (X, Y), I extract them and print them into two separate columns 
mnd_sp32635 <- cbind(mnd_shp, X = st_coordinates(mnd_shp)[,1], Y=st_coordinates(mnd_shp)[,2]) 
mnd_sp32635 %>% 
  st_drop_geometry() %>% 
  glimpse()

##################  ADD 2022 SPATIAL DATA

# Add the last season's (2022) spatial data because it was created from FAIMS app
mnd_sp32635 <- rbind(st_drop_geometry(mnd_sp32635), 
                     data.frame(TopoID = m2022$uuid, Note= m2022$AllNotes, TRAP = m2022$TRAP, 
                                X = m2022$Easting, Y =m2022$Northing))

##################  SPATIAL FIXES (FOR WRONG LOCATIONS)

# Upon final visual review, we detected inconsistencies and errors in the 
# spatial point aggregate mnd_sp32635. These are fixed here and a final aggregate
# version m_sp is generated

# Fix the coordinates of 8142 which is 300 m off its location (actually under a windmill)

m8142 <-data.frame(TopoID = 200562, Note = "poorly geocoded TopoID200562", TRAP = 8142, X = 467040.37, Y = 4698768.43) 

sort(mnd_sp32635$TRAP)

mnd_sp32635 %>% 
  filter(TRAP == 8142)
mnd_sp32635[mnd_sp32635$TRAP == 8142,]


m_sp <- rows_update(
  mnd_sp32635,
  m8142,
  by = "TRAP")

m_sp[m_sp$TRAP == 8142,]

# BEWARE some intractable problems remain:
# For example, 9313 geospatial info in m2010 may be wrong as the description is 
# inconsistent with its photo (road in the image, none in GoogleEarth)
# the TopoID from 2010 (Royce) differs from 2017(faims) so don't go by it.
# Fieldwork is needed.
# library(mapview)
# mapview(m_sp[m_sp$TRAP == 9313,])

##################  MERGE ATTRIBUTE AND RE-SPATIALIZE INTO MASTER_SP SF OBJECT

# Full join between simple features and attributes, resulting in sf object
master_sp <- m_sp %>% inner_join(master, c=by("TRAP"="TRAP")) # 1484 records
paste("Joined spatial data to attributes in a  basic master_sp")

master_sp %>% 
  mutate(year = year(Date)) %>% 
  group_by(year) %>% 
  count(year) 

master_sp <- master_sp %>% 
  dplyr::select(-DiameterMin) %>% 
  st_as_sf(coords = c("X", "Y"), crs = 32635)

paste("Created a sf object out of joined master_sp")

# looks ok? 
plot(master_sp$geometry)
paste("master spatial data exists")
glimpse(master_sp)

# Check attributes
master_sp %>% 
  filter(Type == "Burial Mound" | Type == "Extinct Burial Mound") %>% 
  ggplot()+
  geom_sf(aes(size = HeightMax, alpha = 0.5))

# Save rds
saveRDS(master_sp, "output_data/master_sp.rds")

# Clean up
rm(m8142, m, m_sp, mnd_shp, mnd_sp32635, df_name, i, input, names_all,
   names_faims, names_manual, script)

##############      FAIMS DATA

m_Faims <- read_csv("output_data/interim/faimsmaster.csv")
glimpse(m_Faims)
Faims4326 <- m_Faims %>%
  filter(!is.na(Latitude)) %>% 
  st_as_sf(coords = c("Longitude","Latitude"), crs = 4326)

write_rds(Faims4326, "output_data/interim/faims4326.rds")

# Clean up
rm(m_Faims, Faims4326)
