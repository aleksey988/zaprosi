with base as (SELECT t.sscc, t.ttnId
FROM ttn_sscc t
INNER JOIN ttn_spec t1 ON t.ttnid = t1.ttn_id
INNER JOIN tov_zap z 
    ON z.ttns_id = t1.id 
    AND z.kol_tov != 0 
    AND z.ttns_id != 0
WHERE t.sscc = t.parentsscc
  AND t.sscc NOT IN (
      SELECT sscc 
      FROM ttn_spec_sgtin 
      WHERE sscc IS NOT NULL
  )
  )
  select base.sscc,base.ttnid from base
  where base.ttnid not in (select ttnid from ttn_sscc where base.sscc in (select parentsscc from ttn_sscc where parentsscc!=sscc and parentsscc is not null) and ttnid is not null)