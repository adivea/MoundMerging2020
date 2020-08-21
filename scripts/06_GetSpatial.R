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
# 2) design merging workflow
# 3) compare TRAP IDs and see the extent of mismatch between shapefile and attribute - is there anything we can salvage>
# 4) do basic streamlining


# Library
library(sf)
library(tidyverse)
library(raster)
library(rgdal)
library(FSA)

##################################    LOAD SPATIAL DATA

# load mound/feature shapefile created in ArcGIS (1240 features, 1 known spatial duplicate, ~346 TopoIDs, 1240 TRAPids)
mnd_shp <- st_read("C:/Users/Adela/Documents/Professional/Projects/MQNS/GIS/Vectors/200918VisitedMax.shp") # large file compiled by Adela
plot(mnd_shp$geometry, col = "red")
plot(mnd_shp$geometry[which(mnd_shp$TRAP%in%master$TRAP)]) # difference of ca 60 points which lack dimensions
mnd_shpmin <- st_read("C:/Users/Adela/Documents/Professional/Projects/MQNS/GIS/Vectors/200918VisitedMinYam.shp") # conservative file from Bara
plot(mnd_shpmin$geometry, pch = 17, add =TRUE)


##################################    EXTRACT COORDINATES FROM SPATIAL DATA AND ADD THEM TO OBJECTS

# As simple features don't advertise coordinates (X, Y), I extract them and print them into two separate columns 
mnd_sp32635 <- cbind(mnd_shp, X = st_coordinates(mnd_shp)[,1], Y =st_coordinates(mnd_shp)[,2]) 

# # After the extraction of X and Y in 32635 EPSG, I want also a spatial object in 4326 EPSG for web visualisation
# # converting to Web Mercator, GSC in order to have Lat Long in addition to X, Y
# mnd_sp4326 <- mnd_shp %>% 
#   st_transform(crs = 4326) %>% 
#   cbind(Lat = st_coordinates(mnd_shp)[,1], Long =st_coordinates(mnd_shp)[,2])
# 
# mnd_sp4326


##################################    MERGE ATTRIBUTE AND SPATIAL DATA INTO MASTER_SP SF OBJECT

# Full join between simple features and attributes, resulting in sf object
master_sp <- mnd_sp32635 %>% inner_join(master, c=by("TRAP"="TRAP")) # 1174 records
plot(master_sp$geometry)

# looks ok? 
ggplot(master_sp, aes(X, Y))+
  geom_sf(colour = "red")


master_sp %>% 
  filter(Type == "Burial Mound" | Type == "Extinct Burial Mound") %>% 
  plot()
