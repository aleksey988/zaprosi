WITH SSCCInPriVoz AS (
    SELECT DISTINCT sscc, pvid
    FROM pri_voz_spec_sgtin
    WHERE sscc IS NOT NULL
),
SGTINInPriVoz AS (
    SELECT DISTINCT sgtin, pvid
    FROM pri_voz_spec_sgtin
    WHERE sgtin IS NOT NULL
),
MissingSGTIN AS (
    SELECT 
        t.sgtin,
        t.sscc,
        sp.pvid
    FROM ttn_spec_sgtin t
    INNER JOIN SSCCInPriVoz sp ON sp.sscc = t.sscc
    LEFT JOIN SGTINInPriVoz sg ON sg.sgtin = t.sgtin AND sg.pvid = sp.pvid
    WHERE sg.sgtin IS NULL
      AND t.sscc IS NOT NULL
)
SELECT 
    sscc,
    pvid,
    COUNT(*) AS missing_count,
    STRING_AGG(CAST(sgtin AS VARCHAR(MAX)), ', ') AS missing_sgtin_list
FROM MissingSGTIN
GROUP BY sscc, pvid
ORDER BY pvid, sscc;
