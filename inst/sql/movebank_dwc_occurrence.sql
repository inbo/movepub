/*
Created by Peter Desmet (INBO)
*/

/* RECORD-LEVEL */

SELECT
  'Event'                               AS type,
  'TODO'                                AS license,
  'TODO'                                AS rightsHolder,
  'TODO'                                AS datasetID,
  'TODO'                                AS institionCode,
  'TODO'                                AS collectionCode,
  'TODO'                                AS datasetName,
  *
FROM (

/* DEPLOYMENTS */

SELECT
-- RECORD-LEVEL
  'HumanObservation'                    AS basisOfRecord,
  'TODO'                                AS informationWithheld,
  NULL                                  AS dataGeneralizations,
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
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', ref."deploy-on-date", 'unixepoch') AS eventDate,
  ref."deployment-comments"             AS eventRemarks,
-- LOCATION
  NULL                                  AS minimumDistanceAboveSurfaceInMeters,
  ref."deploy-on-latitude"              AS decimalLatitude,
  ref."deploy-on-longitude"             AS decimalLongitude,
  'WGS84'                               AS geodeticDatum,
  30                                    AS coordinateUncertaintyInMeters,
-- TAXON
  ref."animal-taxon"                    AS scientificName,
  'Animalia'                            AS kingdom
FROM
  reference_data AS ref

UNION

/* GPS POSITIONS */

SELECT
-- RECORD-LEVEL
  'MachineObservation'                  AS basisOfRecord,
  'TODO'                                AS informationWithheld,
  'subsampled by hour: first of ' || gps."subsample-count" || ' records' AS dataGeneralizations,
-- OCCURRENCE
  CAST(CAST(gps."event-id" AS int) AS text) AS occurrenceID, -- Avoid .0 format
  NULL                                  AS sex,
  NULL                                  AS lifeStage,
  'present'                             AS occurrenceStatus,
-- ORGANISM
  ref."animal-id"                       AS organismID,
  ref."animal-nickname"                 AS organismName,
-- EVENT
  ref."tag-id" ||  '-' || ref."animal-id" AS eventID,
  gps."sensor-type"                     AS samplingProtocol,
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', gps."timestamp", 'unixepoch') AS eventDate,
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
    GROUP BY
    -- Group by tag+animal+date+hour combination
      gps."tag-local-identifier" ||
      gps."individual-local-identifier" ||
      STRFTIME('%Y-%m-%dT%H', timestamp, 'unixepoch')
    HAVING
    -- Take first record/timestamp within group
    -- Movebank data are sorted by timestamp: https://github.com/tdwg/dwc-for-biologging/issues/31
      ROWID = MIN(ROWID)
  ) AS gps
  LEFT JOIN reference_data AS ref
    ON gps."tag-local-identifier" = ref."tag-id"
    AND gps."individual-local-identifier" = ref."animal-id"
)
