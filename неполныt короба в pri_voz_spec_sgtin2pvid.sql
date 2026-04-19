SELECT DISTINCT
    t.sgtin,
    t.sscc,
    pv.pv_num,
    pvs.pvid
FROM ttn_spec_sgtin t
INNER JOIN pri_voz_spec_sgtin pvs ON pvs.sscc = t.sscc  -- Короб есть в приходе
LEFT JOIN pri_voz_spec_sgtin pvs2 ON pvs2.sgtin = t.sgtin AND pvs2.pvid = pvs.pvid  -- Но SGTIN не отсканирован
LEFT JOIN pri_voz pv ON pv.id = pvs.pvid
WHERE pvs.pvid IN ('1057796')  -- ? Подставьте свой pvid
  AND pvs2.sgtin IS NULL  -- SGTIN отсутствует в приходе
  AND t.sscc IS NOT NULL
ORDER BY t.sscc, t.sgtin;