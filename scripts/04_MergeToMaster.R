############################################################################################################
#                                Creating MASTER verified feature dataset
############################################################################################################

# Goal
# Create a master dataset of all visited features in the Yambol province and surroundings from 2009-2018. 
# Such dataset can be used to generate subset data such as all visited features in Yambol, 
# all potential mounds in Yambol and surroundings, and all potential and all confirmed mounds in Yambol.
# This master dataset can be joined with spatial coordinates from GIS and used for analyses ranging from
# vulnerability assessment to temporal prediction and RS feasibility

# Prerequisites 
# 1) previously cleaned merging-ready datasets from 2009-2022 with shared column names
# 2) spatial data from GIS that contains TRAP IDs for 2009-2010 data
# 3) consistent but not necessarily perfect column content in 1 and 2

# Process 
# 1) load previously cleaned merging-ready datasets from 2009-2022 with shared column names
# 2) merge to create 2009-2022 master dataset with at least 10 essential columns  
# 3) merge to create 2017-2022 FAIMS master dataset with all consistent columns
# 4) do basic streamlining


# Library
library(tidyverse)
library(lubridate)
library(here)
library(googlesheets4)
gs4_deauth()
#gs4_auth(email = adela@faims.edu.au) # select Google account with which you are downloading data or use gs4_deauth()

################################## LOAD DATA ######################################################

# Load the inputs

df_name <- c("m2009","m2010","m2017","m2018", "m2022")
script <- c("03_Clean2009.R","03_Clean2010.R","03_Clean2017.R","03_Clean2018.R","03_Clean2022.R")
for (i in df_name){
   if (exists(i)){
    is.data.frame(get(i))
  }  else {
    source(paste0("scripts/",(script[contains(gsub("m","", i), vars = script)])))
  }
}

## Inputs - check what they look like at this point
colnames(m2009)  # 2009 dataset cleaned in GoogleDocs
colnames(m2010) # 2010 only mounds (n=406) based on TRAP number and left join to adela:  conservative dataset
colnames(m2017)  # 2017 FAIMS-collected features (413)
colnames(m2018)  # 2018 mounds (282)
colnames(m2022)  # 2022 FAIMS-collected features (310), 47 columns

#################################  REVIEW DATA AND GET SHARED COLUMNS ########################################################m2009
 
# There are 12 shared columns between 2010 and 2009 
dim(m2010) # 30 columns in 2010 dataset
names(m2009)[which(names(m2009)%nin%names(m2010))] # which are not shared?
m2009$TopoID 

# There are 11 shared columns between 2018 and 2009 
dim(m2018) # 40 columns in 2018 dataset
names(m2009)[which(names(m2009)%nin%names(m2018))]  # which are not shared?

# There are 11 shared columns between 2017 and 2009 
dim(m2017) # 37 columns

# There are 36 shared columns between 2018 and 2017 
dim(m2018) # 40 columns in 2018 dataset
dim(m2017) # 37 columns in 2017 dataset
names(m2018)[which(names(m2018)%nin%names(m2017))]

names_all <- names(m2009)[which(names(m2009)%in%names(m2017))]  # 11 shared columns (essential ones in there)
names_manual <- names(m2009)[which(names(m2009)%in%names(m2010))] # 12 shared in 2009-2010, (TopoID being extra)
names_faims <- names(m2018)[which(names(m2018)%in%names(m2017))] # 36 shared columns in 2017-2018 (richer data)

m2017[, names_faims]

####################################  MASTER M DATASET FOR ALL SEASONS ############################################

## MASTER DATASET - conservative selection of mostly mounds in 2009-2010, liberal features in 2017-2018

m = NULL
m <- rbind(m2022[, names_all], m2010[, names_all], m2017[, names_all], m2018[, names_all],m2009[, names_all])
dim(m) # 1491 12 in 2023

glimpse(m)
glimpse(m2009) # Check:  existence of AllNotes
glimpse(m2010) # Check: valid 2010 date
glimpse(m2010[, names_all])
glimpse(m2017[, names_all])
glimpse(m2018[, names_all])
glimpse(m2022[, names_all])
write_csv(m, "output_data/interim/merged2023.csv") # through 2022; previous merged.csv was for 2009-18

