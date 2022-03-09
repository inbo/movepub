/*
Created by Peter Desmet (INBO)
Mapping from Camtrap DP: https://tdwg.github.io/camtrap-dp
Mapping to Audubon Media Description: https://rs.gbif.org/extension/ac/audubon_2020_10_06.xml
Y = included in DwC, N = not included in DwC

CAMTRAP DP MEDIA

mediaID                         Y: as link to observation
deploymentID                    N: included at observation level
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

SELECT
-- occurrenceID
  obs.observationID AS occurrenceID,
-- creator
-- providerLiteral
-- provider
-- rights
  {metadata$mediaLicense} AS rights,
-- owner
-- identifier
  med.mediaID AS identifier,
-- type
  CASE
    WHEN med.fileMediatype LIKE '%video%' THEN 'MovingImage'
    ELSE 'StillImage'
  END AS type,
-- providerManagedID
  med._id AS providerManagedID,
-- captureDevice
--  dep.cameraModel AS captureDevice,
-- resourceCreationTechnique
  med.captureMethod AS resourceCreationTechnique,
-- accessURI
  med.filePath AS accessURI,
-- format
  med.fileMediatype AS format,
-- CreateDate
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', datetime(med.timestamp, 'unixepoch')) AS createDate

FROM
  observations AS obs
  LEFT JOIN observationunits AS obsu
    ON obs.observationUnitID = obsu.observationUnitID
  LEFT JOIN media AS med
    ON obsu.mediaID = med.mediaID

WHERE
  obs.observationType = 'animal'

ORDER BY
  med.timestamp,
  med.fileName
