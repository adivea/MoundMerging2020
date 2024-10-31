############################################################################################################
#             Creating a clean 2009 verified mound dataset
############################################################################################################

# Goal:
# Create an analysis-ready dataset of all features visited in Yambol in 2009.

# Requires couple prerequisites, such as 
# 0) loading the 2009 dataset collating survey and RS mounds
# 1) dropping and renaming columns to achieve consistency between datasets
# 2) aggregating notes into a single column_to_rownames
# 3) eliminating columns irrelevant at present (e.g. spatial join results that are not shared among datasets) 
# 4) merging and cleaning up

# Library
library(tidyverse)
library(lubridate)

# Load the inputs
df_name <- c("mnd2009")
if (exists(df_name)){
  is.data.frame(get(df_name))
}  else source("scripts/01_LoadData.R")

#### 2009 DATASET

colnames(mnd2009)  # 2009 dataset of survey and RS mound features collated in GoogleDocs

# Drop a few needless columns.

m2009 <- mnd2009 %>% 
  dplyr::select(-one_of("LUCheckedinGE", "Year", "Mo", "Day", "Lat", "Long")) %>% 
  filter(!grepl("*GE*", Type))
# got 15 columns, 80 observations now

# Rename columns to standard 
m2009 <- m2009 %>% 
  rename(TRAP=TRAPCode, DiameterMax = Length, DiameterMin = Width, PrincipalSourceOfImpact=PrincipalFactor, 
         DataProvenance = Provenance, HeightMax = HeightGC)
m2009 <- m2009 %>% 
  rename(AllNotes = Notes)

# Check cleaned 2009
head(m2009,2)
# 2009 mounds are good to go: Source "Survey" is guaranteed mounds, source "RS" or "LGV"not always. 
# 2009 contain 80 potential mounds, 77 are certain, 3 c(8051, 8054, 8055) are uncertain.
# (missing dates signal inaccessible locations or problematic ones)

glimpse(m2009)

# Needed fixes : consistent Source value capitalisation
# unique(m2009$Source) #[1] "RS:FNEG"   "RS:SITE" "RS:FNEG - duplicate 9358" "2010LGV" "survey" 
# unique(m2010$Source) #"Legacy verification" "Survey"              NA 

