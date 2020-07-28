##### CREATING MASTER DATASET

# Goal
# Create a master dataset of all visited features in Yambol and surroundings from 2009-2018, which can be used to generate derivates, 
# such as all visited features in Yambol, all potential mounds in Yambol and surroundings, and all potential and all confirmed mounds in Yambol

 
# Requires couple prerequisites, such as 
# 1) dropping and renaming columns to achieve consistency between datasets
# 2) aggregating notes into a single column_to_rownames
# 3) eliminating columns irrelevant at present (e.g. spatial join results that are not shared among datasets) 
# 4) merging and cleaning up


## Inputs - check what they look like at this point
colnames(mnd2009)  # 2009 dateset cleaned in GoogleDocs
colnames(abmounds) # 2010 only mounds (n=406) based on TRAP number and left join to adela:  conservative dataset
colnames(ableftj)   # 2010 collection (493) of mounds (406) and other features(87) - potentially extinct mounds
colnames(mnd2017)  # 2017 mounds (413)
colnames(mnd2018)  # 2018 mounds (282)


# Library
library(tidyverse)
library(lubridate)




#### 2009 DATASET

# only dropping a few needless columns.

mnd2009 <- mnd2009 %>% 
  select(-one_of("LUCheckedinGE", "Year", "Mo", "Day", "Lat", "Long")) %>% 
  filter(!grepl("*GE*", Type))
# got 15 columns, 80 observations now

# rename columns to standard 
mnd2009 <- mnd2009 %>% 
  rename(TRAP=TRAPCode, DiameterMax = Length, DiameterMin = Width, PrincipalSourceOfImpact=PrincipalFactor, 
         DataProvenance = Provenance, HeightMax = HeightGC) 

# 2009 mounds are good to go: Source "Survey" is guaranteed mounds, source "RS" or "LGV"not always. 
# 2009 contain 80 potential mounds, 77 are certain, 3 c(8051, 8054, 8055) are uncertain.
# (missing dates signal inaccessible locations or problematic ones)



#### 2017 DATASET 


mnd2017 <- mnd2017 %>% 
  select(-one_of("uuid","HandheldGPSPoint", "Elevation", "Photo")) %>%  # Uuid is corrupted by excel, and other fields are managerial mostly (refer to sqlite)
  rename(TRAP=identifier, LU_Around = LanduseAroundMound, LU_Top=LanduseOnTopOfMound)   


# Aggregate notes to two columns using, https://stackoverflow.com/questions/50845474/concatenating-two-text-columns-in-dplyr
# Look where notes are distributed >> 7 columns
mnd2017 %>% 
  select(grep(" 2",names(mnd2017)), grep("[Nn]ote",names(mnd2017)))

# Unite them into two columns with sep = ",", remove = TRUE, na.rm = TRUE
mnd2017 <- mnd2017 %>% 
  unite(AllNotes, c(grep("[Nn]ote",names(mnd2017))), sep = ",", remove = TRUE, na.rm = TRUE) 
mnd2017$AllNotes
mnd2017 <- mnd2017 %>% 
  unite(DamageNotes, c(grep(" 2",names(mnd2017))), sep = ",", remove = TRUE, na.rm = TRUE)  # Damage notes have "2" in column name from OpenRefine
mnd2017$DamageNotes  # we have reduced the initial 46 to 37 variables

# Clean up the Date
dmy(mnd2017$Date) # needs appending 2017 to it else it does not work, continue below
#test the command - does the data look like dates now?
paste(mnd2017$Date, sep="-","2017")
#implementation
mnd2017 <- mnd2017 %>% 
  mutate(Date=paste(mnd2017$Date, sep="-","2017"))

#preview final result
mnd2017 %>% 
  mutate(Date=dmy(Date)) %>% 
  glimpse()

mnd2017 <- mnd2017 %>% 
  mutate(Date=ymd(Date))

# Check Type
levels(as.factor(mnd2017$Type))

# all done with 2017



#### 2018 DATASET 

names(mnd2018)

