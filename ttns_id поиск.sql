SELECT 
    tss.sgtin,sscc,
    rsp.p_name,
    ts.ttn_id,
    ts.ocena_nds,
    ts.pnds,ost
FROM ttn_spec_sgtin tss
INNER JOIN ttn_spec ts ON tss.ttn_id = ts.ttn_id
INNER JOIN rozn_s_prep rsp ON ts.prep_id = rsp.id
WHERE ts.ocena_nds = (
    SELECT MAX(ocena_nds) 
    FROM ttn_spec 
    WHERE ttn_id = tss.ttn_id
)
AND ts.pnds = (
    SELECT MAX(pnds) 
    FROM ttn_spec 
    WHERE ttn_id = tss.ttn_id
)
AND (rsp.p_name LIKE '%Калия перманганат%') 

AND tss.ttn_id  IN ( '248488') and ost  = 0