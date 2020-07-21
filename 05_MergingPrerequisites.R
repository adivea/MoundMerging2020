## CREATING MASTER DATASET

# Requires couple prerequisites, such as 
# 1) dropping and renaming columns to achieve consistency between datasets
# 2) aggregating notes into a single column_to_rownames
# 3) eliminating columns irrelevant at present (e.g. spatial join results that are not shared among datasets) 
# 4) merging and cleaning up


## Inputs - check what they look like at this point
colnames(mnd2009)  # 2009 dateset cleaned in GoogleDocs
colnames(abmounds) # 2010 only mounds (n=406) based on TRAP number and left join to adela:  conservative dataset
colnames(ab2010)   # 2010 collection (493) of mounds (406) and other features(87) - potentially extinct mounds
colnames(mnd2017)  # 2017 mounds (413)
colnames(mnd2018)  # 2018 mounds (282)


# Library
library(tidyverse)
library(lubridate)




#### 2009 DATASET

# only dropping a few needless columns.

mnd2009 <- mnd2009[,-c(6, 8:12)] # removing "LUCheckedinGE","Year", "Mo", "Day" columns as the data is managerial only, "Lat and Long" because they are empty

dmy(mnd2009$Date)  # checking that date parses (it does if you attach the lubridate library)
tail(mnd2009)

mnd2009 <- mnd2009 %>% 
  mutate(Date = dmy(Date))

mnd2009 <- mnd2009 %>% 
  rename(DiameterMax = Length, DiameterMin= Width, PrincipalSourceOfImpact=PrincipalFactor, 
         DataProvenance= Provenance, HeightMax = HeightGC) %>% 
  rename(TRAP=TRAPCode)


# 2009 mounds are good to go: Source "Survey" is guaranteed mounds, source "RS" or "LGV"not always. 
# 2009 contain 81 potential mounds, 78 are certain, 3 c(8051, 8054, 8055) are uncertain.
# (missing dates signal inaccessible locations or problematic ones)

# 2017 DATASET 
mnd2017 <- mnd2017 %>% 
  select(-one_of("uuid","HandheldGPSPoint", "Elevation", "Photo")) %>%  # Uuid is corrupted by excel, and other fields are managerial mostly (refer to sqlite)
  rename(TRAP=identifier, LU_Around = LanduseAroundMound, LU_Top=LanduseOnTopOfMound)   


# Aggregate notes to two columns using, https://stackoverflow.com/questions/50845474/concatenating-two-text-columns-in-dplyr
# Look where notes are distributed
mnd2017 %>% 
  select(grep(" 2",names(mnd2017)), grep("[Nn]ote",names(mnd2017)))

# unite them with sep = ",", remove = TRUE, na.rm = TRUE
mnd2017 <- mnd2017 %>% 
  unite(AllNotes, c(grep("[Nn]ote",names(mnd2017))), sep = ",", remove = TRUE, na.rm = TRUE) 
mnd2017$AllNotes
mnd2017 <- mnd2017 %>% 
  unite(DamageNotes, c(grep(" 2",names(mnd2017))), sep = ",", remove = TRUE, na.rm = TRUE)  # Damage notes have "2" in column name from OpenRefine
mnd2017$DamageNotes  # we have reduced the initial 46 to 37 variables

# Clean up the timestamp
dmy(mnd2017$Date) # needs appending 2017 to it _OpenRefine task
#test
paste(mnd2017$Date, sep="-","2017")
#implementation
mnd2017 <- mnd2017 %>% 
  mutate(Date=paste(mnd2017$Date, sep="-","2017"))

#preview final result
mnd2017 %>% 
  mutate(Timestamp=dmy(Date)) %>% 
  glimpse()

mnd2017 <- mnd2017 %>% 
  mutate(Timestamp=dmy(Date))

mnd2017 <- mnd2017 %>% 
  select(-Date) %>% 
  rename(Date = Timestamp)

# all done with 2017



# 2018 DATASET 
names(mnd2018)
mnd2018 <- mnd2018 %>% 
  select(-one_of("File","uuid", "HandheldGPSPoint", "Elevation", "Photo", "modifiedBy", "modifiedAtGMT", "BurialMoundAuthor")) %>% 
  rename(TRAP=identifier, Timestamp=createdAtGMT, Type=Type_Adela, LU_Around = LanduseAroundMound, LU_Top=LanduseOnTopOfMound)# Uuid is corrupted by excel, and other fields are managerial mostly (refer to sqlite)

# Fix date
mnd2018 <- mnd2018 %>% 
  mutate(Date = date(Timestamp))

# Aggregate notes from 2018 -2018 to a single column using, https://stackoverflow.com/questions/50845474/concatenating-two-text-columns-in-dplyr

# Look where notes are distributed
mnd2018 %>% 
  select(grep("[Nn]ote",names(mnd2018)))

# I wish to distinguish betweeen generic notes and damage comments
allnotes <- names(mnd2018[grep("[Nn]ote",names(mnd2018))])[c(1,6,2,3,4,5,7)]
damagenotes <- names(mnd2018[grep("[Nn]ote",names(mnd2018))])[8:12]

# apply these column names vectors to aggregate the notes columns as desired
mnd2018 <- mnd2018 %>% 
  unite(AllNotes, all_of(allnotes), sep = ",", remove = TRUE, na.rm = TRUE) 
