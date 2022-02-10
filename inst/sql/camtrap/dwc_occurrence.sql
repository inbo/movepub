/*
Created by Peter Desmet (INBO)

Based on https://rs.gbif.org/core/dwc_occurrence_2022-02-02.xml
Static Darwin Core values are marked with FIXED VALUE.

CAMTRAP DP DEPLOYMENTS

deploymentID                           Y
locationID                             Y
locationName                           Y
longitude                              Y
latitude                               Y
coordinateUncertainty
start                                  N: observation timestamp is used instead
end                                    N: observation timestamp is used instead
setupBy                                N
cameraID                               N
cameraModel                            N
cameraInterval                         N
cameraHeight                           N
cameraTilt                             N
cameraHeading                          N
timestampIssues                        N
baitUse                                Y
session                                N: sessions events (grouping deployments) are not retained
array                                  N
featureType                            Y
habitat                                ENABLE
tags                                   Y
comments                               Y
_id                                    N

CAMTRAP DP OBSERVATIONS

observationID                          Y
deploymentID                           Y
sequenceID                             N: link is made in dwc_multimedia
mediaID                                N: link is made in dwc_multimedia
timestamp                              Y
observationType                        Y: as filter
cameraSetup                            N
taxonID                                Y
scientificName                         Y
count                                  Y
countNew                               N: difficult to express
lifeStage                              Y
sex                                    Y
behaviour                              Y
individualID                           Y
classificationMethod                   Y
classifiedBy                           Y
classificationTimestamp                Y
classificationConfidence               Y
comments                               Y
_id                                    N

*/

SELECT
-- RECORD-LEVEL
-- type                                 FIXED VALUE
  'Event' AS "type",
-- modified
-- language
-- license                              Only available in dataset metadata
-- rightsHolder                         Only available in dataset metadata
-- accessRights
-- bibliographicCitation
-- references
-- institutionID
-- collectionID
-- datasetID                            Only available in dataset metadata
-- institutionCode
-- collectionCode
-- datasetName                          Only available in dataset metadata
-- ownerInstitutionCode
-- basisOfRecord                        FIXED VALUE
  'MachineObservation' AS "basisOfRecord",
-- informationWithheld
-- dataGeneralizations
-- dynamicProperties

-- OCCURRENCE
-- occurrenceID
  obs."observationID" AS "occurrenceID",
-- catalogNumber
-- recordNumber
-- recordedBy
-- recordedByID
-- individualCount
  obs."count" AS "individualCount",
-- organismQuantity
-- organismQuantityType
-- sex
  obs."sex" AS "sex",
-- lifeStage
  obs."lifeStage" AS "lifeStage",
-- reproductiveCondition
-- behavior
  obs."behaviour" AS "behavior",
-- establishmentMeans
-- degreeOfEstablishment
-- pathway
-- georeferenceVerificationStatus
-- occurrenceStatus                     FIXED VALUE
  'present' AS "occurrenceStatus",
-- preparations
-- disposition
-- associatedMedia
-- associatedOccurrences
-- associatedReferences
-- associatedSequences
-- associatedTaxa
-- otherCatalogNumbers
-- occurrenceRemarks
  obs."comments" AS "occurrenceRemarks",

-- ORGANISM
-- organismID
  obs."individualID" AS "organismID",
-- organismName
-- organismScope
-- associatedOrganisms
-- previousIdentifications
-- organismRemarks

-- MATERIALSAMPLE
-- Not applicable

-- EVENT
-- eventID
  obs."sequenceID" AS "eventID",
-- parentEventID
  obs."deploymentID" AS "parentEventID",
-- fieldNumber
-- eventDate                            ISO-8601 in UTC
  strftime('%Y-%m-%dT%H:%M:%SZ', datetime(obs.timestamp, 'unixepoch')) AS "eventDate",
-- eventTime                            Included in eventDate
-- startDayOfYear
-- endDayOfYear
-- year
-- month
-- day
-- verbatimEventDate
-- habitat
  dep."habitat" AS habitat,
-- samplingProtocol
  'camera trap' ||
  CASE
    WHEN dep."baitUse" IS 'none' THEN ' without bait'
    WHEN dep."baitUse" IS NOT NULL THEN ' with bait'
    ELSE ''
  END AS "samplingProtocol",
-- sampleSizeValue
-- sampleSizeUnit
-- samplingEffort
  strftime('%Y-%m-%dT%H:%M:%SZ', datetime(dep.start, 'unixepoch')) ||
  '/' ||
  strftime('%Y-%m-%dT%H:%M:%SZ', datetime(dep.end, 'unixepoch')) AS "samplingEffort",