# Drop and rename columns
mnd2018 <- mnd2018 %>% 
  select(-one_of("File","uuid", "HandheldGPSPoint", "Elevation", "Photo", "modifiedBy", "modifiedAtGMT", "BurialMoundAuthor")) %>% 
  rename(TRAP=identifier, Timestamp=createdAtGMT, Type=Type_Adela, LU_Around = LanduseAroundMound, LU_Top=LanduseOnTopOfMound)# Uuid is corrupted by excel, and other fields are managerial mostly (refer to sqlite)

# Fix date
mnd2018 <- mnd2018 %>% 
  mutate(Date = date(Timestamp)) %>% 
  mutate(Date = ymd(Date))

# Aggregate notes to a single column 
# using, https://stackoverflow.com/questions/50845474/concatenating-two-text-columns-in-dplyr

# Look where notes are distributed > 12 notes columns here
mnd2018 %>% 
  select(grep("[Nn]ote",names(mnd2018)))

# I wish to distinguish betweeen generic notes and damage comments
allnotes <- names(mnd2018[grep("[Nn]ote",names(mnd2018))])[c(1,6,2,3,4,5,7)] # generic notes reordered
damagenotes <- names(mnd2018[grep("[Nn]ote",names(mnd2018))])[8:12] # condition-related notes

# apply these column names vectors to aggregate the notes columns as desired
mnd2018 <- mnd2018 %>% 
  unite(AllNotes, all_of(allnotes), sep = ",", remove = TRUE, na.rm = TRUE) 
mnd2018 <- mnd2018 %>% 
  unite(DamageNotes, all_of(damagenotes), sep = ",", remove = TRUE, na.rm = TRUE)  # Damage notes have "2" in column name from OpenRefine
mnd2018  # we have reduced the initial 58 to 40 variables

# Check Type
levels(as.factor(mnd2018$Type))
# All done with 2018, it still needs some column dropping (e.g. timestamp)


### 2010 Dataset

# Input is abmounds (n = 406), a conservative result of a left join between adela and bara 2010 datasets,
# filtered by type== mound. 
# Another potential input is ableftj (n = 444), which is a more liberal result of left join with 38 features that were mapped as mounds, look like mounds, but are 
# bunkers, waterstations and other features instead. 

# Drop undesired columns. If you are running this the first time, uncomment.

names(abmounds)

# Drop unwanted columns from 58 to 37
ab <- abmounds %>% 
   select(-one_of("Excav", "Necropolis","ElevationTopo", "Certainty", "GC",
         "Leader", "Datum" ,"SurfaceMaterial","SampleCollected","uuid","createdBy",
         "Latitude","Longitude","Northing","Easting","Source_1","GC_1",
         "Mound_ID","DateCompl0","y_proj","x_proj"))


# Consolidation of notes, renaming of columns
names(ab)
ab <- ab %>% 
  rename(TopoMapHeight= Note_1) %>% 
  rename(TypeBara=Type, LU_AroundRS = Landuse_AroundRS, LU_TopRS=Landuse_TopRS, 
         DiameterMax = Length, Diameter_Bara= `Length (max, m)`, 
         PrincipalSourceOfImpact = Principal, 
         ArchaeologicalPotential=ArcheoPotential, 
         MostRecentDamageWithin=When, RSNotes=X18) %>% 
  unite(RTDescription, c("RTNumber", "RTPosition", "RTDescription"), sep = ";", remove = TRUE, na.rm = TRUE) 

# checking which TopoID to retain  - .x is better
problemTopoID <- which(!ab$TopoID.x%in%ab$TopoID.y)  # 35 discrepancies in Topo IDs btw adela and bara
ab$TopoID.y[problemTopoID] # most are zeroes in Bara, only 200244 a problem, which is perhaps a typo?? CHECK IN GE

# Fixing Date column (happenned earlier above - try it if starting from scratch!)
# length(which(is.na(ab$Date))) # ok 73 don't have a date

ab <- ab %>%
  mutate(Date=paste(abmounds$Date, sep="-","2010")) %>%
  mutate(Date=dmy(Date)) %>%
  glimpse()


