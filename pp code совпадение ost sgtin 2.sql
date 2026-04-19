WITH BaseData AS (
    SELECT 
        tss.sgtin,
        tss.ost AS sgtin_ost,t.id,
        ts.sscc,
        ts.ost AS sscc_ost,
        ts.ttnid, kol_tov, kol_rezerv,
        t2.sscc palet, t2.ost paletost,
        CASE 
            WHEN tss.ost = 0 AND ts.ost NOT IN (0, 3) THEN 1
            WHEN tss.ost = 1 AND ts.ost != 0 THEN 1
            WHEN tss.ost = 2 AND ts.ost NOT IN (1, 2) THEN 1
            WHEN tss.ost = 3 AND ts.ost NOT IN (0, 3) THEN 1
            ELSE 0
        END AS is_mismatch,
        CASE WHEN tss.ost = 2 AND t2.ost != 1 THEN 1 ELSE 0 END AS miss_palet
    FROM post_parties pp
    INNER JOIN ttn t ON t.p_party_id = pp.id 
    INNER JOIN ttn_spec_sgtin tss ON tss.ttn_id = t.id 
    LEFT JOIN ttn_sscc ts ON ts.sscc = tss.sscc AND ts.ttnid = t.id
    left JOIN TOV_ZAP z ON z.ttns_id = tss.ttns_id AND kol_tov != 0
    LEFT JOIN ttn_sscc t2 ON ts.parentsscc = t2.sscc 
        AND t2.sscc = t2.parentsscc 
        AND ts.ttnid = t2.ttnid 
        AND ts.sscc != ts.parentsscc 
        AND t2.sscc NOT IN (SELECT sscc FROM ttn_spec_sgtin WHERE sscc IS NOT NULL)
    WHERE t.id IN (SELECT TOP(3000) ttnid FROM ttn_sscc WHERE ttnid IS NOT NULL ORDER BY ttnid DESC)
),
RankedData AS (
    SELECT 
        sgtin, sgtin_ost, palet, paletost,
        sscc, sscc_ost, is_mismatch, kol_tov, kol_rezerv,
        ROW_NUMBER() OVER (PARTITION BY sscc ORDER BY is_mismatch DESC, sgtin) AS rn
    FROM BaseData
    WHERE is_mismatch = 1
),

-- Второй запрос
PaletBase AS (
    SELECT t.sscc palet, t2.sscc korob, t.ost p_ost, t2.ost k_ost
    FROM ttn_sscc t
    INNER JOIN ttn_sscc t2 ON t2.parentsscc = t.sscc 
        AND t.sscc = t.parentsscc 
        AND t2.sscc != t2.parentsscc 
        AND t.ttnid = t2.ttnid
        AND t.sscc IN (SELECT parentsscc FROM ttn_sscc WHERE parentsscc IS NOT NULL)
        AND t.sscc NOT IN (SELECT sscc FROM ttn_spec_sgtin WHERE sscc IS NOT NULL)
    WHERE t.ttnid IN (SELECT TOP(3000) ttnid FROM ttn_sscc WHERE ttnid IS NOT NULL ORDER BY ttnid DESC) --SELECT t.id FROM BaseData WHERE t.id IS NOT NULL
),
PaletMismatch AS (
    SELECT palet, korob, p_ost, k_ost,
        CASE WHEN k_ost = 2 AND p_ost != 1 THEN 1 ELSE 0 END AS mismatch
    FROM PaletBase
),
PaletRanked AS (
    SELECT palet, korob, p_ost, k_ost,
        ROW_NUMBER() OVER (PARTITION BY palet ORDER BY mismatch DESC, korob) rn
    FROM PaletMismatch
    WHERE mismatch = 1
)

-- Первый результат: проблемные sgtin/sscc
SELECT 
    sgtin,
    sgtin_ost AS ost_sgtin,
    sscc,
    sscc_ost AS ost_sscc,
    palet,
    paletost,
    'sgtin_mismatch' AS reason
FROM RankedData
WHERE rn = 1 
  AND sgtin NOT LIKE '%[^0-9A-Za-z]%' 
  AND len(sscc) = 18

UNION ALL

-- Второй результат: проблемные паллеты
SELECT 
    NULL AS sgtin,
    NULL AS ost_sgtin,
    korob AS sscc,
    k_ost AS ost_sscc,
    palet,
    p_ost AS paletost,
    'palet_mismatch' AS reason
FROM PaletRanked
WHERE rn = 1
  AND korob NOT IN (
      SELECT sscc FROM ttn_spec_sgtin 
      WHERE sscc IS NOT NULL 
      AND sgtin LIKE '%[^0-9A-Za-z]%'
  )

ORDER BY sscc, sgtin;