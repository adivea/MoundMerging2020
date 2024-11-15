## Merging Mound Monitoring Data from Yambol: 2009-2022 Streamlined

This project aims to build a master dataset of verified burial mounds with coordinates, TRAP and TopoID, dimensions, landuse and conservation attributes. We have five datasets from the following campaigns of fieldwalking:

- 2009 (20 ATTRIBUTES) field survey and remote sensing verification, initial season, data model not complete hence some missing attributes, 
- 2010 (58 ATTRIBUTES)legacy data verification on the basis of historical topographic maps, data model also not fully sorted,plus robbery of office leads to the loss of image data for one team's week of work, land use data not transcribed, many categories missing, additional discrepancy arises from asynchronous fixing by two different teams. Requires weeks of streamlining in OR, GoogleEarthPro, ArcGIS, and old PDfs of field records, images and spreadsheets to triangulate closer to the past reality.
- 2017 (46 ATTRIBUTES)legacy data verification with a mature data model, digital FAIMS output, 
- 2018 (58 ATTRIBUTES) repeat of 2017 in a different region (Bolyarovo) with minor tweaks to data model, but very active body of participants who added annotations everywhere.
- 2022 (58 ATTRIBUTES) repeat of data collection following the 2017 conceptual model from the FAIMS module in the municipality of Elhovo and partially Straldzha with the same data model.

Difference in attribute numbers in post-2017 modules stems from notes attached to individual fields in later seasons. 

## Streamlining

As in any archaeological fieldwork, the data realities and accompanying data models are emergent, and as such they evolve through time. Inconsistencies appear across the datasets because the initial datasets were recorded on paper and suffer from ommissions and errors while the latter ones recorded via digital workflow with stricter controls and validation implemented via in the field are more complete. 

- 2009 survey dataset had undergone cleaning for the initial TRAP publication and my own dissertation and only required a couple hours to split up LU into \_Around and \_Top and verify dimensions and spotcheck factual correctness to be ready for a merge-in
- 2009 remotely sensed dataset required the same edits as 2009 survey
- 2010 was severely impaired by missing and divergent data (2016 Adela version differed from 2018 Bara version, but had fuller attributes and GIS information). In order to verify and fill in information, I had to refine each version, reconcile discrepancies and duplicates and fill in land use and dimensions on the basis of Google Earth Pro before I could merge these two versions. I used RS_Temporal.csc data (completely different source) to verify landuse data, but it was not all that useful in the end. This dataset took in excess of 80 hours to reconcile. Year 2009 and 2010 together took 106 hours to streamline.
- 2017 took 2 hours to clean up because it was produced by a fully digital workflow
- 2018 took 2 hours to clean up 
- 2022 took 8 hours to clean up mostly due to infrequent sanity checks during collection (Bara was not verifying the incoming data daily) and the discovery of attribute issues ('serendipity' being wrongly selected as Source instead of 'survey', etc.) and the need to aggregate all five seasons and deal with attribute and spatial attributes.

It is perhaps useful to categorize the main issues that archaeologists seeking to reuse data encounter. 

### Within dataset issues:
Within each dataset there are quirks such a typographic and factual errors, such as duplicate IDs or erroneous IDs, or dot-separated decimals, misspellings, or multivalued attributes that prevent merging and analysis in R. These I have strived to reconcile in OpenRefine. Missing data were filled in where possible by revisiting field records, field photos, and by using temporal slider in satellite imagery viewer of Google Earth Pro. Furthermore, records were randomly spotchecked against scanned paper data to verify transcription correspondence. To summarize the issues were divided between the technical inconsistencies due to lack of validation (fixable with computer-assistance of OpenRefine) and factual errors which required manual review.
These issues were resolved before merging.

### Between dataset issues:
Once each dataset was reasonably consistent, the merging could commence. Upon merging, I discovered that despite cleaning, vocabularies slightly differed among datasets (spelling, capitalisation, etc.) from one year to another even in established categories such as Landuse, and more under attributes such as CRM/Conservation. Column names also varied slightly. This was tractable with grepl and effort. 
Divergence in the semantic model behind attributes was not tractable computationally but required reinterpretation: e.g. the application of Landuse has also shifted from 2009, when only a single landuse category was used without closer specification , while in 2017 we differentiated between Landuse_Around, Landuse_Top to specify landuse around the mound from that on top of it, as they differed and the difference impacted their preservation.  Having written the guidelines in 2009, I intended landuse around the mound, but diary records showed some teams recorded mound surface landuse.

