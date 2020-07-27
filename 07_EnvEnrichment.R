## Mound data enrichment and analysis

# Goal
# Lets' do a bit of investigation of the mounds locations in the landscape 
# using the master dataset generated in previous scripts to sample the available DEM rasters for environmental data


# First, we need to extract environ data from rasters at mound coordinates

# Libraries
library(raster)
library(rgdal)
library(FSA)
library(sf)
methods(raster)

# Load raster, in this case ASTER DEM from JICA, projected to WGS82, UTM 35N
Yam <- raster("E:/TRAP Workstation/Shared GIS/Satellite imagery/ASTER/DEM/ASTGTM_N42E026/prjYAM_DEM_N42E026.tif")
Yam <- raster("F:/Shared GIS/Satellite imagery/ASTER/DEM/ASTGTM_N42E026/prjYAM_DEM_N42E026.tif")
Yam # projected WGS84 35N raster 27m resolution, 4112x3053
Yaspect<- raster("E:/TRAP Workstation/Shared GIS/Satellite imagery/ASTER/DEM/ASTGTM_N42E026/prjYAM_Aspect.tif")
Yslope<- raster("E:/TRAP Workstation/Shared GIS/Satellite imagery/ASTER/DEM/ASTGTM_N42E026/prjYAM_Slope.tif")

mounds <- st_read("C:/Users/Adela/Documents/Professional/Projects/MQNS/GIS/Vectors/200918VisitedMax.shp")
st_crs(mounds)



# Visual check of the data
plot(mounds$geometry)
plot(Yam)
plot(mounds$geometry, pch = 17, add = TRUE)


# Prerequisites to sampling - Coordinate system alignment

crs(Yam)
crs(mounds)
all.equal(crs(Yam),st_crs(mounds)) # does not look so, but maybe we should interpret

bbox(Yam)<st_bbox(mounds)

st_coordinates(mounds)
mound_coordinates <- data.frame(st_coordinates(mounds)) # don't add TRAP yet

# Sample elevations at mound locations

elevation <- raster::extract(Yam, mound_coordinates)
elev_Yammnds <- data.frame(mound_coordinates, mounds$TRAP,elevation=
                             raster::extract(Yam, mound_coordinates))

# Create a table with elevation, slope and aspect at mound locations

slope <- raster::extract(Yslope, mound_coordinates)
enviro_Yammnds <- data.frame(mound_coordinates, mounds$TRAP,
                             elevation=
                               raster::extract(Yam, mound_coordinates),
                             slope=
                              raster::extract(Yslope, mound_coordinates),
                             aspect=
                               raster::extract(Yaspect, mound_coordinates))


############################################################################################################

########################   continue here

#############################################################################################################


# There is something rotten in the prominence below, as it always averages out to a random 50% (unlikely) ; when I tested with a subset 
# the numbers were closer to my epxectations, so maybe it's a lot of mounds on a slope. 
enviro_Yammnds$prom250mbuff <- raster::extract(Yam,  # raster containing elevation data
                                        mound_coordinates, # centroids of mounds
                                        buffer = 250,
                                        #buffer = 250, # actual buffer size in crs units, in this case 250m  or ca 22x22 cells around kernel
                                        fun = function(x){perc(x,x[length(x)/2],"lt", na.rm = FALSE, digits = 2)})



enviro_Yammnds%>% 
  filter(prom250mbuff > 74) %>% 
  plot()


# Test with smaller subset to verify that the prominence values vary and are not random
mnd09shp <- mounds %>% 
  filter(TRAP%in%mnd2009$TRAP)%>% 
  filter(TRAP < 8020)

mnd09_coordinates <- data.frame(st_coordinates(mnd09shp)) # don't add TRAP yet
test <- raster::extract(Yam,  # raster containing elevation data
                mnd09_coordinates, # centroids of mounds
                buffer = 250,
                #buffer = 250, # actual buffer size in crs units, in this case 250m  or ca 22x22 cells around kernel
                fun = function(x){perc(x,x[length(x)/2],"lt", na.rm = FALSE, digits = 2)})
summary(test)
hist(test)


# Prominence at 1 and 2 and 5 km

enviro_Yammnds$prom1kmbuff <- raster::extract(Yam,  # raster containing elevation data
                                               mound_coordinates, # centroids of mounds
                                               buffer = 1000, # actual buffer size in crs units, in this case 250m  or ca 22x22 cells around kernel
                                               fun = function(x){perc(x,x[length(x)/2],"lt", na.rm = FALSE, digits = 2)})

enviro_Yammnds$prom2kmbuff <- raster::extract(Yam,  # raster containing elevation data
                                               mound_coordinates, # centroids of mounds
                                               buffer = 2000,# actual buffer size in crs units, in this case 250m  or ca 22x22 cells around kernel
                                               fun = function(x){perc(x,x[length(x)/2],"lt", na.rm = FALSE, digits = 2)})


hist(enviro_Yammnds$prom2kmbuff)

###################################################################################################### 
Yam_df <- as.data.frame(Yam, xy = TRUE)



nrow(elev_Yammnds)
hist(Yam_df$prjYAM_DEM_N42E026, main="Overlapping Regional and Mound Elevation")
hist(elev_Yammnds$elevation/rows, col=rgb(0.8,0.8,0.8,0.5))#, add=TRUE)
box()

ggplot() +
  geom_histogram(data=Yam_df, aes(prjYAM_DEM_N42E026))



Yam_df <- Yam_df %>%
  mutate(fct_elevation = cut(prjYAM_DEM_N42E026, breaks = 10))

ggplot() +
  geom_bar(data = Yam_df, aes(fct_elevation)) +
  geom_bar(elev_Yammnds, aes(elevation)) # fix this second line

plot(Yam)
plot(mounds$geometry, col = mounds$prom1000mbuff, add = TRUE)

# Sample prominence at mound locations
# https://geocompr.robinlovelace.net/spatial-operations.html#spatial-raster-subsetting
# https://mgimond.github.io/megug2017/
