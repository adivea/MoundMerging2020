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
There is a number of spatial duplicates and triplicates (see duplicate_final.txt) for mounds repeatedly visited in different seasons either on assignment to take better photos or by accidental overlap. The duplication is treated in script 06_Enrich.Rmd.

Extent: while survey was conducted primarily in the Yambol Province, occasionally a track led outside of its boundaries. Occurrences outside Yambol are useful when conducting analysis susceptible to edge effects, however, features like these are filtered out in 07_Finalize.Rmd(clipped by regional boundary) for cultural heritage and administrative reporting reasons.

# How to use

0. If you just want to use the data, choose the most suitable dataset for your toolkit (rds is great for R but geojson is easier to work with for Python users) from the output_data/ folder. All are streamlined, and sorted by from the most conservative and filtered to the most complete:

  - Y_mounds_dd_early.rds - mounds clipped to Yambol region, deduplicated to early version, enriched (06_Enrich and 07_Finalize)
  - Y_mounds_dd_later.rds - mounds clipped to Yambol region, deduplicated to later version, enriched (06_Enrich and 07_Finalize)
  - Y_features_dd_early.rds - moundlike and other phenomena encountered in maps with 2010 variant of duplicates
  - Y_features_dd_later.rds - moundlike and other phenomena encountered in maps with 2017 variant of duplicates

  For completeness and to facilitate transition between the scripts, interim outputs are stored in the interim/ folder. Some are products of earler scripts, where attributes are less streamlined to allow access to raw records. Others, such as the features_dd are similar to final files in the output_data/ but their spatial extent is greater, as they contain all originally verified features, and not only those inside the Yambol region. 
  - interim/features_dd_early, interim/features_dd_later 
  - interim/master_sp_enriched - spatialized master dataset (product of 05_GetSpatial.R and also 06_Enrich.rmd) but not deduplicated
  
1. If you want to edit the cleaning routine yourself, then start by running the script `source("scripts/04_MergeToMaster.R")` to create a master dataset from the 2009-2022 data above. You can then edit some or all of the streamlining steps.

2. Afterwards, depending on your needs, either make the data spatial using

* `05_GetSpatial.R` which loads the point shapefiles for the mounds and merges the previously cleaned attribute data to them. 

 -- Incorrect coordinates are corrected here (only where previously known, 8142 is the prime example) 
 
* `06_Enrich.rmd` takes spatialized feature data and enriches it with admin and environmental data extracted from JICA ASTER 30m resolution rasters at points (via `raster::extract` etc.). 

-- Spatial duplicates are streamlined here. the dataset is divided into two: early and later versions with duplicates initially visited in 2010 and revisited in 2017
The datasets are then exported into interim/ folder

* `07_Finalize.rmd` takes deduplicated features from previous scripts, strips uncertainty (removing '?' ) from Type and Condition, and writes it to TypeCertainty according to feedback from BG colleagues. AKB numbers and excavation status is added. 
Features are clipped to Yambol border and exported in two spatially-deduplicated versions in geojson and rds formats. Features are further filtered for mounds and exported in geojson and rds formats.

-- final attribute streamlining happens here as well as AKB mapping, which connects field observation to cultural defition in excavated mounds

Each of these scripts is fully stand-alone and running `07_Finalize.rmd` will generate the most refined and enriched, but spatially constrained datasets. 

3. The idea behind the multiple scripts and data versions is that each script focuses on different aspect of cleaning. The streamlining needs follow a certain logic of ease, e.g. spatial deduplication (==splitting) makes sense after most streamlining and enrichment is done to avoid repetition on the subsets. Spatialisation focuses on geometries, while merging works mostly with identifiers and attributes.  Standardisation of the attributes of Type, Condition, LandUse (LU) serves most common analyses of type and landuse classification, vulnerability assessment and similar.  Additional variation, uncertainty and verbose annotations are streamlined and moved either to AllNotes or fields such as TypeCertainty in 05_GetSpatial and 07_Finalize rmd scripts. They can be accessed in the interim/ products.

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