## Spatial data: 
Manual checks were done on the spatial points of records from 2009-2010 vis-a-vis GPS and legacy data and Google Earth by two separate people. 2017-2022 data was checked against legacy data from topographic maps. Systematic Google Earth check would be helpful for 2017-2022 data, which have only been spotchecked. 
There is a number of spatial duplicates and triplicates (see duplicate_final.txt) for mounds repeatedly visited in different seasons either on assignment to take better photos or by accidental overlap. The duplicates are retained and declared to facilitate their filtering in script `07_Finalize.Rmd`.

Extent: while survey was conducted primarily in the Yambol Province, occasionally a track led outside of its boundaries. Occurrences outside Yambol are useful when conducting analysis susceptible to edge effects, however, features like these are filtered out in `07_Finalize.Rmd`(clipped by regional boundary) for cultural heritage and administrative reporting reasons.

# How to use

0. If you just want to use the data, choose the most suitable dataset for your toolkit (rds is great for R but geojson is easier to work with for Python users, csv should open anywhere) from the output_data/ folder. All attributes are streamlined, duplicates are indicated:

  - Y_features - observations of mounds, moundlike and other phenomena encountered en route to and in locations indicated by Soviet maps clipped to Yambol region
  - Y_mounds - a subset of mounds from the Y_features

  For completeness and to facilitate transition between the scripts, interim outputs are stored in the interim/ folder. Some are products of earlier scripts, where attributes are less streamlined to allow access to raw data. Others, such as the master_sp_enriched are similar to final files in the output_data/ but their spatial extent is greater, as they contain all originally verified features, and not only those inside the Yambol region. 
  - interim/features_dd_early, interim/features_dd_later 
  - interim/master_sp_enriched - spatialized master dataset (product of 05_GetSpatial.R and also 06_Enrich.rmd) but not deduplicated
  
1. If you want to edit the cleaning routine yourself, you can open and start with any of the R or rmd files in the `scripts/` folder, as long as you remember to run all the remaining (=higher number) scripts afterwards. To facilitate decision-making about what you wish to alter, here is a quick summary of each script's purpose:

* `1_LoadData.R` loads each seasons' data from local input_data/ folder  
* `2_2010dataTRAP.R` creates 2010 data by merging and filtering two differently cleaned versions of 2010 data by Adela and Bara. This is an essential step however one can change the prioritization of Bara or Adela's attributes.
* `3_CleanXXXX.R` a series of scripts to streamline each season's dataset. Each season, the teams and conditions differed slightly resulting in slight differences in collected values. 
* `4_MergeToMaster.R` to create a master dataset from the 2009-2022 data above. You can change which attributes are included in the master, and edit some or all of the streamlining steps.

* `05_GetSpatial.R` which merges the cleaned and merged attribute data from several seasons and marries them to point shapefiles by TRAP id. 

 -- Incorrect coordinates are corrected here (only where previously known, 8142 is the prime example) 
 
* `06_Enrich.rmd` takes the spatialized feature data and enriches the records with environmental values extracted from JICA ASTER 30m resolution rasters at points (via `raster::extract` etc.). 

-- If you have a finer resolution dataset, you may want to replace the ASTER here. 
The output dataset are then exported into interim/ folder

* `07_Finalize.rmd`takes enriched features from script 06, strips uncertainty (removing '?' ) from Type and Condition, and writes it to TypeCertainty. AKB numbers and excavation status is added as is SpatialDuplicate status, PairedID, and columns for version filtering. 
Features are clipped to Yambol border and exported in csv, geojson, and rds formats. Features are further filtered for mounds and exported in geojson and rds formats.

-- final attribute streamlining happens here as well as AKB mapping, which connects field observation to cultural defition in excavated mounds

Each of these scripts is fully stand-alone and running `07_Finalize.rmd` will generate the most refined and enriched, but spatially constrained datasets. 

