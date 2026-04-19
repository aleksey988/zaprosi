UPDATE ttn_sscc 
SET ost = 1 
WHERE sscc IN (
    -- Найти все SSCC где parentsscc = указанным палетам
    SELECT DISTINCT sscc 
    FROM ttn_sscc 
    WHERE parentsscc IN ('146024001', '146024002', '146024003')
) 
-- НО исключить сами палеты
AND sscc NOT IN ('146024001', '146024002', '146024003') and ost = 2

update ttn_sscc
set ost = 0 
where sscc in ()