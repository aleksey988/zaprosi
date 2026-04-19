WITH BaseData AS (
    SELECT 
        tss.sgtin,
        tss.ost AS sgtin_ost,
        ts.sscc,
        ts.ost AS sscc_ost,
        ts.ttnid,kol_tov,kol_rezerv,t.id tid,
        CASE 
            WHEN tss.ost = 0 AND ts.ost NOT IN (0, 3) THEN 1
            WHEN tss.ost = 1 AND ts.ost != 0 THEN 1
            WHEN tss.ost = 2 AND ts.ost NOT IN (1, 2) THEN 1
            WHEN tss.ost = 3 AND ts.ost NOT IN (0, 3) THEN 1
            ELSE 0
        END AS is_mismatch
    FROM post_parties pp
    INNER JOIN ttn t ON t.p_party_id = pp.id 
    INNER JOIN ttn_spec_sgtin tss ON tss.ttn_id = t.id 
    LEFT JOIN ttn_sscc ts ON ts.sscc = tss.sscc AND ts.ttnid = t.id left join TOV_ZAP z on z.ttns_id = tss.ttns_id --and kol_tov != 0
    WHERE t.id in (select top(3000) ttnid from ttn_sscc where ttnid is not null order by ttnid desc) 
),
RankedData AS (
    SELECT 
        sgtin,
        sgtin_ost,
        sscc,
        sscc_ost,
        is_mismatch,kol_tov,kol_rezerv,tid,
        ROW_NUMBER() OVER (PARTITION BY sscc ORDER BY is_mismatch DESC, sgtin) AS rn
    FROM BaseData
    WHERE is_mismatch = 1
)
SELECT 
    sgtin,
    sgtin_ost AS ost_sgtin,
    sscc,
    sscc_ost AS ost_sscc,tid
FROM RankedData 
WHERE rn = 1 and  sgtin NOT LIKE '%[^0-9A-Za-z]%'  and len(sscc) = 18
ORDER BY sscc, sgtin;  --дальше одна ттн

--WITH BaseData AS (
--    SELECT 
--        tss.sgtin,
--        tss.ost AS sgtin_ost,
--        ts.sscc,
--        ts.ost AS sscc_ost,
--        ts.ttnid,kol_tov,kol_rezerv,t.id tid,tss.ttns_id ns,
--        CASE 
--            WHEN tss.ost = 0 AND ts.ost NOT IN (0, 3) THEN 1
--            WHEN tss.ost = 1 AND ts.ost != 0 THEN 1
--            WHEN tss.ost = 2 AND ts.ost NOT IN (1, 2) THEN 1
--            WHEN tss.ost = 3 AND ts.ost NOT IN (0, 3) THEN 1
--            ELSE 0
--        END AS is_mismatch
--    FROM post_parties pp
--    INNER JOIN ttn t ON t.p_party_id = pp.id 
--    INNER JOIN ttn_spec_sgtin tss ON tss.ttn_id = t.id 
--    LEFT JOIN ttn_sscc ts ON ts.sscc = tss.sscc AND ts.ttnid = t.id left join TOV_ZAP z on z.ttns_id = tss.ttns_id --and kol_tov != 0
--    WHERE t.id in (select top(3000) ttnid from ttn_sscc where ttnid is not null order by ttnid desc) 
--),
--RankedData AS (
--    SELECT 
--        sgtin,
--        sgtin_ost,ns,
--        sscc,
--        sscc_ost,
--        is_mismatch,kol_tov,kol_rezerv,tid,
--        ROW_NUMBER() OVER (PARTITION BY sscc ORDER BY is_mismatch DESC, sgtin) AS rn
--    FROM BaseData
--    WHERE is_mismatch = 1
--),base3 as (
--SELECT 
--    sgtin,ns,
--    sgtin_ost AS ost_sgtin,row_number()over(partition by tid order by sscc,sgtin ) t--одна ттн или 
--	,row_number()over(partition by ns order by sscc,sgtin) r, --одна ттнс
--    sscc,
--    sscc_ost AS ost_sscc,tid
--FROM RankedData 
--WHERE rn = 1 and  sgtin NOT LIKE '%[^0-9A-Za-z]%'  and len(sscc) = 18
--  )
--select sgtin,ost_sgtin,sscc,ost_sscc,tid,ns from base3
--where r=1