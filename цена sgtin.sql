WITH AllData AS (
    -- Основная таблица
    SELECT 
        t.sgtin,
        t.ttns_id,
        t.ttn_id,
        t.sscc
    FROM TTN_SPEC_SGTIN t

    UNION ALL

    -- Архив (только если такого sgtin нет в основной)
    SELECT 
        a.sgtin,
        a.ttns_id,
        a.ttn_id,
        a.sscc
    FROM TTN_SPEC_SGTIN_ARCHIVE a
    WHERE NOT EXISTS (
        SELECT 1
        FROM TTN_SPEC_SGTIN t
        WHERE t.sgtin = a.sgtin
    )
)

SELECT 
    sgtin, 
    ocena_nds, 
    pnds, 
    sscc, 
    markSupplierFinancingSource, 
    markAcceptType, 
    markSupplierContractType
FROM (
    SELECT 
        ad.sgtin, 
        ts.ocena_nds, 
        ts.pnds, 
        ad.sscc, 
        ttn.markSupplierFinancingSource, 
        ttn.markAcceptType, 
        ttn.markSupplierContractType,

        MAX(ts.ocena_nds) OVER (PARTITION BY ad.sgtin) AS max_ocena,
        MAX(ts.pnds) OVER (PARTITION BY ad.sgtin) AS max_pnds,

        ROW_NUMBER() OVER (
            PARTITION BY ad.sgtin
            ORDER BY ts.ocena_nds DESC, ts.pnds DESC
        ) AS PriceRank

    FROM AllData ad
    LEFT JOIN ttn_spec ts ON ad.ttns_id = ts.id
    LEFT JOIN PRI_VOZ_SPEC_SGTIN pvs ON pvs.sgtin = ad.sgtin
    LEFT JOIN ttn ON ttn.id = ad.ttn_id

    WHERE ad.sgtin IN (
        '04604060997124DEnCHZpQzCoEA'
    )
    AND ad.sgtin <> '046601251402255sfzydfQMr(Vt'
    AND (pvs.sgtin IS NULL OR pvs.sgtin <> '046004880052433108310723901')
) AS SubQuery
WHERE ocena_nds = max_ocena 
  AND pnds = max_pnds 
  AND PriceRank = 1;
