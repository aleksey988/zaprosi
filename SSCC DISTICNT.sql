WITH BaseData AS (
    SELECT
        pvs.pvid, 
        pvs.sgtin,
        CASE 
            WHEN pvs.sscc IS NULL 
                 AND COALESCE(tss.sscc, tssa.sscc) NOT IN (
                     SELECT pvs_sscc.sscc 
                     FROM PRI_VOZ_SSCC pvs_sscc 
                     WHERE pvs_sscc.pvid = pvs.pvid 
                       AND pvs_sscc.sscc IS NOT NULL
                 )
            THEN COALESCE(tss.sscc, tssa.sscc)
        END AS sscc_rasform,
        CASE 
            WHEN ttn_sscc.parentsscc IS NOT NULL 
                 AND ttn_sscc.parentsscc != ttn_sscc.sscc
            THEN ttn_sscc.parentsscc 
            ELSE NULL 
        END AS parent_sscc_different
    FROM PRI_VOZ_SPEC_SGTIN pvs
    LEFT JOIN TTN_SPEC_SGTIN tss ON tss.sgtin = pvs.sgtin
    LEFT JOIN TTN_SPEC_SGTIN_ARCHIVE tssa ON tssa.sgtin = pvs.sgtin
    LEFT JOIN ttn_sscc ON ttn_sscc.sscc = COALESCE(tss.sscc, tssa.sscc)
    WHERE 
        (pvs.pvid IN ('3118996','3126247','3126405','3126113','3126319','3126640','3126208','3126359','3126861','3126154','3126329','3126833') )
         and pvs.tsd = 1
          and pvs.sgtin  != '053505860050250872848171884' and pvid != 0  
)
SELECT
    pvid,
    sgtin,
    MAX(sscc_rasform) AS sscc_rasform,
    MAX(parent_sscc_different) AS parent_sscc_different
FROM BaseData
GROUP BY pvid, sgtin
ORDER BY pvid, sgtin;