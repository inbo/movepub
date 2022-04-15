/*
Created by Peter Desmet (INBO)
*/
SELECT
-- RECORD-LEVEL
  'Event'                               AS type,
  'TODO'                                AS license,
  'TODO'                                AS rightsHolder,
  'TODO'                                AS datasetID,
  'TODO'                                AS institionCode,
  'TODO'                                AS collectionCode,
  'TODO'                                AS datasetName,
  'HumanObservation'                    AS basisOfRecord,
  'TODO'                                AS informationWithheld,

-- OCCURRENCE
  ref."deployment-id"                   AS occurrenceID,
  CASE
    WHEN ref."animal-sex" = 'm' THEN 'male'
    WHEN ref."animal-sex" = 'f' THEN 'female'
    WHEN ref."animal-sex" = 'u' THEN 'undetermined' -- unknown = undetermined for some reason
  END                                   AS sex,
  ref."animal-life-stage"               AS lifeStage,
  'present'                             AS occurrenceStatus,
-- ORGANISM
  ref."animal-id"                       AS organismID,
  ref."animal-nickname"                 AS organismName,
-- EVENT
  ref."tag-id" ||  '-' || ref."animal-id" AS eventID,
  'tag deployment'                      AS samplingProtocol,
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', ref."deploy-on-date") AS eventDate,
  ref."deployment-comments"             AS eventRemarks,
-- LOCATION
  ref."deploy-on-latitude"              AS decimalLatitude,
  ref."deploy-on-longitude"             AS decimalLongitude,
  'WGS84'                               AS geodeticDatum,
  'TODO'                                AS coordinateUncertaintyInMeters,
-- TAXON
  ref."animal-taxon"                    AS scientificName,
  'Animalia'                            AS kingdom

FROM
  reference_data AS ref
