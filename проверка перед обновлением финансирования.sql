WITH SGTIN_Pool AS (
    -- Шаг 1: Находим SGTIN, которые есть в >= 2 ТТН и имеют источник 2 или 3
    SELECT 
        ts.sgtin,
        MAX(t.markSupplierFinancingSource) AS reference_fin_source
    FROM TTN_SPEC_SGTIN ts
    JOIN TTN t ON ts.ttn_id = t.id
    GROUP BY ts.sgtin
    HAVING COUNT(DISTINCT ts.ttn_id) > 1 
       AND MAX(t.markSupplierFinancingSource) IN (2, 3)
),
Target_Documents AS (
    -- Шаг 2: Находим ТТН, требующие обновления (где источник не совпадает с эталонным)
    SELECT DISTINCT
        t.id AS ttn_id,
        t.markSupplierFinancingSource AS current_value,
        pool.reference_fin_source AS projected_value,
        target_sgtin.sgtin AS linked_sgtin
    FROM TTN t
    CROSS APPLY (
        SELECT TOP 1 ts_inner.sgtin
        FROM TTN_SPEC_SGTIN ts_inner
        JOIN SGTIN_Pool p ON ts_inner.sgtin = p.sgtin
        WHERE ts_inner.ttn_id = t.id 
          AND ts_inner.ost = 1
    ) AS target_sgtin
    JOIN SGTIN_Pool pool ON target_sgtin.sgtin = pool.sgtin
    WHERE (t.markSupplierFinancingSource IS NULL 
        OR t.markSupplierFinancingSource != pool.reference_fin_source)
)
-- Шаг 3: Выводим целевые ТТН и информацию обо всех остальных ТТН, связанных через этот SGTIN
SELECT TOP (20000)
    td.ttn_id,
    td.current_value,
    td.projected_value,
    td.linked_sgtin,
    -- Список всех ТТН, в которых встречается данный SGTIN (ID и их текущий Источник)
    (
        SELECT STRING_AGG(CAST(all_t.id AS VARCHAR) + ' (src:' + ISNULL(CAST(all_t.markSupplierFinancingSource AS VARCHAR), 'NULL') + ')', '; ')
        FROM TTN_SPEC_SGTIN all_ts
        JOIN TTN all_t ON all_ts.ttn_id = all_t.id
        WHERE all_ts.sgtin = td.linked_sgtin
    ) AS all_related_ttns_with_sources
FROM Target_Documents td
ORDER BY td.projected_value DESC, td.ttn_id;