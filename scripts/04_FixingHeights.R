######################################################## STREAMLINE HEIGHT

# FOR MAXIMUM HEIGHTS (INCL MAP-BASED ONES) NEEDS WORK!!!

# This script needs to be implemented in 2010 dataset

# Height is mostly numeric, but a few missing values were reconstructed from old atlases,
# and entered as text. e.g.[454] "2 acc to topomap". These four entries can be either made NAs,
# as they are reconstructions, or digits can be extracted with regexes.

# Checking height measures
class(mnd2010$Height.x)

hist(mnd2010$Height.y)
hist(as.numeric(mnd2010$Height.y))
mean(as.numeric(master$HeightMax), na.rm = TRUE)
length(which(is.na(mnd2010$Height.x))) #6
length(which(is.na(mnd2017$HeightMax)))
length(which(is.na(mnd2009$HeightGC))) #3
length(which(is.na(mnd2018$HeightMax))) #17!
length(which(is.na(m2022$HeightMax)))

# Missing Heights in original master dataset
length(which(is.na(master$HeightMax))) # 18 missing heights in 
# [1]  460  964  970 1076 1086 1088 1116 1117 1118 1119 1120 1121 1122 1123 1124
# [16] 1125 1126 1127

# Additional 4 NAs if we force text to number for indeces 130  456  459 461
length(which(is.na(as.numeric(master$HeightMax)))) # 22 missing heights

# 454ff have text with reconstructions from an atlas instead of the numbers, 
# create a version with the numbers reconstructed, or force to NAs
master_reconstr_heights <- master %>%
  mutate(HeightMax = str_extract(HeightMax,"\\d\\.?\\d?"),
         HeightMax = as.numeric(HeightMax))
master <- master %>%
  mutate(HeightMax = as.numeric(HeightMax))

mean(master$HeightMax, na.rm = TRUE)
mean(master_reconstr_heights$HeightMax, na.rm = TRUE)

hist(master$HeightMax)
hist(master_reconstr_heights$HeightMax, col= "pink", add = TRUE, alpha = 0.5)

# Output the cleaned master dataset
write.csv(master, "output_data/mergedclean.csv")
write.csv(master, "../MoundHealth/data/master.csv")
write.csv(master_reconstr_heights, "../MoundHealth/data/master_reconstr_heights.csv")
####################################  NEXT STEPS #############################################

# NEXT STEPS: Streamline m_Faims
# NEXT STEPS: ADD SPATIAL DATA > NEW SCRIPT 06
# NEXT STEPS: CONTINUE THINKING: WHAT OTHER COLUMNS DO I NEED IN MASTER? OR WHAT CHECKS ARE NEEDED?

# - geospatial can be extracted from GIS
# - TopoID can be extracted from GIS (but exists in 2009-2010)
# BEWARE: 9313 geospatial info in m2010 may be wrong as is inconsistent with image (road on image, none in GE)



# REVIEW DIMENSIONS AND TYPE CONCORDANCE
# mXXXX %>%
#   select(TRAP, Source, DiameterMax, DiameterMin, HeightMax, Condition, Notes, Type) %>%
#   filter(HeightMax<0.6 | DiameterMax <15 | DiameterMin < 15) %>%
#   tail(13)
# mutate(Type = "Extinct Burial Mound") %>%
#   filter(HeightMax == 0) %>%
#   mutate(Type = "Uncertain Mound")