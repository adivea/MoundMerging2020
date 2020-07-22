
# NEXT STEPS: MERGE WITH SPATIAL DATA > NEW SCRIPT 06


# Goal
## CREATE SPATIAL COLUMNS IN MASTER DATASET


# Inputs
# Verified 2009-2018, as a shapefile Ver09_18.shp and Verified0819.csv exported from ArcGIS on 22 July. 
# These datasets are 1033 long, and collate Bara verified data with my additions (all of 2010 or only a section>>)
# plus 2017 Sliven section of Elenovo dataset. It is on the conservative side.



# LIBRARIES
library(sf)

# load spatial data

shapefile <- st_read("C:/Users/Adela/Documents/Professional/Projects/MQNS/GIS/Vectors/Ver09_18.shp")
plot(shapefile$geometry)
plot(shapefile$geometry[which(shapefile$TRAP%in%master$TRAP)])


length(which(shapefile$TRAP%in%master$TRAP))

# load csv with spatial data
verified <- read_csv("raw_data/Verified0918.csv")  
verified <- verified %>% 
  select(TRAP, Xtext,Ytext, Easting, Northing, Topo_ID) %>% 
  rename(Longitude = Xtext, Latitude = Ytext)


# What kinds of mounds do we have in the master dataset?
dim(master)

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
# 833 mounds, 990 mound and extinct mounds

master %>% 
  filter(TRAP%in%shapefile$TRAP) %>% 
  filter(Type == "Burial Mound")
# 797 mounds