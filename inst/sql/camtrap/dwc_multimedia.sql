/*
Created by Peter Desmet (INBO)
Mapping from Camtrap DP: https://tdwg.github.io/camtrap-dp
Y = included in DwC, N = not included in DwC

CAMTRAP DP MEDIA

mediaID                         Y: as link to observation
deploymentID                    N: included at observation level
sequenceID                      Y: as link to observation
captureMethod                   ?
timestamp                       Y
filePath                        Y
fileName                        Y: to sort data
fileMediatype                   Y
exifData                        N
favourite                       N
comments                        N
_id                             N

*/

-- Observations can be based on sequences (sequenceID) or individual files (mediaID)
-- Make two joins and union to capture both cases
WITH observations_media AS (
-- Sequence based observations
  SELECT
    obs.observationID,
    med.*
  FROM
    observations AS obs
    LEFT JOIN
      media AS med
      ON obs.sequenceID = med.sequenceID
  WHERE
    obs.mediaID IS NULL
    AND obs.observationType = 'animal'
  UNION
-- Media based observations
  SELECT
    obs.observationID,
    med.*
  FROM
    observations AS obs
    LEFT JOIN
      media AS med
      ON obs.mediaID = med.mediaID
  WHERE
    obs.mediaID IS NOT NULL
    AND obs.observationType = 'animal'
)

SELECT
-- occurrenceID
  obs_med.observationID AS occurrenceID,
-- type
  CASE
    WHEN obs_med.fileMediatype LIKE '%video%' THEN 'MovingImage'
    ELSE 'StillImage'
  END AS type,
-- format
  obs_med.fileMediatype AS format,
-- identifier
  obs_med.filePath AS identifier,
-- references
-- title
-- description
-- created
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', datetime(obs_med.timestamp, 'unixepoch')) AS created
-- creator
-- contributor
-- publisher
-- audience
-- source
-- license                              Only available in dataset metadata
-- rightsHolder                         Only available in dataset metadata
-- datasetID                            Only available in dataset metadata

FROM
  observations_media AS obs_med

ORDER BY
-- Order is not retained in observations_media, so important to sort
  obs_med."timestamp",
  obs_med."fileName"
