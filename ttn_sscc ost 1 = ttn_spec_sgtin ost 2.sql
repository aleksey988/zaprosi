UPDATE ttn_spec_sgtin
SET ost = 2
FROM ttn_spec_sgtin
INNER JOIN ttn_sscc ON ttn_sscc.sscc = ttn_spec_sgtin.sscc
WHERE ttn_sscc.ost = 1;