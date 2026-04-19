SELECT 
    markSupplierFinancingSource, 
    id, 
    sgtin
FROM (
    SELECT 
        t.markSupplierFinancingSource, 
        t.id, 
        tss.sgtin,
        ROW_NUMBER() OVER (PARTITION BY t.id ORDER BY tss.sgtin ASC) AS rn_one
    FROM ttn t
    JOIN ttn_spec_sgtin tss ON tss.ttn_id = t.id 
    LEFT JOIN pri_voz_spec_sgtin p ON p.sgtin = tss.sgtin
    WHERE (tss.sgtin IN ('') OR tss.sscc IN ('') OR p.pvid IN ('3108867','3113328'))
      AND tss.sgtin != '046601251402255sfzydfQMr(Vt'
) sub
WHERE rn_one = 1
ORDER BY id;