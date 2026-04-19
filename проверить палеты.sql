WITH base AS (
    SELECT 
        t.sscc as pallet_sscc,
        t2.sscc as box_sscc,t2.ttnid,t.ost as ostatok,
        COUNT(t2.sscc) OVER(PARTITION BY t.sscc,t.ttnid) as total_boxes,
        ROW_NUMBER() OVER(PARTITION BY t.sscc,t.ttnid ORDER BY t2.sscc) as rn
    FROM ttn_sscc t
    LEFT JOIN ttn_sscc t2 ON t2.parentsscc = t.sscc AND t2.sscc != t2.parentsscc and t.ttnid = t2.ttnid
    WHERE t.ttnId IN (select top(190000) id from TTN where id is not null order by id desc) 
      AND t.sscc NOT IN (SELECT sscc FROM ttn_spec_sgtin WHERE sscc IS NOT NULL) and len(t.sscc) = 18 
     
)
SELECT 
    pallet_sscc,
    total_boxes as kol,ttnid,ostatok,
    box_sscc as sample_box_sscc
FROM base 
WHERE  rn = 1   and ttnid is not null  -- Ѕерем первый короб или паллеты без коробов
ORDER BY ttnId DESC
