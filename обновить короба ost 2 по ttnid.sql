UPDATE t2
SET 
    parentsscc = t1.sscc,  -- SSCC паллета
    ost = 2
FROM ttn_sscc t1  -- паллеты
INNER JOIN ttn_sscc t2 ON t2.ttnid = t1.ttnid  -- короба с тем же ttnid
WHERE 
    t1.sscc IN ('046200086268643773', '046200086268643774', '046200086268643775') -- Ваши паллеты
    AND t1.sscc = t1.parentsscc -- это паллеты (sscc = parentsscc)
    AND t1.ost = 1              -- паллеты активны
    AND t2.sscc = t2.parentsscc -- короба НЕ проставлены (sscc = parentsscc)
    AND t2.ost = 1              -- короба активны
    AND t2.parentsscc != t1.sscc -- короба не связаны с этим паллетом
    AND t1.sscc NOT IN (SELECT sscc FROM ttn_spec_sgtin WHERE sscc IS NOT NULL)
    AND NOT EXISTS (            -- проверяем, что ВСЕ короба активны
        SELECT 1 
        FROM ttn_sscc t3 
        WHERE t3.ttnid = t1.ttnid 
          AND t3.sscc = t3.parentsscc  -- непроставленные короба
          AND t3.parentsscc != t1.sscc -- не связаны с этим паллетом
          AND t3.ost != 1
    )