# Check rectitude of date (there should not be any 2020-... date)
m %>% 
  filter(grepl("2020-",Date))


m %>% 
  mutate(year = year(Date),
         DayMonth = format(as.Date(Date), "%d-%m")) %>% 
  ggplot()+
  geom_histogram(aes(DayMonth),stat="count")+
  facet_grid(~year) +
  theme_minimal()+
  labs(title = "Mounds documentation timeframe",
       x = "Day and Month",
       y = "Number of registered features")


# 1181 records in the 2009-2018 master dataset with 11 variables
# 1491 records in the 2009-2022 master dataset
####################################  MASTER M_FAIMS DATASET FOR FAIMS SEASONS 2017 - 2018 #####################################

# MASTER DATASET FOR FAIMS YEARS
# 1005 records and 36 cols in 2022
m_Faims <- NULL
m_Faims <- rbind(m2017[, names_faims], m2018[, names_faims],m2022[, names_faims])

# Check date, check spatial data, check datatype everywhere
glimpse(m_Faims)

# Verify timeframe
m_Faims %>% 
  mutate(year = year(Date),
         DayMonth = format(as.Date(Date), "%d-%m")) %>% 
  ggplot()+
  geom_histogram(aes(DayMonth),stat="count")+
  facet_grid(~year) +
  theme_minimal()+
  labs(title = "Mounds documentation timeframe",
       x = "Day and Month",
       y = "Number of registered features")+
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1,size = 7))

# Convert 'list' datatype if it occurs
# m_Faims$DiameterMin <- as.numeric(unlist(m_Faims$DiameterMin))
# unique(unlist(m_Faims$HeightMin)) 
# m_Faims$HeightMin <- as.numeric(unlist(m_Faims$HeightMin))
# m_Faims$DescriptionOfMoundOrLocale # skip for now and fix when needed

dim(m_Faims)  
glimpse(m_Faims)
write_csv(m_Faims, "output_data/interim/faimsmaster.csv") 

####################################  STREAMLINE M INTO MASTER FOR ALL SEASONS ##################################################

####  We will need fields such as Type, Height, Landuse and others streamlined before analysis

## Create a new object called master so as to differentiate streamlined data from the product of merger
master <- m

## Streamline Type
levels(as.factor(master$Type))
master$Type[master$Type=="Uncertain Mound"] <- "Burial Mound?"

## Streamline Landuse 
master %>% 
  group_by(LU_Around) %>% 
  tally()

master %>% 
  group_by(LU_Top) %>% 
  tally()

master$LU_Around[master$LU_Around =="Fallow"] <- "Annual agriculture"
master$LU_Around[master$LU_Around =="Annual"] <- "Annual agriculture"
master$LU_Around[master$LU_Around =="Pasture/Scrub"] <- "Scrub"

master$LU_Top[master$LU_Top =="Fallow"] <- "Annual agriculture"
master$LU_Top[master$LU_Top =="Annual"] <- "Annual agriculture"
master$LU_Top[master$LU_Top =="Annual/Pasture"] <- "Annual agriculture"
master$LU_Top[master$LU_Top =="Pasture/Scrub"] <- "Scrub"


# Fill in missing Landuse - substituting with Adela's RS values where missing in Bara's
# 45 mounds lack LU values
master %>% 
  group_by(LU_Around) %>% 
  tally()

master %>% 
  group_by(LU_Top) %>% 
  tally()

# lets see where LU is missing
LUmissing <- master %>% 
  filter(is.na(LU_Around)) %>% 
  dplyr::select(TRAP)

LUTmissing <- master %>% 
  filter(is.na(LU_Top)) %>% 
  dplyr::select(TRAP)

LUmissing$TRAP%in%LUTmissing$TRAP

LUmiss_subs <- m2010 %>% 
  filter(TRAP %in% LUmissing$TRAP) %>% 
  dplyr::select(TRAP, LU_AroundRS, LU_TopRS) %>% 
  rename(LU_Around =LU_AroundRS,LU_Top=LU_TopRS) %>% 
  print(n=45)
 