3. The idea behind the multiple scripts is that each script focuses on different aspect of cleaning. Standardisation of the attributes of Type, Condition, LandUse (LU) serves most common analyses of type and landuse classification, vulnerability assessment and similar.  Additional variation, uncertainty and verbose annotations are streamlined and moved either to AllNotes or fields such as TypeCertainty in 05_GetSpatial and 07_Finalize rmd scripts. They can be accessed in the interim/ products.

# Acknowledgments
Collecting a landscape-scale dataset would not be possible without the dedicated help of local and international colleagues. We hereby give massive thanks to Barbora Weissova her assistance with mound monitoring and spatial data streamlining. We also thank Petra Heřmánková and Věra Doležálková for leading field teams and managing data collection. Last but not least, the data would not exist were it not for the students, colleagues, and volunteers from the Yambol History Museum, UNSW Australia, Macquarie University, New Bulgarian University, Charles University, Aarhus University and many other institutions. In rough chronological order of appearance these include Iliya Iliev, Georgi Iliev, Yavor Rusev, Stefan Bakardzhiev, Simon Connor, Shawn Ross, Petra Tušlová, Tereza Dobrovodská, Sona Holičková, Scott Jackson, Stanislav Marchovski, Jana Ryšavková, Radko Sedláček, Jarmila Švédová, Dragomir Garbov,  Emma Jacobson, Royce Lawrence, Briana Barton, Stephanie Black, Lachlan Hanley, Samuel Riley, Isaac Roberts, Tiana Anderson, Amy Tanswell, Mikaila Walker, Bronwyn Schlamowitz, Elissa Sinclair, Angel Bogdanov Grigorov, Matilde Jensen, Sara Vejrup, Dorthe Pedersen, Julie Lund, Joel Sercombe, Mathias Kaas, and Mathias Johansen.

# Funding Information
This work was supported by the Australian Research Council Linkage Projects Funding scheme LP0989901, University of Michigan International Grant, America for Bulgaria Foundation, Endeavour Short-Term Mobility Programme from the Australian Department of Education, grant 19686; National eResearch Collaboration Tools and Resources (NeCTAR) under eResearch Tools grant RT043; the Australian Research Council under Linkage, Infrastructure, Equipment and Facilities (LIEF) grant LE140100151; Macquarie University and UNSW Australia under internal infrastructure grant schemes; and Aarhus University Forskningsfond Starting grant no. AUFF-2018-7-22 awarded to the ‘Social Complexity in the Ancient Mediterranean’ (SDAM) project.


# License
Attribution-NonCommercial-ShareAlike 4.0 International
* You are free to:
-- Share — copy and redistribute the material in any medium or format
-- Adapt — remix, transform, and build upon the material

The licensor cannot revoke these freedoms as long as you follow the license terms.

* Under the following terms:
-- Attribution — You must give appropriate credit , provide a link to the license, and indicate if changes were made . You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
-- NonCommercial — You may not use the material for commercial purposes .
-- ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
-- No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


# How to cite
Adela Sobotkova. (2024). Verified Burial Mounds in Yambol Province, SE Bulgaria (v1.1) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.13342120

References:
JICA. n.d. “ASTER Global Digital Elevation Model.” ASTER GDEM. Accessed June 25, 2024. https://gdemdl.aster.jspacesystems.or.jp/index_en.html.
Appelhans T, Detsch F, Reudenbach C, Woellauer S (2023). mapview: Interactive Viewing of Spatial Data in R_. R  package version 2.11.2, <https://CRAN.R-project.org/package=mapview>.
Ogle, Derek H., Jason C. Doll, A. Powell Wheeler, and Alexis Dinno. 2023. “FSA: Simple Fisheries Stock Assessment Methods.” https://CRAN.R-project.org/package=FSA.
Pebesma, E., & Bivand, R. (2023). Spatial Data Science:  With Applications in R. Chapman and Hall/CRC.  https://doi.org/10.1201/9780429459016
Pebesma, E., 2018. Simple Features for R: Standardized  Support for Spatial Vector Data. The R Journal 10 (1),  439-446, https://doi.org/10.32614/RJ-2018-009
Wickham, Hadley, Mara Averick, Jennifer Bryan, Winston Chang, Lucy D’agostino McGowan, Romain François, Garrett Grolemund, et al. 2019. “Welcome to the Tidyverse.” Journal of Open Source Software. https://doi.org/10.21105/joss.01686.

