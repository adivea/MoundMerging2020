############################################################################################################
#                   CONNECTING MASTER DATASET WITH SPATIAL DATA 
############################################################################################################
#

# Goal
# Enrich the master dataset of all visited features in the Yambol province and surroundings from 2009-2022 with spatial data. 
# Such dataset can be used to generate subset data such as all visited features in Yambol, 
# Have both attribute and spatial data for verified features and mounds - conservative and liberal, in Yambol and everywhere.
# Verify that we are catching all salvageable features by merging an attribute workflow from Excel and Open Refine with ArcGIS work; 
# these two workflows had been separate, which can contribute to error.
# Deduplicate spatial duplicates (features re-visited in different seasons and given different ID)

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
# In addition, errors discovered in location (e.g. 8142) are fixed before spatialization

# SMALLER: Spatially conservative and permit-covered shapefile
# 20092010VerifiedMounds (n = 887) [check that name has not changed?] - represents a bara's strictly in-Yambol dataset 2009-2018 
# without Sliven mounds from 2017 or Malomirovo mounds from day 1. It is data we expect to be in AKB national register of sites.

# Outputs
# 4 csvs in output/data with Mounds everywhere, Mounds only in Yambol, features everywhere, features in Yambol
# 4 objects: master_sp, mnd_sp32635, mnd_sp4326, 
# 2 loaded datasets mnd_shp, and mnd_shpmin(not used further)

# Prerequisites 
# 1) previously cleaned master datasets from 2009-2018 with shared column names
# 2) spatial data from GIS that contains TRAP IDs 
# 3) consistent but not necessarily perfect column content in 1 and 2

# Process 
# 1) load master attribute dataset and large shapefile
# 2) design merging workflow and clean up coordinates where known as wrong
# 3) compare TRAP IDs and see the extent of mismatch between shapefile and attribute - is there anything we can salvage>
# 4) deduplicate places visited repeatedly (same/nearby points with different IDs) 
# 5) do  basic streamlining


# Library
library(sf)
library(tidyverse)
library(raster)
library(rgdal)
library(FSA)

##################################    LOAD SPATIAL DATA
input <- "master"
if (exists(input)){
  print("file exists")
  get(input)
}  else  {
  print("file doesnot exist")
  print("so we load it from rds")
  master <- readRDS("output_data/mergedcleanfeatures2023.rds")
}

#}  else source("scripts/05_MergeToMaster.R")

#glimpse(master)

##################################    LOAD SPATIAL DATA from 2009-2018. 2022 comes later

# load mound/feature shapefile created in ArcGIS (1240 features from 2009-2018, 1 known spatial duplicate, ~346 TopoIDs, 1240 TRAPids)
mnd_shp <- st_read("C:/Users/Adela/Documents/Professional/Projects/MQNS/GIS/Vectors/200918VisitedMax.shp") # large file compiled by Adela
plot(mnd_shp$geometry, col = "red")
paste("plotting 1174 points from 2009-2018 master")
plot(mnd_shp$geometry[which(mnd_shp$TRAP%in%master$TRAP)]) # difference of ca 60 points which lack dimensions [coordinates?]

# mnd_shpmin <- st_read("C:/Users/Adela/Documents/Professional/Projects/MQNS/GIS/Vectors/200918VisitedMinYam.shp") # conservative file from Bara
# plot(mnd_shpmin$geometry, pch = 17, add =TRUE)

##################################    EXTRACT COORDINATES FROM SPATIAL 09-18 DATA 

# As simple features don't advertise coordinates (X, Y), I extract them and print them into two separate columns 
mnd_sp32635 <- cbind(mnd_shp, X = st_coordinates(mnd_shp)[,1], Y=st_coordinates(mnd_shp)[,2]) 
mnd_sp32635 %>% 
  st_drop_geometry() %>% 
  glimpse()

# We add 2022 features' spatial data
mnd_sp32635 <- rbind(st_drop_geometry(mnd_sp32635), 
                     data.frame(TopoID = m2022$uuid, Note= m2022$AllNotes, TRAP = m2022$TRAP, 
                                X = m2022$Easting, Y =m2022$Northing))

##################################    SPATIAL FIXES (FOR WRONG LOCATIONS)

# Fix location of 8142 which is 300 m off its location (actually under a windmill)

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

# BEWARE: 9313 geospatial info in m2010 may also be wrong as the description is inconsistent with image (road on image, none in GE)
# the TopoID from 2010 (Royce) differs from 2017(faims) so don't go by it
# library(mapview)
# mapview(m_sp[m_sp$TRAP == 9313,])

##################################    MERGE ATTRIBUTE AND RE-SPATIALIZE INTO MASTER_SP SF OBJECT

# Full join between simple features and attributes, resulting in sf object
master_sp <- m_sp %>% inner_join(master, c=by("TRAP"="TRAP")) # 1174 records in 2020, 1550 in 2022
paste("Joined spatial data to attributes in a  basic master_sp")

master_sp <- master_sp %>% 
  dplyr::select(-DiameterMin) %>% 
  st_as_sf(coords = c("X", "Y"), crs = 32635)

paste("Created a sf object out of joined master_sp")

# looks ok? 
plot(master_sp$geometry)
paste("master spatial data exists")

# check attributes
master_sp %>% 
  filter(Type == "Burial Mound" | Type == "Extinct Burial Mound") %>% 
  ggplot()+
  geom_sf(aes(size = HeightMax, alpha = 0.5))



#################################################################################3
#################################################################################
#########      FAIMS DATA

glimpse(m_Faims)
m_Faims4326 <- m_Faims %>%
  filter(!is.na(Latitude)) %>% 
  st_as_sf(coords = c("Longitude","Latitude"), crs = 4326)
write_rds(m_Faims4326, "output_data/interim/m_faims4326.rds")