-- fieldNotes
-- eventRemarks
  CASE
    WHEN dep."comments" IS NOT NULL THEN 'comments: ' || dep."comments"
  END ||
  CASE
    WHEN dep."comments" IS NOT NULL AND dep."tags" IS NOT NULL THEN ' | '
  END ||
  CASE
    WHEN dep."tags" IS NOT NULL THEN 'tags: ' || dep."tags"
  END AS "eventRemarks",

-- LOCATION
-- locationID
  dep."locationID" AS "locationID",
-- higherGeographyID
-- higherGeography
-- continent
-- waterBody
-- islandGroup
-- island
-- country
-- countryCode                          Not in source data
-- stateProvince
-- county
-- municipality
-- locality
  dep."locationName" AS "locality",
-- verbatimLocality
-- minimumElevationInMeters
-- maximumElevationInMeters
-- verbatimElevation
-- verticalDatum
-- minimumDepthInMeters
-- maximumDepthInMeters
-- verbatimDepth
-- minimumDistanceAboveSurfaceInMeters
-- maximumDistanceAboveSurfaceInMeters
-- locationAccordingTo
-- locationRemarks
  dep."featureType" AS "locationRemarks",
-- decimalLatitude
  dep."latitude" AS "decimalLatitude",
-- decimalLongitude
  dep."longitude" AS "decimalLongitude",
-- geodeticDatum                        FIXED VALUE
  'WGS84' AS "geodeticDatum",
-- coordinateUncertaintyInMeters
  dep."coordinateUncertainty" AS "coordinateUncertaintyInMeters",
-- coordinatePrecision
-- pointRadiusSpatialFit
-- verbatimCoordinates
-- verbatimLatitude
-- verbatimLongitude
-- verbatimCoordinateSystem
-- verbatimSRS
-- footprintWKT
-- footprintSRS
-- footprintSpatialFit
-- georeferencedBy
-- georeferencedDate
-- georeferenceProtocol
-- georeferenceSources
-- georeferenceRemarks

-- GEOLOGICAL CONTEXT
-- Not applicable

-- IDENTIFICATION
-- identificationID
-- verbatimIdentification
-- identificationQualifier
-- typeStatus
-- identifiedBy
  obs."classifiedBy" AS "identifiedBy",
-- identifiedByID
-- dateIdentified                       ISO-8601 in UTC
  strftime('%Y-%m-%dT%H:%M:%SZ', datetime(obs.classificationTimestamp, 'unixepoch')) AS "dateIdentified",
-- identificationReferences
-- identificationVerificationStatus
-- identificationRemarks
  CASE
    WHEN obs."classificationMethod" IS NOT NULL THEN 'classificationMethod: ' || obs."classificationMethod"
  END ||
  CASE
    WHEN obs."classificationMethod" IS NOT NULL AND obs."classificationConfidence" IS NOT NULL THEN ' | '
  END ||
  CASE
    WHEN obs."classificationConfidence" IS NOT NULL THEN 'classificationConfidence: ' || obs."classificationConfidence"
  END AS "identificationRemarks",

-- TAXON
-- taxonID                              The refence for the taxon_ids is only available in dataset metadata
  obs."taxonID" AS "taxonID",
-- scientificNameID
-- acceptedNameUsageID
-- parentNameUsageID
-- originalNameUsageID
-- nameAccordingToID
-- namePublishedInID
-- taxonConceptID
-- scientificName
  obs."scientificName" AS "scientificName",
-- acceptedNameUsage
-- parentNameUsage
-- originalNameUsage
-- nameAccordingTo
-- namePublishedIn
-- namePublishedInYear
-- higherClassification
-- kingdom                              FIXED VALUE: in almost all use cases, it is safe to assume all observations are animals, see https://gitlab.com/oscf/camtrap-dp/-/issues/67
  'Animalia' AS "kingdom"
-- phylum
-- class
-- order
-- family
-- genus
-- genericName
-- subgenus
-- infragenericEpithet
-- specificEpithet
-- infraspecificEpithet
-- cultivarEpithet
-- taxonRank                            Only available in dataset metadata
-- verbatimTaxonRank
-- scientificNameAuthorship
-- vernacularName                       Only available in dataset metadata
-- nomenclaturalCode
-- taxonomicStatus
-- nomenclaturalStatus
-- taxonRemarks

FROM
  observations AS obs

  LEFT JOIN deployments AS dep
    ON obs."deploymentID" = dep."deploymentID"

WHERE
  -- Select biological observations only (excluding observations marked as human, empty, vehicle)
  -- Same filter should be used in dwc_multimedia.sql!
  obs."observationType" = 'animal'

ORDER BY
  obs."observationID"
