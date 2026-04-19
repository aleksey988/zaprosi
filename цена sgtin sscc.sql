WITH AllData AS (
    SELECT 
        t.sgtin,
        t.ttns_id,
        t.ttn_id,
        t.sscc
    FROM TTN_SPEC_SGTIN t
    UNION ALL
    SELECT 
        a.sgtin,
        a.ttns_id,
        a.ttn_id,
        a.sscc
    FROM TTN_SPEC_SGTIN_ARCHIVE a
    WHERE NOT EXISTS (
        SELECT 1
        FROM TTN_SPEC_SGTIN t
        WHERE t.sscc = a.sscc and t.sgtin = a.sgtin
    )
),
MaxPrice AS (
    SELECT 
        ad.sgtin,
        ad.sscc,
        ad.ttn_id,
        ad.ttns_id,
        ts.ocena_nds,
        ts.pnds,
        ttn.markSupplierFinancingSource,
        ttn.markAcceptType,
        ttn.markSupplierContractType,
        ROW_NUMBER() OVER (
            PARTITION BY ad.sgtin
            ORDER BY ts.ocena_nds DESC, ts.pnds DESC
        ) AS rn_price
    FROM AllData ad
    LEFT JOIN ttn_spec ts ON ad.ttns_id = ts.id
    LEFT JOIN ttn ON ttn.id = ad.ttn_id
    LEFT JOIN PRI_VOZ_SPEC_SGTIN pvs ON pvs.sgtin = ad.sgtin
    WHERE (
        pvs.pvid IN ('') 
     
    )
    AND ad.sgtin <> '046040609917571039T11PKB706(Vt'
    AND (pvs.sgtin IS NULL OR pvs.sgtin <> '046004880052433108310723901') and ad.sgtin != '046601251402255sfzydfQMr(Vt'
),
Numbered AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY sscc
            ORDER BY sgtin
        ) AS rn_sscc
    FROM MaxPrice
    WHERE rn_price = 1
)
SELECT
    sgtin,
    ocena_nds,
    pnds,
    sscc,
    markSupplierFinancingSource,
    markAcceptType,
    markSupplierContractType,
    rn_sscc
FROM Numbered 
ORDER BY rn_sscc, sscc, sgtin; 
