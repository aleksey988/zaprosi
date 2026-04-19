INSERT INTO ttn_spec_sgtin (
    ttn_id, ttns_id, sgtin, sscc, gtin, seria, 
    price, vatValue, tsd, accept, ost, 
    mdlp_status, mdlp_status_date, mdlp_status_check_counts, 
    mdlp_good_status, inArchive, qrCode, expiration_date
)
SELECT 
    a.ttn_id, a.ttns_id, a.sgtin, a.sscc, a.gtin, a.seria, 
    a.price, a.vatValue, a.tsd, a.accept, a.ost, 
    a.mdlp_status, a.mdlp_status_date, a.mdlp_status_check_counts, 
    a.mdlp_good_status, 0, a.qrCode, a.expiration_date
FROM ttn_spec_sgtin_archive a
WHERE a.sgtin IN ('070383191605211008039475509')
-- Безопасность: не вставляем, если в основной таблице уже есть такой ID или SGTIN
AND NOT EXISTS (
    SELECT 1 FROM ttn_spec_sgtin m 
    WHERE m.sgtin = a.sgtin 
    
);