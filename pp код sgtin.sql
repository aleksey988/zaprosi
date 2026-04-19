WITH base AS (
    SELECT 
        tss.sgtin,
        tss.sscc,
        tss.ost,
        pp_code,
        s.ost as korob,
        t.id as ttn_id,
        ROW_NUMBER() OVER (
            PARTITION BY pp_code 
            ORDER BY 
                CASE WHEN tss.sscc IS NOT NULL THEN 0 ELSE 1 END,
                tss.sgtin
        ) AS rn
    FROM post_parties pp
    INNER JOIN ttn t ON t.p_party_id = pp.id
    INNER JOIN ttn_spec_sgtin tss ON tss.ttn_id = t.id 
    LEFT JOIN ttn_sscc s ON s.sscc = tss.sscc
    WHERE pp.pp_code IN ('26-3187') 
      
       AND tss.ttn_id != '0'
),
deduplicated AS (
    SELECT 
        sgtin,rn,
        sscc,
        ost,
        pp_code,
        korob,
        ttn_id,
        ROW_NUMBER() OVER (
            PARTITION BY sgtin 
            ORDER BY ttn_id desc  -- выбираем запись с минимальным ttn_id
        ) as sgtin_rn
    FROM base
)
SELECT sgtin, sscc, ost, pp_code, korob,ttn_id
FROM deduplicated

