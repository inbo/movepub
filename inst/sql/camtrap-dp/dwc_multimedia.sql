/*
Created by Peter Desmet (INBO)
Mapping from Camtrap DP: https://tdwg.github.io/camtrap-dp
Mapping to Audubon Media Description: https://rs.gbif.org/extension/ac/audubon_2020_10_06.xml
Y = included in DwC, N = not included in DwC

CAMTRAP DP MEDIA

mediaID                         Y: as link to observation
parentMediaID                   Y: as link to child media files
deploymentID                    Y
captureMethod                   ?
start                           Y
end                             N
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
  STRFTIME('%Y-%m-%dT%H:%M:%SZ', datetime(med.start, 'unixepoch')) AS createDate

FROM
  observations AS obs
  LEFT JOIN media AS parent_med
    ON obs.mediaID = parent_med.mediaID
  LEFT JOIN
    (
      SELECT
        *,
        CASE
          WHEN parentMediaID IS NULL THEN mediaID -- Make parents their own child
          ELSE parentMediaID
        END AS populatedParentMediaID
      FROM media
    ) AS med
    ON med.populatedParentMediaID = parent_med.mediaID

WHERE
  obs.observationType = 'animal' AND
  med.filePath IS NOT NULL -- Remove sequences

ORDER BY
  med.start,
  med.fileName
