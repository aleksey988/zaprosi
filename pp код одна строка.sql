WITH UniqueSSCC AS (
    SELECT DISTINCT sscc, parentsscc, ost, ttnid
    FROM ttn_sscc
),
NumberedSSCC AS (
    SELECT 
        tss.sscc,
        ROW_NUMBER() OVER (ORDER BY tss.sscc) AS sscc_number
    FROM (
        SELECT DISTINCT tss.sscc
        FROM post_parties pp
        INNER JOIN ttn t ON t.p_party_id = pp.id
        INNER JOIN ttn_spec_sgtin tss ON tss.ttn_id = t.id AND tss.sscc IS NOT NULL
        WHERE pp.pp_code IN ('26-2605', '26-2623', '26-3016', '26-3035', '26-3091', '26-3154')
    ) tss
)
SELECT 
    sgtin,
    sscc,
    ost,
    pp_code,
    mdlp_status,
    ttn_id,
    ttn_sscc_ost,
    sscc_number
FROM (
    SELECT 
        tss.sgtin,
        tss.sscc,
        tss.ost,
        pp.pp_code,
        tss.mdlp_status,
        tss.ttn_id,
        ts.ost AS ttn_sscc_ost,
        ts.parentSscc AS parent,
        ns.sscc_number,
        -- Приоритет: сначала строки где SSCC не null, потом остальные.
        -- Внутри групп сортируем по sgtin для стабильности.
        ROW_NUMBER() OVER (
            PARTITION BY pp.pp_code 
            ORDER BY (CASE WHEN tss.sscc IS NOT NULL THEN 0 ELSE 1 END), tss.sgtin
        ) AS rn,
        ROW_NUMBER() OVER (PARTITION BY pp_code ORDER BY tss.sgtin) AS sscc_rn
    FROM post_parties pp
    INNER JOIN ttn t ON t.p_party_id = pp.id
    INNER JOIN ttn_spec_sgtin tss ON tss.ttn_id = t.id 
    LEFT JOIN UniqueSSCC ts ON ts.sscc = tss.sscc AND ts.ttnid = t.id 
    LEFT JOIN NumberedSSCC ns ON ns.sscc = tss.sscc
    WHERE pp.pp_code IN ('26-2605', '26-2623', '26-3016', '26-3035', '26-3091', '26-3154') 
) sub 
-- Если оставить WHERE rn = 1, выберется по 1 приоритетной строке на pp_code.
-- Если убрать, выведутся все SGTIN (и с SSCC, и без).

ORDER BY sscc_rn, sscc, sgtin;