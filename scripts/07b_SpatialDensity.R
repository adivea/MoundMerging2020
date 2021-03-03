
# Libraries
library(tidyverse)
library(sf)

# Load Map Digitisation results
mnd_digit <- read_csv("F:/Elenovo2017/TRAPshare/20170929/Project Records/CSVfromFAIMS/MapDig_ALLfixedNE.csv")

which(is.na(mnd_digit$Northing))
mnd_digit <- st_as_sf(mnd_digit[-c(2025,4969),], coords = c("Easting", "Northing"), crs = 32635)

plot(mnd_digit$geometry)


# Intersect

