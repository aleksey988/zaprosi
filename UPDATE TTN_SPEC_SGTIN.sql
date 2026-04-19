update       TTN_SPEC_SGTIN
set ost = 1
WHERE        (sgtin in (''))

UPDATE TTN_SSCC
SET ost = 0
FROM TTN_SSCC
INNER JOIN TTN_SPEC_SGTIN
    ON TTN_SPEC_SGTIN.sscc = TTN_SSCC.sscc
	WHERE SGTIN IN ('')

	update pri_voz_spec_sgtin
	set tsd = 2 
	where sgtin in ('')
	