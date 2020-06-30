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

# only dropping needed, there are hardly any redundant columns

mnd2009 <- mnd2009[,-c(6, 8:12)] # removing "LUCheckedinGE","Year", "Mo", "Day" columns as the data is managerial only, "Lat and Long" because they are empty

dmy(mnd2009$Date)  # checking that date parses (it does if you attach the lubridate library)
tail(mnd2009)

mnd2009 %>% 
  rename(DiameterMax = Length, PrincipalSourceOfImpact=PrincipalFactor, DataProvenance= Provenance)


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

# 2018 DATASET 
names(mnd2018)
mnd2018 <- mnd2018 %>% 
  select(-one_of("File","uuid", "HandheldGPSPoint", "Elevation", "Photo", "modifiedBy", "modifiedAtGMT", "BurialMoundAuthor")) %>% 
  rename(TRAP=identifier, Timestamp=createdAtGMT, Type=Type_Adela, LU_Around = LanduseAroundMound, LU_Top=LanduseOnTopOfMound)# Uuid is corrupted by excel, and other fields are managerial mostly (refer to sqlite)

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



# 2010 Datasets CONTINUE HERE!

# Drop undesired columns. If you are running this the first time, uncomment.
#abmounds <- abmounds[,-c(40:44,46)]  # dropping extra info from digitisation
#abmounds<- abmounds[,-c(46, 48,50:52)] # dropping additional coordinates
abmounds <- abmounds[,-47]
abmounds[3,40:47]
# abmounds %>% 
#   select(-one_of("Excav", "Necropolis","ElevationTopo", "Certainty", "GC", )


# CONTINUE HERE!
abmounds <- abmounds %>% 
  rename(TopoMapHeight=Note_1) %>% 
  rename(RSNotes=X18, TypeBara=Type, LU_AroundRS = Landuse_AroundRS, LU_TopRS=Landuse_TopRS, DiameterMax = Length, 
         Diameter_Bara= `Length (max, m)`, PrincipalSourceOfImpact = Principal, 
         ArchaeologicalPotential=ArcheoPotential, MostRecentDamageWithin=When) %>% 
  unite(RTDescription, c("RTNumber", "RTPosition", "RTDescription"), sep = ";", remove = TRUE, na.rm = TRUE), 

# Description and Notes need consolidation as well as RS_Notes
# BLG_name and NameTopo need consolidation
# Additional renaming
rename(Source = Source.y, DiameterMax_Bara=Diameter_Bara, DiameterMin_Bara=Width.y,) #source.x refers to map
# Dates 
length(which(is.na(abmounds$Date))) # ok 73 don't have a date

abmounds <- abmounds %>% 
  mutate(Date=paste(abmounds$Date, sep="-","2010")) %>% 
  mutate(Timestamp=dmy(Date)) %>% 
  glimpse()




# additional MOund ID field from spatial join - check if IDs match
all.equal(abmounds$TRAP, abmounds$Mound_ID)
abmounds %>% 
  select(TRAP, Mound_ID) # they match exept for 45 entities missing TRAP in bara

