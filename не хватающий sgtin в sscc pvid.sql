WITH t_unique AS (
    SELECT DISTINCT
        p.pvid,
        p.sscc,
        t.sgtin
    FROM pri_voz_spec_sgtin p
    CROSS APPLY (
        SELECT sgtin
        FROM ttn_spec_sgtin
        WHERE sscc = p.sscc
          AND sgtin != p.sgtin
    ) t
    WHERE p.pvid in('1039839')
)
SELECT
    pvid,
    sscc,
    STRING_AGG(sgtin, CHAR(13) + CHAR(10)) AS missing_sgtins
FROM t_unique
GROUP BY pvid, sscc;