mnd2018 <- mnd2018 %>% 
  unite(DamageNotes, all_of(damagenotes), sep = ",", remove = TRUE, na.rm = TRUE)  # Damage notes have "2" in column name from OpenRefine
mnd2018  # we have reduced the initial 58 to 40 variables

# All done with 2018


### 2010 Dataset

# Input is abmounds (n = 406), a conservative result of a left join between adela and bara 2010 datasets, filtered by type== mound. 
# Another potential input is ableftj (n=444), which is a more liberal result of left join with 38 features that were mapped as mounds, look like mounds, but are 
# bunkers, waterstations and other features instead. 

# Drop undesired columns. If you are running this the first time, uncomment.

# abmounds <- abmounds[,-c(40:44,46)]  # dropping extra info from digitisation
# abmounds<- abmounds[,-c(46, 48,50:52)] # dropping additional coordinates
# abmounds <- abmounds[,-47]
# abmounds[3,40:47]
# abmounds %>% 
#   select(-one_of("Excav", "Necropolis","ElevationTopo", "Certainty", "GC", )


# Consolisation of notes, renaming of columns

abmounds <- abmounds %>% 
  rename(TopoMapHeight=Note_1) %>% 
  rename(RSNotes=X18, TypeBara=Type, LU_AroundRS = Landuse_AroundRS, LU_TopRS=Landuse_TopRS, DiameterMax = Length, 
         Diameter_Bara= `Length (max, m)`, PrincipalSourceOfImpact = Principal, 
         ArchaeologicalPotential=ArcheoPotential, MostRecentDamageWithin=When) %>% 
  unite(RTDescription, c("RTNumber", "RTPosition", "RTDescription"), sep = ";", remove = TRUE, na.rm = TRUE) 

# checking which TopoID to retain  - .x is better
problemTopoID <- which(!abmounds$TopoID.x%in%abmounds$TopoID.y)
abmounds$TopoID.y[problemTopoID]

# fixing Date column (happenned earlier above - try it if starting from scratch!)
# length(which(is.na(abmounds$Date))) # ok 73 don't have a date
# 
# abmounds <- abmounds %>% 
#   mutate(Date=paste(abmounds$Date, sep="-","2010")) %>% 
#   mutate(Timestamp=dmy(Date)) %>% 
#   glimpse()


# Generating finalized 2010 conservative dataset (n =406, 32 columns)
mnd2010 <- abmounds %>% 
  rename(Type=SomethingPresentOntheGround, LU_Around = LandUseAround, LU_Top=LanduseOn, LU_Source=LandUseSource,
         Width_Bara = Width.y, Height_Bara = Height.y, Condition_Bara = Condition, Condition = CRM, 
         DiameterMin = Width.x, Height_Adela = Height.x, RT_numberGE = RT_number, RT_number = RTDescription, 
         TopoID2017 = `2017identifier`, TopoID = TopoID.x,
         HeightMap = TopoMapHeight, Source = Source.y, DiameterMax_Bara=Diameter_Bara, DiameterMin_Bara=Width.y) %>% 
  unite(Name_BG, c("BLG_Name","NameTopo"), sep = ";", remove = TRUE, na.rm = TRUE) %>% 
  unite(AllNotes, c("Notes", "Description"), sep = "; Bara:", remove = TRUE, na.rm = TRUE) %>% 
  unite(RT_Number, c("RT_number", "RT_numberGE"), sep = "; GE:", remove = TRUE, na.rm = TRUE) %>% 
  select(-one_of("Source.x", "Excav", "Certainty", "Necropolis", "GC", "TopoID.y", "ElevationTopo")) %>%  #remove needless
  select(-one_of("Latitude", "Longitude", "Northing", "Easting")) #remove sensitive and incomplete

# fixing date

mnd2010 <- mnd2010 %>% 
  mutate(Date = date(Timestamp))

# additional streamlining of Height is necessary as 12 values do not agree

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

which(is.na(as.numeric(mnd2010$Height_Adela)))  # 6 NAs get introduced by coercion to numeric
which(is.na(as.numeric(mnd2010$Height_Bara)))  # 48 NAs get introduced to Bara

# Height_Adela can be considered Height_Max
mnd2010 <- mnd2010 %>% 
  rename(HeightMax=Height_Adela) 


#########################################################################################mnd2009
 
# There are 11 shared columns between 2010 and 2009 
dim(mnd2010) # 31 columns in 2010 dataset
names(mnd2009)[which(names(mnd2009)%in%names(mnd2010))] # TopoID is extra in 2010

# There are 10 shared columns between 2018 and 2009 
dim(mnd2018) # 40 columns in 2018 dataset
names(mnd2009)[which(names(mnd2009)%in%names(mnd2018))]

# There are 10 shared columns between 2017 and 2009 
dim(mnd2017) # 38 columns
columnames <- names(mnd2009)[which(names(mnd2009)%in%names(mnd2017))]

mnd2018[, columnames]

################################################################################

# MASTER DATASET

master <- rbind(mnd2018[, c(columnames, "geospatialcolumn")], mnd2017[, c(columnames, "geospatialcolumn")], 
                mnd2010[, c(columnames, "geospatialcolumn")], mnd2009[, c(columnames, "geospatialcolumn")])
master = NULL
master <- rbind(mnd2009[, columnames], mnd2010[, columnames], mnd2017[, columnames], mnd2018[, columnames])

#################################################################################

# CONTINUE THINKING: WHAT OTHER COLUMNS DO I NEED? TYPE (Burial mound vs other?)