# Generating finalized 2010 conservative dataset (n =406, 30 columns)
mnd2010 <- ab %>% 
  rename(TypeGE=SomethingPresentOntheGround, LU_Around = LandUseAround, LU_Top=LanduseOn, LU_Source=LandUseSource,
         Width_Bara = Width.y, Height_Bara = Height.y, Condition_Bara = Condition, Condition = CRM, 
         DiameterMin = Width.x, Height_Adela = Height.x, RT_numberGE = RT_number, RT_number = RTDescription, 
         TopoID2017 = `2017identifier`, TopoID = TopoID.x,
         HeightMap = TopoMapHeight, Source = Source.y, 
         DiameterMax_Bara=Diameter_Bara, DiameterMin_Bara=Width.y) %>% 
  unite(Name_BG, c("BLG_Name","NameTopo"), sep = ";", remove = TRUE, na.rm = TRUE) %>% 
  unite(AllNotes, c("Notes", "Description"), sep = "; Bara:", remove = TRUE, na.rm = TRUE) %>% 
  unite(RT_Number, c("RT_number", "RT_numberGE"), sep = "; GE:", remove = TRUE, na.rm = TRUE) %>% 
  select(-one_of("Source.x", "TopoID.y"))   #remove needless
 


# Streamlining of Height is necessary as 12 values do not agree

mnd2010$Height_Adela[!mnd2010$Height_Adela%in%mnd2010$Height_Bara]
heightissue <- !mnd2010$Height_Adela%in%mnd2010$Height_Bara


# Height difference between Bara and Adela measurement exists in 12 cases, 5 due to atlas values in Adela, NAs in Bara
mnd2010 %>% 
  select(TRAP, Height_Adela, Height_Bara) %>% 
  filter(heightissue)

# reviewing the images, Height_Bara corresponds better to photograph in 9038-9057. 
# Exception is 9159,9160, where Adela's estimate is better.  9307 - 9438 are unverifiable due to photo loss
# Where Bara is NA, then Adela should stay NA as well in this subset.

which(mnd2010$TRAP == 9038)

mnd2010$Height_Adela[25] <- "2.0" #overwriting 9038 height with Bara value 
mnd2010$Height_Adela[34] <- "1.5"  #overwriting 9050 height with Baras value
mnd2010$Height_Adela[38] <- "0.5"  #overwriting 9057 height with Baras value
mnd2010$TRAP[38] 
mnd2010[278,]

# Which Height column is better? There are more missing values in Height_Bara
which(is.na(as.numeric(mnd2010$Height_Adela)))  # 6 NAs get introduced by coercion to numeric
which(is.na(as.numeric(mnd2010$Height_Bara)))  # 48 NAs get introduced to Bara

# Height_Adela can be considered Height_Max
mnd2010 <- mnd2010 %>% 
  rename(HeightMax=Height_Adela) 



# Streamline feature Type attribute in 2010?
 
levels(as.factor(mnd2010$TypeGE))
levels(as.factor(mnd2010$TypeBara))
mnd2010 %>% filter(TypeBara == "Surface Scatter")

# Review type in TypeBara as Type is only 'mound'; need to fix 45 NAs if we are to use this column
mnd2010 %>% 
  select(TRAP, TypeGE, TypeBara, HeightMax, Condition) %>% 
  group_by(TypeBara) %>% 
  summarize(Havg = mean(!is.na(HeightMax)), n()) 

# If we exclude Burial Mound types, the NAs don't show
mnd2010 %>% 
  select(TRAP, TypeGE, TypeBara, HeightMax, Condition) %>% 
  filter(TypeBara != "Burial Mound") %>% 
  group_by(TypeBara) %>%
  tally()

# Eliminate NAs: 
# first, createa a temp df that contains all NAs from TypeBara and verify in photos
temp <- mnd2010 %>% 
  select(TRAP, TypeGE, TypeBara, HeightMax, DiameterMax, DiameterMin, Condition, AllNotes) %>% 
  filter(is.na(TypeBara)) # %>% 
# head(25)
#  filter(HeightMax<1.1 | DiameterMax <15 | DiameterMin < 15) # couple Heights are wrong .e.g. 9302 is clearly 1m at least
# , 9107 and 9106 is extinct, 9097 is excavated? 9098 is not a mound?, 9089 is a mound

