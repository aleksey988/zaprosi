SELECT DISTINCT t1.sscc
FROM rsklad.dbo.ttn_sscc t1
JOIN rsklad_test.dbo.ttn_sscc t2
    ON t1.sscc = t2.sscc
   AND t1.ttnid = t2.ttnid and t1.ttnid not in (select ttn_id from ttn_spec_sgtin where ttns_id in (select ttns_id from tov_zap where kol_tov =0 and ttns_id is not null) and ttns_id is not null) and t1.ttnId=0
WHERE ISNULL(t1.ost,0) <> ISNULL(t2.ost,0)
--AND t1.sscc not in  (
--    SELECT sscc
--    FROM pri_voz_spec_sgtin 
--    where sscc is not null
--)
AND t1.sscc not in  (
    SELECT t.sscc
    FROM ttn_spec_sgtin t
	where t.sscc is not null and t1.sscc = t.sscc and sgtin in (select sgtin from pri_voz_spec_sgtin where sgtin is not null)
    
)  --and t1.sscc not in (select sscc from ttn_spec_sgtin where sscc is not null group by sscc having count(case when ost = 0 then 1 end) > 0 )
--and t1.sscc in (select sscc from ttn_spec_sgtin where sscc is not null)
UNION

-- изменения по SGTIN
SELECT distinct c.sscc
FROM rsklad.dbo.ttn_spec_sgtin c
 left JOIN rsklad_test.dbo.ttn_spec_sgtin y
    ON c.sgtin = y.sgtin
WHERE ISNULL(c.ost,0) <> ISNULL(y.ost,0)
  AND c.ttn_id <> 0

  AND c.ttns_id NOT IN (
        SELECT ttns_id
        FROM tov_zap
        WHERE kol_tov = 0
          AND ttns_id IS NOT NULL
  )

  AND c.sscc NOT IN (
    SELECT sscc
    FROM ttn_spec_sgtin t
    WHERE sscc is not null and t.sgtin IN (SELECT sgtin FROM pri_voz_spec_sgtin WHERE sgtin IS NOT NULL)
) 


   --and c.sscc not in (select sscc from ttn_spec_sgtin where sscc is not null group by sscc   Having count(case when ost = 0 then 1 end) > 0)

ORDER BY sscc;



SELECT  t.sscc, t.ttn_id
FROM ttn_spec_sgtin t
LEFT JOIN pri_voz_spec_sgtin p
    ON p.sgtin = t.sgtin
WHERE t.sscc NOT IN (
        SELECT sscc 
        FROM ttn_sscc 
        WHERE sscc IS NOT NULL  
          AND ost IN (1, 2)
    ) 
  AND t.ttn_id != 0 
  AND t.ttn_id IN (SELECT TOP (10000) id FROM ttn ORDER BY id DESC)
GROUP BY t.sscc, t.ttn_id
HAVING COUNT(*) = SUM(CASE WHEN t.ost = 2 THEN 1 ELSE 0 END)
   AND COUNT(*) = SUM(CASE WHEN t.sgtin NOT LIKE '%[^0-9A-Za-z]%' THEN 1 ELSE 0 END)
   AND COUNT(*) = SUM(CASE WHEN t.sgtin NOT LIKE '%[а-яА-ЯёЁ]%' COLLATE Cyrillic_General_CS_AS THEN 1 ELSE 0 END)
   AND SUM(CASE WHEN p.sgtin IS NOT NULL THEN 1 ELSE 0 END) = 0;



