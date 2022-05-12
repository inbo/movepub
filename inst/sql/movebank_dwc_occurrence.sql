/*
Created by Peter Desmet (INBO)

Each record is its own event, but GPS records are child events of the
capture/deployment.

occurrenceID     | eventID         | parentEventID | basisOfRecord | eventRemarks
---------------- | --------------- | ------------- | ------------- | ------------------
ani1_tag1_start  | ani1_tag1_start | ani1_tag1     | HumanObs      | deploy-on remarks
occ1             | occ1            | ani1_tag1     | MachineObs    |
occ2             | occ2            | ani1_tag1     | MachineObs    |
ani1_tag1_end    | ani1_tag1_end   | ani1_tag1     | HumanObs      | deploy-off remarks

*/

/* RECORD-LEVEL */

SELECT
  'Event'                               AS type,
  {license_url}                         AS license,
  {rights_holder}                       AS rightsHolder,
  {doi_url}                             AS datasetID,
  'MPIAB'                               AS institutionCode, -- Max Planck Institute of Animal Behavior
  'Movebank'                            AS collectionCode,
  {title}                               AS datasetName,
  *
FROM (

/* DEPLOYMENT START */

SELECT
-- RECORD-LEVEL
  'HumanObservation'                    AS basisOfRecord,
  'see metadata'                        AS informationWithheld,
  NULL                                  AS dataGeneralizations,
-- OCCURRENCE
  ref."animal-id" || '_' || ref."tag-id" || '_start' AS occurrenceID, -- Same as EventID
  CASE
    WHEN ref."animal-sex" = 'm' THEN 'male'
    WHEN ref."animal-sex" = 'f' THEN 'female'
    WHEN ref."animal-sex" = 'u' THEN 'unknown'
  END                                   AS sex,
  ref."animal-life-stage"               AS lifeStage,
  ref."animal-reproductive-condition"   AS reproductiveCondition,
  'present'                             AS occurrenceStatus,
-- ORGANISM
  ref."animal-id"                       AS organismID,
  ref."animal-nickname"                 AS organismName,
-- EVENT
  ref."animal-id" || '_' || ref."tag-id" || '_start' AS eventID,
  ref."animal-id" || '_' || ref."tag-id" AS parentEventID,
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', ref."deploy-on-date", 'unixepoch') AS eventDate,
  'tag deployment start'                AS samplingProtocol,
  ref."tag-manufacturer-name" || ' tag attached by ' ||
  ref."attachment-type" || ' to ' ||
  CASE
    WHEN ref."manipulation-type" = 'none' THEN 'free-ranging animal'
    WHEN ref."manipulation-type" != 'none' THEN 'manipulated animal'
  END ||
  ' | ' || ref."deployment-comments"    AS eventRemarks,
-- LOCATION
  NULL                                  AS minimumDistanceAboveSurfaceInMeters,
  ref."deploy-on-latitude"              AS decimalLatitude,
  ref."deploy-on-longitude"             AS decimalLongitude,
  CASE
    WHEN ref."deploy-on-latitude" IS NOT NULL THEN 'WGS84'
    ELSE NULL
  END                                   AS geodeticDatum,
  CASE
    WHEN ref."deploy-on-latitude" IS NOT NULL THEN 1000 -- Deploy on coordinates not always precise
    ELSE NULL
  END                                   AS coordinateUncertaintyInMeters,
-- TAXON
  ref."animal-taxon"                    AS scientificName,
  'Animalia'                            AS kingdom
FROM
  reference_data AS ref
WHERE
  ref."deploy-on-date" IS NOT NULL

UNION

/* GPS POSITIONS */

SELECT
-- RECORD-LEVEL
  'MachineObservation'                  AS basisOfRecord,
  'see metadata'                        AS informationWithheld,
  'subsampled by hour: first of ' || gps."subsample-count" || ' record(s)' AS dataGeneralizations,
-- OCCURRENCE
  CAST(CAST(gps."event-id" AS int) AS text) AS occurrenceID, -- Avoid .0 format
  CASE
    WHEN ref."animal-sex" = 'm' THEN 'male'
    WHEN ref."animal-sex" = 'f' THEN 'female'
    WHEN ref."animal-sex" = 'u' THEN 'unknown'
  END                                   AS sex,
  NULL                                  AS lifeStage, -- Can change over time
  NULL                                  AS reproductiveCondition,  -- Can change over time
  'present'                             AS occurrenceStatus,
-- ORGANISM
  ref."animal-id"                       AS organismID,
  ref."animal-nickname"                 AS organismName,
-- EVENT
  CAST(CAST(gps."event-id" AS int) AS text) AS eventID,
  ref."animal-id" || '_' || ref."tag-id" AS parentEventID,
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', gps."timestamp", 'unixepoch') AS eventDate,
  gps."sensor-type"                     AS samplingProtocol,
  NULL                                  AS eventRemarks,
-- LOCATION
  gps."height-above-msl"                AS minimumDistanceAboveSurfaceInMeters,
  gps."location-lat"                    AS decimalLatitude,
  gps."location-long"                   AS decimalLongitude,
  'WGS84'                               AS geodeticDatum,
  gps."location-error-numerical"        AS coordinateUncertaintyInMeters,
-- TAXON
  ref."animal-taxon"                    AS scientificName,
  'Animalia'                            AS kingdom
FROM
  (
    SELECT
      *,
      COUNT(*) AS "subsample-count"
    FROM gps
    WHERE
      visible -- Exclude outliers
      AND gps."location-lat" IS NOT NULL -- Exclude (rare) empty coordinates
    GROUP BY
    -- Group by animal+tag+date+hour combination
      gps."individual-local-identifier" ||
      gps."tag-local-identifier" ||
      STRFTIME('%Y-%m-%dT%H', timestamp, 'unixepoch')
    HAVING
    -- Take first record/timestamp within group
    -- Movebank data are sorted by timestamp: https://github.com/tdwg/dwc-for-biologging/issues/31
      ROWID = MIN(ROWID)
  ) AS gps
  LEFT JOIN reference_data AS ref
    ON gps."individual-local-identifier" = ref."animal-id"
    AND gps."tag-local-identifier" = ref."tag-id"

UNION

/* DEPLOYMENT END */

SELECT
-- RECORD-LEVEL
  'HumanObservation'                    AS basisOfRecord,
  'see metadata'                        AS informationWithheld,
  NULL                                  AS dataGeneralizations,
-- OCCURRENCE
  ref."animal-id" || '_' || ref."tag-id" || '_end' AS occurrenceID, -- Same as EventID
  CASE
    WHEN ref."animal-sex" = 'm' THEN 'male'
    WHEN ref."animal-sex" = 'f' THEN 'female'
    WHEN ref."animal-sex" = 'u' THEN 'unknown'
  END                                   AS sex,
  NULL                                  AS lifeStage, -- Can change over time
  NULL                                  AS reproductiveCondition, -- Can change over time
  'present'                             AS occurrenceStatus,
-- ORGANISM
  ref."animal-id"                       AS organismID,
  ref."animal-nickname"                 AS organismName,
-- EVENT
  ref."animal-id" || '_' || ref."tag-id" || '_end' AS eventID,
  ref."animal-id" || '_' || ref."tag-id" AS parentEventID,
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', ref."deploy-off-date", 'unixepoch') AS eventDate,
  'tag deployment end'                  AS samplingProtocol,
  CASE
    WHEN ref."deployment-end-type" IS NOT NULL THEN ref."deployment-end-type"
  END                                   AS eventRemarks,
-- LOCATION
  NULL                                  AS minimumDistanceAboveSurfaceInMeters,
  ref."deploy-off-latitude"             AS decimalLatitude,
  ref."deploy-off-longitude"            AS decimalLongitude,
  CASE
    WHEN ref."deploy-off-latitude" IS NOT NULL THEN 'WGS84'
    ELSE NULL
  END                                   AS geodeticDatum,
  CASE
    WHEN ref."deploy-off-latitude" IS NOT NULL THEN 1000 -- Deploy off coordinates not always precise
    ELSE NULL
  END                                   AS coordinateUncertaintyInMeters,
-- TAXON
  ref."animal-taxon"                    AS scientificName,
  'Animalia'                            AS kingdom
FROM
  reference_data AS ref
WHERE
  ref."deploy-off-date" IS NOT NULL

)