# photo results classified:  
mounds <- c(9089, 9090, 9091, 9092, 9093, 9094, 9095, 9096, 9099:9105, 9108, 9109, 9305:9312)  
ext <- c(9097, 9106,9107,9214, 9303, 9304, 9301, 9313, 9435, 9438)  
unc <-  c(9077, 9098)
remnants <-  temp$TRAP[temp$TRAP%nin%c(mounds,ext,unc)] 

# replace NA values
`%nin%` = Negate(`%in%`)

mnd2010 <- mnd2010 %>% 
  #select(TRAP, TypeBara) %>% 
  #filter(is.na(TypeBara)) %>% 
  mutate(TypeBara = case_when(TRAP%in%mounds ~  "Burial Mound", 
                              TRAP%in%ext ~ "Extinct Burial Mound",
                              TRAP%in%unc ~ "Burial Mound?", 
                              TRAP%in%remnants ~ "Burial Mound",
                              TRAP%nin%c(mounds,ext,unc)~ TypeBara)) %>% 
  rename(Type = TypeBara)


levels(as.factor(mnd2010$Type))

mnd2010 %>% 
  group_by(Type) %>% 
  tally()

mnd2010 %>% 
  select(TRAP, TypeGE, Type, HeightMax, Condition) %>% 
  group_by(Type) %>% 
  summarize(Havg = mean(!is.na(HeightMax)), n()) 

# Further classification vs dimension checks
# mndXXXX %>% 
#   select(TRAP, Source, DiameterMax, DiameterMin, HeightMax, Condition, Notes, Type) %>% 
#   filter(HeightMax<0.6 | DiameterMax <15 | DiameterMin < 15) %>% 
#   tail(13)
# mutate(Type = "Extinct Burial Mound") %>% 
#   filter(HeightMax == 0) %>% 
#   mutate(Type = "Uncertain Mound")
# 
# levels(as.factor(mnd2017$Type))



#########################################################################################mnd2009
 
# There are 12 shared columns between 2010 and 2009 
dim(mnd2010) # 31 columns in 2010 dataset
names(mnd2009)[which(names(mnd2009)%in%names(mnd2010))] # TopoID is extra in 2010

# There are 11 shared columns between 2018 and 2009 
dim(mnd2018) # 40 columns in 2018 dataset
names(mnd2009)[which(names(mnd2009)%in%names(mnd2018))]

# There are 11 shared columns between 2017 and 2009 
dim(mnd2017) # 38 columns

# There are 36 shared columns between 2018 and 2017 
dim(mnd2018) # 40 columns in 2018 dataset
dim(mnd2017) # 38 columns in 2017 dataset
names(mnd2018)[which(names(mnd2018)%in%names(mnd2017))]

names_all <- names(mnd2009)[which(names(mnd2009)%in%names(mnd2017))]  # 11 shared columns (essential ones in there)
names_manual <- names(mnd2009)[which(names(mnd2009)%in%names(mnd2010))] # 12 shared in 2009-2010, (TopoID being extra)
names_faims <- names(mnd2018)[which(names(mnd2018)%in%names(mnd2017))] # 36 shared columns in 2017-2018 (richer data)

mnd2018[, names_all]

################################################################################

# MASTER DATASET - conservative 2009-2010, liberal 2017-2018

master = NULL
master <- rbind(mnd2009[, names_all], mnd2010[, names_all], mnd2017[, names_all], mnd2018[, names_all])
dim(master)



# 1181 records in the master dataset with 11 variables

#################################################################################
# FIX UP MASTER CATEGORIES

# Fix Type
levels(as.factor(master$Type))
master$Type[master$Type=="Burial Mound?"] <- "Uncertain Mound"

# Streamline LU spelling
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


# Fix missing Landuse - substituting with Adela's RS values where missing in Bara's
# 45 mounds lack LU values
master %>% 
  group_by(LU_Around) %>% 
  tally()

master %>% 
  group_by(LU_Top) %>% 
  tally()

# lets see which ones
LUmissing <- master %>% 
  filter(is.na(LU_Around)) %>% 
  select(TRAP)

LUTmissing <- master %>% 
  filter(is.na(LU_Top)) %>% 
  select(TRAP)

LUmissing$TRAP%in%LUTmissing$TRAP

