-- Запрос без столбца id (автоматическое присвоение)
INSERT INTO ttn_spec_sgtin (
    ttn_id, 
    ttns_id, 
    sgtin, 
    sscc, 
    gtin, 
    seria, 
    price, 
    vatValue, 
    tsd, 
    accept, 
    ost, 
    mdlp_status, 
    mdlp_status_date, 
    mdlp_status_check_counts, 
    mdlp_good_status, 
    inArchive, 
    qrCode, 
    expiration_date
) 
VALUES 
(208789, 1949982, '0467001246100510512B6PBE791', '146700124603070463', NULL, 1, NULL, NULL, 1, 1, 0, 'in_circulation', '1900-01-01', 3, 0, 0, NULL, NULL),
(208789, 1949982, '04670012461005105154BA5654M', '146700124603070463', NULL, 1, NULL, NULL, 1, 1, 0, 'in_circulation', '1900-01-01', 3, 0, 0, NULL, NULL),
(208789, 1949982, '0467001246100510515HE289PHA', '146700124603070463', NULL, 1, NULL, NULL, 1, 1, 0, 'in_circulation', '1900-01-01', 3, 0, 0, NULL, NULL),
(208789, 1949982, '0467001246100510528MAMCCE25', '146700124603070463', NULL, 1, NULL, NULL, 1, 1, 0, 'in_circulation', '1900-01-01', 3, 0, 0, NULL, NULL),
(208789, 1949982, '046700124610051052K9041CEBH', '146700124603070463', NULL, 1, NULL, NULL, 1, 1, 0, 'in_circulation', '1900-01-01', 3, 0, 0, NULL, NULL),
(208789, 1949982, '046700124610051052T18TPAMMH', '146700124603070463', NULL, 1, NULL, NULL, 1, 1, 0, 'in_circulation', '1900-01-01', 3, 0, 0, NULL, NULL);