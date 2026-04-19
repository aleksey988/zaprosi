UPDATE t
SET ost = CASE 
            WHEN p.sscc IS NULL THEN 1
            ELSE 2
          END
FROM ttn_spec_sgtin t
LEFT JOIN pri_voz_spec_sgtin p
       ON t.sgtin = p.sgtin
WHERE p.pvid IN ('список_pvid')

update ttn_sscc 
set ost = 1
where sscc in (select sscc from pri_voz_spec_sgtin where pvid in ('') and sscc is not null)