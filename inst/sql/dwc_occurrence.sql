/*
Schema: https://rs.gbif.org/core/dwc_occurrence_2022-02-02.xml
*/

/* DATASET-LEVEL */

SELECT
  'Event'                               AS type,
  {license}                             AS license,
  {rights_holder}                       AS rightsHolder,
  {dataset_id}                          AS datasetID,
  'MPIAB'                               AS institutionCode, -- Max Planck Institute of Animal Behavior
  'Movebank'                            AS collectionCode,
  {dataset_name}                        AS datasetName,
  *
FROM (

/* DEPLOYMENT START */

SELECT
-- RECORD-LEVEL
  'HumanObservation'                    AS basisOfRecord,
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
  'tag attachment'                      AS eventType,
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', ref."deploy-on-date", 'unixepoch') AS eventDate,
  'tag attachment'                      AS samplingProtocol,
  COALESCE(
    ref."tag-manufacturer-name" || ' ' || ref."tag-model" || ' tag ',
    ref."tag-manufacturer-name" || ' tag ',
    'tag '
  ) ||
  COALESCE(
    'attached by ' || ref."attachment-type" || ' to ',
    'attached to '
  ) ||
  CASE
    WHEN ref."manipulation-type" = 'none' THEN 'free-ranging animal'
    WHEN ref."manipulation-type" = 'confined' THEN 'confined animal'
    WHEN ref."manipulation-type" = 'recolated' THEN 'relocated animal'
    WHEN ref."manipulation-type" = 'manipulated other' THEN 'manipulated animal'
    ELSE 'likely free-ranging animal'
  END ||
  COALESCE(
    ' | ' || ref."deployment-comments",
    ''
  )                                     AS eventRemarks,
-- LOCATION
  NULL                                  AS minimumElevationInMeters,
  NULL                                  AS maximumElevationInMeters,
  NULL                                  AS locationRemarks,
  ref."deploy-on-latitude"              AS decimalLatitude,
  ref."deploy-on-longitude"             AS decimalLongitude,
  CASE
    WHEN ref."deploy-on-latitude" IS NOT NULL THEN 'EPSG:4326'
  END                                   AS geodeticDatum,
  CASE
    -- Assume coordinate precision of 0.001 degree (157m) and recording by GPS (30m)
    WHEN ref."deploy-on-latitude" IS NOT NULL THEN 187
  END                                   AS coordinateUncertaintyInMeters,
-- TAXON
  'urn:lsid:marinespecies.org:taxname:' || taxon."aphia_id" AS scientificNameID,
  ref."animal-taxon"                    AS scientificName,
  'Animalia'                            AS kingdom
FROM
  reference_data AS ref
  LEFT JOIN taxa AS taxon
    ON ref."animal-taxon" = taxon."name"
WHERE
  ref."deploy-on-date" IS NOT NULL

UNION

/* GPS POSITIONS */

SELECT
-- RECORD-LEVEL
  'MachineObservation'                  AS basisOfRecord,
  'subsampled by hour: first of ' || gps."subsample-count" || ' record(s)' AS dataGeneralizations,
-- OCCURRENCE
  CAST(CAST(gps."event-id" AS int) AS text) AS occurrenceID, -- Avoid .0 format
  CASE
    WHEN ref."animal-sex" = 'm' THEN 'male'
    WHEN ref."animal-sex" = 'f' THEN 'female'
    WHEN ref."animal-sex" = 'u' THEN 'unknown'
  END                                   AS sex,
  NULL                                  AS lifeStage, -- Value at start of deployment might not apply to all records
  NULL                                  AS reproductiveCondition, -- Value at start of deployment might not apply to all records
  'present'                             AS occurrenceStatus,
-- ORGANISM
  ref."animal-id"                       AS organismID,
  ref."animal-nickname"                 AS organismName,
-- EVENT
  CAST(CAST(gps."event-id" AS int) AS text) AS eventID,
  ref."animal-id" || '_' || ref."tag-id" AS parentEventID,
  'gps'                                 AS eventType,
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', gps."timestamp", 'unixepoch') AS eventDate,
  gps."sensor-type"                     AS samplingProtocol,
  COALESCE(
    gps."comments",
    ''
  )                                     AS eventRemarks,
-- LOCATION
  COALESCE(
    gps."height-above-msl",
    gps."height-above-ellipsoid",
    NULL
  )                                     AS minimumElevationInMeters,
  COALESCE(
    gps."height-above-msl",
    gps."height-above-ellipsoid",
    NULL
  )                                     AS maximumElevationInMeters,
  CASE
    WHEN gps."height-above-msl" IS NOT NULL THEN 'elevations are altitude above mean sea level'
    WHEN gps."height-above-ellipsoid" IS NOT NULL THEN 'elevations are altitude above above'
  END                                   AS locationRemarks,
  gps."location-lat"                    AS decimalLatitude,
  gps."location-long"                   AS decimalLongitude,
  'EPSG:4326'                           AS geodeticDatum,
  gps."location-error-numerical"        AS coordinateUncertaintyInMeters,
-- TAXON
  'urn:lsid:marinespecies.org:taxname:' || taxon."aphia_id" AS scientificNameID,
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
    -- Take first record/timestamp within group (Movebank data are sorted chronologically)
      ROWID = MIN(ROWID)
  ) AS gps
  LEFT JOIN reference_data AS ref
    ON gps."individual-local-identifier" = ref."animal-id"
    AND gps."tag-local-identifier" = ref."tag-id"
  LEFT JOIN taxa AS taxon
    ON ref."animal-taxon" = taxon."name"
WHERE
  ref."animal-taxon" IS NOT NULL -- Exclude (rare) records outside a deployment
)

ORDER BY
  parentEventID,
  eventDate
