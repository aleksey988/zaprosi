SELECT DISTINCT sgtin,ttns_id,sscc,ttn_id,mdlp_status_date
FROM (
    SELECT 
        tq.sgtin,
        tq.ttn_id,
        tq.ttns_id,sscc,mdlp_status_date,
        ROW_NUMBER() OVER (PARTITION BY tq.ttns_id ORDER BY tq.sgtin) AS rn
    FROM ttn_spec_sgtin tq
    JOIN ttn ON ttn.id = tq.ttn_id
    JOIN s_sklads s ON s.id = ttn.sklad_id 
    JOIN TOV_ZAP t ON t.ttns_id = tq.ttns_id
    WHERE 
       tq.ost  = 1
      AND (
          s.markAddressId LIKE '00000000550927' 
          
      )
      AND t.kol_tov != 0 
      AND tq.sgtin NOT LIKE '%[^0-9A-Za-z]%'
      AND tq.sgtin IS NOT NULL
      AND LEN(tq.sgtin) > 0
) sub
where rn =1
ORDER BY mdlp_status_date desc, sgtin;