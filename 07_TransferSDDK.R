##################################    MOVE OUTPUTS TO SCIENCEDATA.DK 

# Inputs: 
# Products of the attribute cleaning and merging with spatial data from ArcGIS, created in scripts 05 and 06
# Eventually we wish to merge in also the enriched data from rasters derived from the SpatialEnrichment script

# Package for data transfer to sddk
#devtools::install_github("sdam-au/sdam")

# Libraries 
library(sdam)
library(getPass)

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
