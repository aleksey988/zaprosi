SELECT TOP(100) 
    t.sscc,
    COUNT(t2.sscc) AS kol 
FROM ttn_sscc t 
INNER JOIN ttn_sscc t2 ON t2.parentsscc = t.sscc 
    AND t2.sscc != t2.parentsscc
    AND t2.ttnid = t.ttnid  -- Добавлено условие: одинаковый ttn_id
WHERE t.sscc NOT IN (SELECT sscc FROM ttn_spec_sgtin WHERE sscc IS NOT NULL) 
  AND t.sscc = t.parentsscc
GROUP BY t.sscc