# add also "Nodata" TRAPids to the LUmiss_subs vector with NA TRAP ids
ableftj %>% 
  filter(LandUseAround == "Nodata") %>% 
  dplyr::select(TRAP, LandUseAround,Landuse_AroundRS, Landuse_TopRS)
ableftj %>% 
  filter(TRAP == 9484) %>% 
  dplyr::select(20:30)


# in LU Around  
LUmiss_subs$LU_Around
scrub <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Around == "Scrub")], 9411,9412)
annual <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Around == "Annual agriculture")],9419,9423)
pasture <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Around == "Pasture")],9420)

# in LU Top
levels(as.factor(LUmiss_subs$LU_Top))
Scrub <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Top == "Scrub")], 9411,9419)
Annual <- LUmiss_subs$TRAP[which(LUmiss_subs$LU_Top == "Annual agriculture")]
Pasture <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Top == "Pasture")], 9412,9420,9423)

master <- master %>% 
  #filter(is.na(master$LU_Around)|is.na(master$LU_Top)) %>% 
  mutate(LU_Around = case_when(TRAP%in%scrub ~  "Scrub", 
                              TRAP%in%pasture ~ "Pasture",
                              TRAP%in%annual ~ "Annual agriculture", 
                              TRAP%nin%c(scrub,pasture,annual)~ LU_Around), # LU_Around streamlined
         LU_Top = case_when(TRAP%in%Scrub ~  "Scrub", 
                             TRAP%in%Pasture ~ "Pasture",
                             TRAP%in%Annual ~ "Annual agriculture",
                             TRAP%nin%c(Scrub,Pasture,Annual)~ LU_Top)) # LU_Top streamlined


# Review Landuse: there should be no "Nodata" or NA's as it was replaced with RS data, where it exists. 
# NAs remain in 9098 and 9484 from 2010 (check RS data)
master %>% 
  filter(is.na(LU_Top))

master %>% 
  group_by(Source) %>% tally()
master %>% 
  filter(is.na(Source)) %>% glimpse()
master %>% 
  group_by(LU_Top) %>% 
  tally()
master %>% 
  group_by(LU_Around) %>% 
  tally() %>% 
  mutate(perc = round(n/sum(n)*100,2)) %>% 
  arrange(perc)

 
###  Eliminate ID duplicates (revisited mounds). For spatial duplicates, see spatial scripts 06

# Find duplicate TRAP ids
master$TRAP[duplicated(master$TRAP)] 
# [1] 8051 9338 9071 9400  # need to be dealt with
master[which(duplicated(master$TRAP)),]
# [1]  80 778 779 839

dupl_rows <- master %>% 
  group_by(TRAP) %>% 
  filter(n()>1) %>% 
  arrange(TRAP) %>% 
  filter(Condition == 5) 

# Delete duplicate rows
dim(master)
master <- master %>% 
  rows_delete(dupl_rows,by = c("TRAP", "Condition")) # as the TRAP ids are duplicated, I specify Condition as the differentiating column
dim(master)

# Delete no-longer needed temps
rm(scrub, Scrub, pasture, Pasture, annual, Annual, 
   LUmiss_subs, LUmissing, LUTmissing, dupl_rows)

####################################### ADDITIONAL EDITS (OPTIONAL)
paste("Starting to streamline condition")

#### STREAMLINE CONDITION
# Condition is expressed on Likert scale 1 - 5 with verbose description 
# of each number, e.g. 1-pristine, 5 - extinct, as a character
unique(master$Condition)

# Clean the Condition to numbers only
master <-  master %>%
   mutate(Condition = str_extract(Condition, "\\d")) #%>% 
#   mutate(nCondition = case_when(Condition == 0 ~ NA,
#                                Condition == 6 ~ "5",
#                                Condition != 0 ~ Condition)) %>% distinct(nCondition) 
#   
# 
# master$Condition <- factor(master$Condition, levels = c("1","2","3","4","5","NA"))
# hist(as.numeric(master$Condition))
# master$Condition[master$Condition=="NA"] <- NA

head(master$Condition)

########################################## SAVE RDS ################

# write_csv(master, "output_data/Master0923.csv") # 1487 rows
# write_csv(master, "output_data/mergedclean2023.csv")
# saveRDS(master, "output_data/mergedcleanfeatures2023.rds")

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