WITH AggregatedData AS (
    -- Шаг 1: Исходная логика запроса, включая объединения и фильтрацию.
    -- TOP(20000) и ORDER BY пока опущены.
    SELECT
        PV_SSCC.sscc,
        PV_SSCC.parentsscc,
        PV_SSCC.tsd,
        PV_SSCC.pvid,
        PV.pv_num,
        MIN(TS.ocena_nds) AS ocena_nds,
        MIN(TS.pnds) AS pnds,
        MIN(TSG.sgtin) AS sgtin,
        
        -- Оконные функции для подсчета
        COUNT(PV_SSCC.sscc) OVER() AS total_sscc_count,
        COUNT(PV_SSCC.sscc) OVER(PARTITION BY PV_SSCC.pvid) AS pvid_sscc_count
    FROM 
        PRI_VOZ_SSCC AS PV_SSCC
    INNER JOIN 
        PRI_VOZ AS PV ON PV.id = PV_SSCC.pvid
    LEFT JOIN 
        TTN_SPEC_SGTIN AS TSG ON TSG.SSCC = PV_SSCC.SSCC
    LEFT JOIN 
        TTN_SPEC AS TS ON TSG.ttns_id = TS.id
    WHERE
        PV_SSCC.pvid IN ('3048840')
        OR PV_SSCC.sscc IN ('')
    GROUP BY
        PV_SSCC.sscc, 
        PV_SSCC.parentsscc, 
        PV_SSCC.tsd, 
        PV_SSCC.pvid,
        PV.pv_num
),
RankedData AS (
    -- Шаг 2: Определяем, какая строка является "первой" для каждого PVID.
    SELECT
        *,
        -- pvid_rn = 1 будет для первой строки в каждой группе PVID (сортируем по sscc для детерминированности)
        ROW_NUMBER() OVER (PARTITION BY pvid ORDER BY sscc) AS pvid_rn
    FROM AggregatedData
)
-- Шаг 3: Финальный вывод с приоритетной сортировкой.
SELECT TOP(20000)
    sscc,
    parentsscc,
    tsd,
    pvid,
    pv_num,
    ocena_nds,
    pnds,
    sgtin,
    total_sscc_count,
    pvid_sscc_count
FROM RankedData
ORDER BY
    -- Приоритет 1: Строки с pvid_rn = 1 идут первыми (0 < 1). 
    -- Это обеспечивает показ одного SSCC для каждого PVID в начале выборки.
    CASE WHEN pvid_rn = 1 THEN 0 ELSE 1 END,
    
    -- Приоритет 2: Сортируем по PVID, чтобы сгруппировать все остальные строки.
    pvid,
    
    -- Приоритет 3: Сортируем по SSCC внутри PVID.
    sscc;