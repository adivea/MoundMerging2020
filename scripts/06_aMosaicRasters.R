############################################################################################################
#                   MOSAIC RASTERS FOR MOUNDS 2009-2022 ENVIRO ENRICHMENT 
############################################################################################################
# This script documents how rasters necessary for 06_Enrich.Rmd in MoundMerging2023 repo
# were generated. 
# The mosaic components are ASTER DEMS for SE Bulgaria and North Turkey downloaded from JICA website
# and mosaiced to encompasses the Yambol province.
# The output serves to sample mound location attributes from

# Load ASTER DEM rasters, provided by JICA, in 4326 unprojected EPSG!
# projected files do not align and are non-trivial to merge

Yam <- raster("input_data/large/ASTGTM_N42E026_dem.tif")
Tur <- raster("input_data/large/ASTGTM_N41E026_dem.tif")

Yam # projected WGS84 0.00027 resolution, 3601x3601 cells
Tur # projected WGS84 0.00027 resolution, 3601x3601 cells

# Mosaic the two tiles to one covers the BG-TUR boundary 
library(raster)
library(rgdal)

YT_elev <- mosaic(Yam, Tur, fun = mean, tolerance = 1)
writeRaster(Y_elev, file="../output_data/Yelev.tif", format="GTiff", overwrite = TRUE)

# Project to 32635 so it's consistent with vector data
YT_elev32635 <- projectRaster(YT_elev, crs = 32635)

writeRaster(Y_Lelev32635, file= "../output_data/YT_elev32635.tif", format="GTiff", overwrite = TRUE)

# Crop to Yambol region boundary
Y_elev <- crop(YT_elev32635, Y_region)
Y_elev <- mask(Y_elev, Y_region)
writeRaster(Y_elev, "../output_data/Yelev32635.tif", format="GTiff", overwrite = TRUE)

# clean up
rm(Yam)
rm(Tur)
rm(Y_elev)
rm(YT_elev)
rm(YT_Lelev32635)