LUmiss_subs <- mnd2010 %>% 
  filter(TRAP %in% LUmissing$TRAP) %>% 
  select(TRAP, LU_AroundRS, LU_TopRS) %>% 
  rename(LU_Around =LU_AroundRS,LU_Top=LU_TopRS)
 
# Apply rows_patch(x,y) to update/change NA values in LU_Around and LU_Top in master dataset
?rows_update

# select the rows from master dataset
names(master[which(is.na(master$LU_Around)),c(1,4,5)])
master[which(master$TRAP%in%LUTmissing$TRAP),c(4)]
# confirm the column names in both datasets are identical
names(LUmiss_subs)%in%names(master[which(is.na(master$LU_Around)),c(1,4,5)])

# rows_patch() is not working
# master %>% 
#   rows_patch(tibble(
#     a = master[which(is.na(master$LU_Around)),c(1,4,5)],  
#     b = LUmiss_subs), )
#     #by = c("TRAP","TRAP")) # R complains so I hid the by =
#                     # R complains that columns in y are not contained in x (they are)


# different approach of updating specific values one by one with case_when, 
# adding also "Nodata" trap ids to these

abmounds %>% 
  filter(LandUseAround == "Nodata") %>% 
  select(TRAP, LU_AroundRS, LU_TopRS)
  
  


LUmiss_subs$LU_Around
scrub <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Around == "Scrub")], 9411,9412)
annual <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Around == "Annual agriculture")],9419,9423)
pasture <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Around == "Pasture")],9420)

levels(as.factor(LUmiss_subs$LU_Top))
Scrub <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Top == "Scrub")], 9411,9419)
Annual <- LUmiss_subs$TRAP[which(LUmiss_subs$LU_Top == "Annual agriculture")]
Pasture <- c(LUmiss_subs$TRAP[which(LUmiss_subs$LU_Top == "Pasture")], 9412,9420,9423)

master <- master %>% 
  #filter(is.na(master$LU_Around)|is.na(master$LU_Top)) %>% 
  mutate(LU_Around = case_when(TRAP%in%scrub ~  "Scrub", 
                              TRAP%in%pasture ~ "Pasture",
                              TRAP%in%annual ~ "Annual agriculture", 
                              TRAP%nin%c(scrub,pasture,annual)~ LU_Around),
         LU_Top = case_when(TRAP%in%Scrub ~  "Scrub", 
                             TRAP%in%Pasture ~ "Pasture",
                             TRAP%in%Annual ~ "Annual agriculture",
                             TRAP%nin%c(Scrub,Pasture,Annual)~ LU_Top))

## FINAL LANDUSE: there should be no "Nodata" or NA's as it was replaced with RS data, where it exists. 
master %>% 
  group_by(LU_Top) %>% 
  tally()
master %>% 
  group_by(LU_Around) %>% 
  tally() %>% 
  mutate(perc = n/sum(n)*100)

#################################################################################

# NEXT STEPS: MERGE WITH SPATIAL DATA > NEW SCRIPT 06
# NEXT STEPS: CONTINUE THINKING: WHAT OTHER COLUMNS DO I NEED? OR WHAT CHECKS ARE NEEDED?

# - check for duplicates: 
# - geospatial can be extracted from GIS
# - TopoID can be extracted from GIS (but exists in 2009-2010)
# - Type is not super consistent
# BEWARE: 9313 geospatial info in mnd2010 may be wrong as is inconsistent with image (road on image, none in GE)


# Duplicates (revisited mounds)
master %>% 
  group_by(TRAP) %>% 
  filter(n()>1) %>% 
  arrange(TRAP)

dupl_ids <- master$TRAP[duplicated(master$TRAP)]
# [1] 8051 9338 9071 9400  # need to be dealt with
which(duplicated(master$TRAP))
# [1]  80 778 779 839


# Further dimension checks
mndXXXX %>%
  select(TRAP, Source, DiameterMax, DiameterMin, HeightMax, Condition, Notes, Type) %>%
  filter(HeightMax<0.6 | DiameterMax <15 | DiameterMin < 15) %>%
  tail(13)
mutate(Type = "Extinct Burial Mound") %>%
  filter(HeightMax == 0) %>%
  mutate(Type = "Uncertain Mound")

levels(as.factor(master$Type))
