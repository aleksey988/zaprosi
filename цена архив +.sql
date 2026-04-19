-- 1️⃣ CTE с пропущенными sgtin
WITH missing AS (
    SELECT 
        p.pvid, 
        p.sscc, 
        t.sgtin AS missing_sgtin
    FROM ttn_spec_sgtin t
    INNER JOIN pri_voz_spec_sgtin p ON t.sscc = p.sscc
    WHERE NOT EXISTS (
        SELECT 1
        FROM pri_voz_spec_sgtin p2
        WHERE p2.sgtin = t.sgtin
          AND p2.pvid = p.pvid
    )
)  -- ← Убрали запятую!

-- 2️⃣ Агрегируем уникальные пропущенные sgtin по (pvid, sscc)
, MissingAgg AS (  -- ← Запятая ПЕРЕД новым CTE!
    SELECT
        pvid,
        sscc,
        STRING_AGG(missing_sgtin, ', ') AS missing_in_box
    FROM (
        SELECT DISTINCT pvid, sscc, missing_sgtin
        FROM missing
    ) m
    GROUP BY pvid, sscc
)  -- ← Убрали запятую!

-- 3️⃣ BaseData с основной информацией
, BaseData AS (  -- ← Запятая ПЕРЕД новым CTE!
    SELECT
        pv.pv_num,
        pvs.pvid,
        CASE WHEN pvs.sscc IS NULL THEN pvs.sgtin END AS sgtin_null_sscc,
        pvs.sscc AS sscc_raw,
        pvs_sscc.sscc AS pri_voz_sscc_raw,
        CASE WHEN tss.sgtin IS NULL THEN pvs.sgtin END AS net_v_ttn,
        CASE WHEN pvs.sscc IS NULL AND pvs_sscc.sscc IS NULL THEN COALESCE(tss.sscc, tssa.sscc) END AS sscc_rasform,
        COALESCE(ttncur.markSupplierFinancingSource, ttnarc.markSupplierFinancingSource) AS financing_source,
        COALESCE(ttncur.markAcceptType, ttnarc.markAcceptType) AS accept_type,
        COALESCE(ttncur.markSupplierContractType, ttnarc.markSupplierContractType) AS contract_type,
        CASE WHEN pvs.sscc IS NULL THEN COALESCE(ts_cur.ocena_nds, ts_arc.ocena_nds) END AS ocena_nds_sgtin,
        CASE WHEN pvs.sscc IS NOT NULL AND pvs_sscc.sscc IS NOT NULL THEN pvs.sgtin END AS sgtinkorob,
        CASE WHEN pvs.sscc IS NULL THEN COALESCE(ts_cur.pnds, ts_arc.pnds) END AS pnds_sgtin,
        CASE WHEN pvs.sscc IS NOT NULL THEN COALESCE(ts_cur.ocena_nds, ts_arc.ocena_nds) END AS ocena_nds_sscc,
        CASE WHEN pvs.sscc IS NOT NULL THEN COALESCE(ts_cur.pnds, ts_arc.pnds) END AS pnds_sscc
    FROM PRI_VOZ_SPEC_SGTIN pvs
    LEFT JOIN PRI_VOZ pv ON pv.id = pvs.pvid
    LEFT JOIN PRI_VOZ_SSCC pvs_sscc ON pvs_sscc.pvid = pvs.pvid
    LEFT JOIN TTN_SPEC_SGTIN tss ON tss.sgtin = pvs.sgtin
    LEFT JOIN TTN_SPEC ts_cur ON ts_cur.id = tss.ttns_id
    LEFT JOIN TTN ttncur ON ttncur.id = tss.ttn_id
    LEFT JOIN TTN_SPEC_SGTIN_ARCHIVE tssa ON tssa.sgtin = pvs.sgtin
    LEFT JOIN TTN_SPEC ts_arc ON ts_arc.id = tssa.ttns_id
    LEFT JOIN TTN ttnarc ON ttnarc.id = tssa.ttn_id
    WHERE pvs.pvid IN ('3123559','3125449','3124517','3124687','3123218','3125294') 
      AND pv.pv_num <> 'Ап/21-291402'
      AND pvs.sgtin <> '046004880052433108310723901'
)  -- ← Убрали запятую!

-- 4️⃣ Статистика по pvid
, StatsByPvid AS (  -- ← Запятая ПЕРЕД новым CTE!
    SELECT
        pvid,
        COUNT(DISTINCT CASE WHEN sscc IS NULL THEN sgtin END) AS unique_sgtin_count,
        (SELECT COUNT(DISTINCT sscc) FROM PRI_VOZ_SSCC s WHERE s.pvid = pvs.pvid) AS total_sscc_in_pvid,
        (SELECT COUNT(DISTINCT sscc) FROM PRI_VOZ_SPEC_SGTIN s WHERE s.pvid = pvs.pvid AND s.sscc IS NOT NULL) AS unique_pri_voz_spe
    FROM PRI_VOZ_SPEC_SGTIN pvs
    GROUP BY pvid
)  -- ← Убрали запятую!

-- 5️⃣ Агрегированные результаты
, AggregatedResults AS (  -- ← Запятая ПЕРЕД новым CTE!
    SELECT
        pv_num,
        pvid,
        sgtinkorob,
        sgtin_null_sscc AS sgtin_only,
        sscc_raw AS sscc_only,
        MAX(sscc_rasform) AS sscc_rasform,
        MAX(net_v_ttn) AS net_v_ttn,
        MAX(ocena_nds_sgtin) AS ocena_nds_for_sgtin,
        MAX(pnds_sgtin) AS pnds_for_sgtin,
        MAX(ocena_nds_sscc) AS ocena_nds_for_sscc,
        MAX(pnds_sscc) AS pnds_for_sscc,
        MAX(financing_source) AS finance,
        MAX(accept_type) AS accept_type,
        MAX(contract_type) AS contracttype
    FROM BaseData
    GROUP BY
        pvid,
        pv_num,
        sgtin_null_sscc,
        sscc_raw,
        sgtinkorob
)  -- ← ПОСЛЕДНЯЯ запятая убрана!

-- 6️⃣ Финальный SELECT
SELECT
    ar.*,
    ma.missing_in_box,
    ROW_NUMBER() OVER (PARTITION BY ar.pvid ORDER BY ar.sgtin_only, ar.sscc_only) AS rn,
    COALESCE(st.unique_sgtin_count, 0) AS total_sgtin_in_pvid,
    COALESCE(st.total_sscc_in_pvid, 0) AS total_sscc_in_pvid,
    COALESCE(st.unique_pri_voz_spe, 0) AS unique_pri_voz_spe
FROM AggregatedResults ar
LEFT JOIN StatsByPvid st ON st.pvid = ar.pvid
LEFT JOIN MissingAgg ma 
    ON ma.pvid = ar.pvid
   AND ma.sscc = ar.sscc_only
ORDER BY ar.net_v_ttn DESC, rn;