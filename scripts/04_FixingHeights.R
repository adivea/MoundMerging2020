######################################################## STREAMLINE HEIGHT

# FOR MAXIMUM HEIGHTS (INCL MAP-BASED ONES) SCRIPT NEEDS WORK BUT IS ONLY RELEVANT TO MOUNDS!!!

# This script needs to be implemented mostly in 2010 dataset. In post-2017 the NA Heights mostly 
# refer to surface scatters and non-mound features

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
