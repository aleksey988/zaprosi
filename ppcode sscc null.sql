WITH BaseData AS (
    SELECT 
        tss.sgtin,
        tss.ost AS sgtin_ost,
        ts.sscc,
        ts.ost AS sscc_ost,
        ts.ttnid,kol_tov,kol_rezerv,t.id tid,tss.ttns_id ns,
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
    LEFT JOIN ttn_sscc ts ON ts.sscc = tss.sscc AND ts.ttnid = t.id 
    LEFT JOIN TOV_ZAP z on z.ttns_id = tss.ttns_id
    WHERE t.id in ('262960','263001','263016','263017','263018','263021','263022','263023','263029','263031','263030','263026','263035','263037','263041','263046','263052','263091','263085') 
),
RankedData AS (
    SELECT 
        sgtin,
        sgtin_ost,ns,
        sscc,
        sscc_ost,
        is_mismatch,kol_tov,kol_rezerv,tid,
        ROW_NUMBER() OVER (PARTITION BY sscc ORDER BY is_mismatch DESC, sgtin) AS rn
        
    FROM BaseData
    WHERE is_mismatch = 1 or sscc is null
),
base3 as (
    SELECT 
        sgtin,ns,
        sgtin_ost AS ost_sgtin,
        row_number()over(partition by tid order by sscc,sgtin) t,
        row_number()over(partition by ns order by sscc,sgtin) r,
        sscc,
        sscc_ost AS ost_sscc,tid
        
    FROM RankedData 
    WHERE rn = 1 and sgtin NOT LIKE '%[^0-9A-Za-z]%' and len(sscc) = 18
),
base_bez as (
    SELECT 
        sgtin,ns,
        sgtin_ost AS ost_sgtin,
        tid,
        row_number()over(partition by ns order by sgtin) rbez
    FROM RankedData 
    WHERE sscc is null 
    and sgtin NOT LIKE '%[^0-9A-Za-z]%'
    and sgtin_ost in (1,2)
)
select 
    b.sgtin,b.ost_sgtin,b.sscc,b.ost_sscc,b.tid,b.ns,
    bb.sgtin as sgtin_bez_koroba
from base3 b
left join base_bez bb on bb.ns = b.ns and bb.rbez = 1
where b.r = 1
order by b.ns desc, b.tid desc