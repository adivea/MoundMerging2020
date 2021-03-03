###################### ###################### ###################### ###################### 
#                       SAVE FINAL DATASET AND POST IT TO SCIENCEDATA.DK
###################### ###################### ###################### ###################### 

###################### EXPORT DATA -- MOUNDS ONLY - 2 DATASETS

# Prerequisite: Load regional boundary 
Y_region <- st_read("F:/Shared GIS/Vector/Oxbow Shapefiles/13_Janouch/Yambol_Region.shp")
# Region polygon needs the attributes culled to not clutter the final dataset
Y_region <- Y_region %>% 
        select(OBJECTID, geometry)



# Visual review
plot(Y_region$geometry,  col = "pink")
plot(st_intersection(mnd_shapes$geometry, Y_region), add = TRUE)



#### Mounds inside and outside Yambol *984 obs of 16 variables

mounds_all <- master_sp %>%
        filter(Type == "Burial Mound" | Type == "Extinct Burial Mound")  

write.csv(mounds_all, "output_data/mounds_all.csv")


#### Mounds inside Yambol *806 obs with 16 variables

# Crop by feature is achieved by st_intersection of sf object with regional boundary
mounds_Yam <- master_sp %>%
        filter(Type == "Burial Mound" | Type == "Extinct Burial Mound") %>% 
        st_intersection(Y_region, c=by("TRAP"="TRAP"))%>% 
        select(-OBJECTID)
names(mounds_Yam)
plot(mounds_Yam$geometry)
write.csv(mounds_Yam, "output_data/mounds_Yam.csv") 


######################## EXPORT DATA -  FEATURES - 2 DATASETS

#### Features inside and outside Yambol
write.csv(master_sp, "output_data/features_all.csv")
plot(master_sp$geometry) # 1174 obs and 16 variables

#### Features inside Yambol
features_Yam <- master_sp %>%
        st_intersection(Y_region, c=by("TRAP"="TRAP")) # 975 obs and 16 variables
write.csv(features_Yam, "output_data/features_Yam.csv")



##################################    MOVE OUTPUTS TO SCIENCEDATA.DK 

# Inputs: 
# Products of the attribute cleaning and merging with spatial data from ArcGIS, created in scripts 05 and 06
# Eventually we wish to merge in also the enriched data from rasters derived from the SpatialEnrichment script

# Package for data transfer to sddk
#devtools::install_github("sdam-au/sdam")

# Libraries 
library(sdam)
library(getPass)
library(here)

### Authentication options

# Alternative A
# Input your sciencedata.dk username - type directly into the RStudio console
user <- readline("your sciencedata username: ")
# Make the request (you will be asked for password in a new pop-up window)

# please note the difference in PUT/GET and sharingin/sharingout components of path and method 
# when you are trying to load data from and into sciencedata.

request("output_data/mounds_all.csv", path="/sharingin/648597@au.dk/SDAM_root/SDAM_data/mounds/",  # this request is to GET data out
        method="GET", cred=c(user, getPass("your sciencedata password: ")))
request("output_data/mounds_all.csv", path="/sharingout/648597@au.dk/SDAM_root/SDAM_data/mounds/",  # this request is to PUT data in
        method="PUT", cred=c(user, getPass("your sciencedata password: ")))

# Alternative B
# Save credentials as a vector of c("username", "password") and then use it with cred argument.

# descend into child directory
setwd("..")
getwd()
# Still does not generate desirable outcome (No visible change in the sddk directory)
sddk("mounds_Yam.csv", method="PUT", path = "/sharingout/648597@au.dk/SDAM_root/SDAM_data/mounds/", 
     cred=c(user, getPass("your sciencedata password: ")))
sddk("mounds_all.csv", method="PUT", path = "/sharingout/648597@au.dk/SDAM_root/SDAM_data/mounds/", 
     cred=c(user, getPass("your sciencedata password: ")))
sddk("features_Yam.csv", method="PUT", path = "/sharingout/648597@au.dk/SDAM_root/SDAM_data/mounds/", 
     cred=c(user, getPass("your sciencedata password: ")))
sddk("features_all.csv", method="PUT", path = "/sharingout/648597@au.dk/SDAM_root/SDAM_data/mounds/", 
     cred=c(user, getPass("your sciencedata password: ")))
sddk("output_data/mergedclean.csv", method="PUT", path = "/sharingout/648597@au.dk/SDAM_root/SDAM_data/mounds/", 
     cred=c(user, getPass("your sciencedata password: ")))
sddk("output_data/mergedfaims.csv", method="PUT", path = "/sharingout/648597@au.dk/SDAM_root/SDAM_data/mounds/", 
     cred=c(user, getPass("your sciencedata password: ")))
