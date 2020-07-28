
# NEXT STEPS: MERGE WITH SPATIAL DATA > NEW SCRIPT 06
## CREATE SPATIAL COLUMNS IN MASTER DATASET

# Goal
# Have both attribute and spatial data for verified mounds - conservative and liberal, in Yambol and everywhere.

# Inputs

# 1) Largest
# Verified 2009-2018, as a shapefile Ver09_18.shp and Verified0819.csv exported from ArcGIS on 22 July. It represents a combination of bara's conservative in-Yambol dataset
# with Sliven mounds added, as well as Malomirovo mounds from day 1 cut off, etc. 
# These datasets are 1033 long, and collate Bara verified data with my additions (all of 2010 or only a section>>)
# plus 2017 Sliven section of Elenovo dataset. It is on the conservative side.

# 2) Conservative and more ethical 
# 20092010VerifiedMounds (n = 887) - represents a bara's conservative in-Yambol dataset with Sliven mounds as well as Malomirovo mounds from day 1 cut off.



# Library
library(sf)
library(tidyverse)


# load spatial data, 1240 features created in ArcGIS (1 known spatial duplicate, ~346 TopoIDs, 1240 TRAPids)
shapefile <- st_read("C:/Users/Adela/Documents/Professional/Projects/MQNS/GIS/Vectors/200918VisitedMax.shp")
plot(shapefile$geometry)
plot(shapefile$geometry[which(shapefile$TRAP%in%master$TRAP)]) # difference of ca 60 points which lack dimensions


# a few diagnostics on matching TRAP ids 
length(which(shapefile$TRAP%in%master$TRAP)) # 1174 shapes have match in master dataset
length(which(shapefile$TRAP%nin%master$TRAP)) # 66 shapes are missing from master
(missingshapes <- sort(shapefile$TRAP[which(shapefile$TRAP%nin%master$TRAP)]))

miss_atrap10 <- adelatrap10[which(adelatrap10%nin%baratrap10)] # which of adela's TRAP ids are not in Baras (and therefore missing from shapefile)
miss_btrap10 <- baratrap10[which(baratrap10%nin%adelatrap10)] # which of bara's TRAP ids are not in Adela (and missing from master)

length(which(missingshapes%in%mnd2009$TRAP)) # 0 come from 2009
length(which(missingshapes%in%mnd2010$TRAP)) # 0 come from 2010
length(which(missingshapes%in%miss_atrap10)) # 3 missing shapes come from 2010 adela  (uncertain or other features?)
length(which(missingshapes%in%miss_btrap10)) # 19 come from 2010 bara
length(which(missingshapes%in%mnd2017$TRAP)) # 0 missing shapes come from 2017
length(which(missingshapes%in%mnd2018$TRAP))# 0 missing shapes come from 2018

# the data has been filtered out of the component datasets probably becuase of missing dimensions.

# load csv with spatial data DONT USE
# verified <- read_csv("raw_data/Verified0918.csv")# this file is now obsolete and superceded; it represents the conservative bara output with sliven data 
# verified <- verified %>% 
#   select(TRAP, Xtext,Ytext, Easting, Northing, Topo_ID) %>% 
#   rename(Longitude = Xtext, Latitude = Ytext)


# Join?

master %>% 
  group_by(Type) %>% 
  tally()

master %>% 
  filter(grepl("Mound", Type)) %>% 
  group_by(Type) %>% 
  tally()

# 1058 of both certain, uncertain and extinct mounds

master %>%
  filter(Type == "Burial Mound" | Type == "Extinct Burial Mound")
# 833 mounds, 990 mound or extinct mounds

master %>% 
  filter(TRAP%in%shapefile$TRAP) %>% 
  filter(Type == "Burial Mound")
# 797 mounds 
# on second attempt, I get 831 mounds with a matching ID in shapefile, or 988 extinct and mounds 


master_points <- left_join(master, shapefile, by = "TRAP", copy = FALSE) ## maybe I need to join to the shapefile!!
