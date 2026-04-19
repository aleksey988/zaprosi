WITH SSCCInPriVoz AS (
    SELECT DISTINCT sscc, pvid
    FROM pri_voz_spec_sgtin
    WHERE sscc IS NOT NULL
),
SGTINInPriVoz AS (
    SELECT sgtin, pvid
    FROM pri_voz_spec_sgtin
    WHERE sgtin IS NOT NULL
),
MissingCounts AS (
    SELECT 
        t.sscc,
        sp.pvid,
        COUNT(*) AS total_in_ttn,
        COUNT(sg.sgtin) AS scanned_count
    FROM ttn_spec_sgtin t
    INNER JOIN SSCCInPriVoz sp ON sp.sscc = t.sscc
    LEFT JOIN SGTINInPriVoz sg ON sg.sgtin = t.sgtin AND sg.pvid = sp.pvid
    WHERE t.sscc IS NOT NULL
    GROUP BY t.sscc, sp.pvid
    HAVING COUNT(*) > COUNT(sg.sgtin)  -- Только неполные коробы
)
SELECT top(10)
    mc.sscc,
    mc.pvid,
    pv.pv_num,
    mc.total_in_ttn,
    mc.scanned_count,
    mc.total_in_ttn - mc.scanned_count AS missing_count
FROM MissingCounts mc
LEFT JOIN pri_voz pv ON pv.id = mc.pvid
ORDER BY mc.pvid, mc.sscc;
