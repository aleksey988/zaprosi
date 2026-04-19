WITH UniqueData AS (
    -- Шаг 1: Формируем базовый набор данных с необходимыми джоинами
    SELECT DISTINCT
        pri_voz_spec_sgtin.SGTIN,pri_voz_spec_sgtin.id as id,
        pri_voz_spec_sgtin.sscc,
        pri_voz_spec_sgtin.tsd,
        pri_voz_spec_sgtin.pvid,
        pri_voz.pv_num,
        TTN_SPEC_SGTIN.sgtin AS ttn_sgtin,
        -- Флаг для сортировки (сначала те, что есть в ТТН)
        CASE 
            WHEN TTN_SPEC_SGTIN.sgtin IS NULL THEN pri_voz_spec_sgtin.sgtin 
            ELSE NULL 
        END AS sort_nulls,
        -- Вспомогательное поле для подсчета SGTIN без коробов
        CASE 
            WHEN pri_voz_spec_sgtin.sscc IS NULL THEN pri_voz_spec_sgtin.sgtin 
            ELSE NULL 
        END AS sgtin_notnull
       
    FROM pri_voz_spec_sgtin
    INNER JOIN pri_voz 
        ON pri_voz.id = pri_voz_spec_sgtin.pvid 
    LEFT JOIN TTN_SPEC_SGTIN 
        ON TTN_SPEC_SGTIN.SGTIN = pri_voz_spec_sgtin.SGTIN
    LEFT JOIN TTN_SSCC 
        ON TTN_SSCC.SSCC = TTN_SPEC_SGTIN.SSCC 
    WHERE 
        pri_voz_spec_sgtin.pvid IN ('3118996','3126247','3126405','3126113','3126319','3126640','3126208','3126359','3126861','3126154','3126329','3126833') 
          and pri_voz_spec_sgtin.sgtin not like '%[^0-9A-Za-z]%'
        AND pri_voz_spec_sgtin.sgtin <> '046004880052433108310723901' 
),
MarkedUnique AS (
    -- Шаг 2: Идентифицируем уникальные SSCC внутри каждой группы pvid
    -- ROW_NUMBER присвоит 1 только одной строке для каждого уникального номера короба
    SELECT 
        *,
        (select count(distinct sscc) from pri_voz_spec_sgtin s where s.pvid = UniqueData.pvid ) as ssccount,
		(select count(distinct sgtin) from pri_voz_spec_sgtin s where s.pvid = uniquedata.pvid and sscc is null) as sgtincount,
		(Select count (distinct sscc) from Pri_voz_sscc a where a.pvid = UniqueData.pvid ) sscc2
		
         
    FROM UniqueData  

)
-- Шаг 3: Итоговый расчет агрегатов через оконные функции
SELECT 
    SGTIN,ssccount,sgtincount,sscc2,
    sscc,
    tsd,
    pvid,
    pv_num, 
    sort_nulls,id,
    -- Порядковый номер строки внутри документа
    ROW_NUMBER() OVER (PARTITION BY pvid ORDER BY SGTIN) as rn
    -- Общее количество SGTIN, у которых нет SSCC
    
    -- Сумма флагов первых вхождений дает точное количество уникальных коробов
    
FROM MarkedUnique
ORDER BY 
    sort_nulls DESC, 
    rn ASC, 
    ttn_sgtin;