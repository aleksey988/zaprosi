SELECT TOP (20000)
    x.sgtin,
    x.ocena_nds,
    x.pnds,
    x.sscc,
    x.markSupplierFinancingSource,
    x.markAcceptType,
    x.markSupplierContractType
FROM (
    SELECT
        ttn_spec_sgtin.sgtin,
        ttn_spec.ocena_nds,
        ttn_spec.pnds,
        ttn_spec_sgtin.sscc,
        ttn.markSupplierFinancingSource,
        ttn.markAcceptType,
        ttn.markSupplierContractType,

        ROW_NUMBER() OVER (
            PARTITION BY ttn_spec_sgtin.sscc
            ORDER BY 
                ttn_spec.ocena_nds DESC,
                ttn_spec.pnds DESC,
                ttn_spec_sgtin.sgtin
        ) AS rn
    FROM TTN_SPEC_SGTIN
    LEFT JOIN ttn_spec 
        ON ttn_spec_sgtin.ttns_id = ttn_spec.id 
    LEFT JOIN ttn 
        ON ttn.id = ttn_spec_sgtin.ttn_id 
    LEFT JOIN pri_voz_spec_sgtin 
        ON pri_voz_spec_sgtin.sgtin = ttn_spec_sgtin.sgtin
    WHERE ttn_spec_sgtin.sscc IN ('046600079302238482', '046600079302238291', '046600079302238451')
      AND ttn_spec_sgtin.sgtin <> '046601251402255sfzydfQMr(Vt'
) x
WHERE x.rn = 1
ORDER BY x.sscc;
