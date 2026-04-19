WITH LatestMarkProcessing AS (
    SELECT documentid, processingStatusId,
    ROW_NUMBER() OVER (PARTITION BY documentid ORDER BY createdate DESC) AS rn
    FROM mark_processing
)
SELECT DISTINCT tss.sgtin
FROM ttn_spec_sgtin tss
INNER JOIN ttn_sscc tssc ON tssc.sscc = tss.sscc
INNER JOIN pri_voz_spec_sgtin pvs ON pvs.sgtin = tss.sgtin
INNER JOIN LatestMarkProcessing lmp ON lmp.documentid = pvs.pvid
WHERE tss.ost = 2
  AND tssc.ost IN (1, 2)
  AND pvs.tsd = 2
  AND lmp.rn = 1
  AND lmp.processingStatusId = 3
  AND tss.sgtin NOT IN (
      SELECT sgtin 
      FROM APT_VOZVRAT_SPEC_SGTIN
  );