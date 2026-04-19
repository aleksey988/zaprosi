WITH SSCC_In_Spec AS (
    SELECT DISTINCT sscc
    FROM ttn_spec_sgtin
    WHERE sscc IS NOT NULL
),
AllInstances AS (
    SELECT t.sscc, t.ttnid, t.parentsscc
    FROM ttn_sscc t
    INNER JOIN SSCC_In_Spec s ON t.sscc = s.sscc
),
ParentUsage AS (
    SELECT DISTINCT 
        parentsscc AS sscc,
        ttnid
    FROM ttn_sscc
    WHERE parentsscc IS NOT NULL
),
Combined AS (
    SELECT 
        a.sscc,
        a.ttnid,
        a.parentsscc,
        CASE 
            WHEN pu.sscc IS NOT NULL THEN 1 
            ELSE 0 
        END AS is_parent_in_ttn
    FROM AllInstances a
    LEFT JOIN ParentUsage pu 
        ON a.sscc = pu.sscc AND a.ttnid = pu.ttnid
),
FilteredResults AS (
    SELECT c.sscc
    FROM Combined c
    GROUP BY c.sscc
    HAVING 
        SUM(c.is_parent_in_ttn) > 0
        AND SUM(1 - c.is_parent_in_ttn) > 0
),
-- Где sscc был проставлен (is_parent_in_ttn = 1) — берём его ttnid
ProvenTTN AS (
    SELECT c.sscc, c.ttnid AS proven_ttnid
    FROM Combined c
    WHERE c.is_parent_in_ttn = 1
)

-- Часть 1: Паллеты с несколькими ТТН
SELECT 
    t.sscc, 
    t.ttnId,
    NULL AS parentsscc,
    NULL AS proven_ttnid,
    'Паллет в нескольких ТТН' AS reason
FROM ttn_sscc t
INNER JOIN ttn_spec t1 ON t.ttnid = t1.ttn_id
INNER JOIN tov_zap z 
    ON z.ttns_id = t1.id 
    AND z.kol_tov != 0 
    AND z.ttns_id != 0
WHERE t.sscc = t.parentsscc
  AND t.sscc NOT IN (
      SELECT sscc FROM ttn_spec_sgtin WHERE sscc IS NOT NULL
  )
  AND t.sscc IN (
      SELECT sscc
      FROM ttn_sscc
      WHERE sscc = parentsscc
      GROUP BY sscc
      HAVING COUNT(DISTINCT ttnId) > 1
  )

UNION ALL

-- Часть 2: Непроставленные короба + parentsscc где был проставлен
SELECT DISTINCT
    c.sscc,
    c.ttnid,
    c.parentsscc,                  -- parentsscc в этом ttnid (не проставлен)
    p.proven_ttnid,                -- ttnid где этот sscc был проставлен
    'Непроставленный короб' AS reason
FROM Combined c
INNER JOIN FilteredResults fr ON c.sscc = fr.sscc
INNER JOIN ttn_spec t1 ON c.ttnid = t1.ttn_id
INNER JOIN tov_zap z 
    ON z.ttns_id = t1.id 
    AND z.kol_tov != 0
    AND z.ttns_id != 0
LEFT JOIN ProvenTTN p ON c.sscc = p.sscc   -- подтягиваем ttnid где был проставлен
WHERE c.parentsscc IS NOT NULL 
  AND c.parentsscc <> c.sscc
  AND c.is_parent_in_ttn = 0               -- показываем только непроставленные строки