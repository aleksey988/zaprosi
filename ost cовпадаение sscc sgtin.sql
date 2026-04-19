WITH UniqueSSCC AS (
    SELECT 
        sscc
    FROM ttn_sscc
    WHERE sscc NOT LIKE '%[^0-9]%'
      AND LEN(sscc) = 18
    GROUP BY sscc
    HAVING COUNT(CASE WHEN ost <> 0 THEN 1 END) = 0
),
ValidSSCC AS (
    SELECT 
        tss.sscc
    FROM ttn_spec_sgtin tss
    INNER JOIN UniqueSSCC us 
        ON us.sscc = tss.sscc
    WHERE tss.sgtin NOT LIKE '%[^0-9A-Za-z]%'
    GROUP BY tss.sscc
    HAVING 
        COUNT(*) > 0
        AND COUNT(CASE WHEN tss.ost = 2 THEN 1 END) = COUNT(*)  -- бяе ost = 2
),
RankedData AS (
    SELECT 
        tss.sgtin,
        tss.ost AS ost_sgtin,
        tss.sscc,
        ROW_NUMBER() OVER (PARTITION BY tss.sscc ORDER BY tss.sgtin) AS rn
    FROM ttn_spec_sgtin tss
    INNER JOIN ValidSSCC v 
        ON v.sscc = tss.sscc
)
SELECT 
    sgtin,
    ost_sgtin,
    sscc
FROM RankedData
WHERE rn = 1
ORDER BY sscc, sgtin;