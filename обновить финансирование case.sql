UPDATE ttn
SET markSupplierFinancingSource = CASE 
    WHEN id IN (SELECT ttn_id FROM ttn_spec_sgtin WHERE sgtin IN ('sgtin1', 'sgtin2', 'sgtin3')) THEN 'значение1'
    WHEN id IN (SELECT ttn_id FROM ttn_spec_sgtin WHERE sgtin IN ('sgtin4', 'sgtin5', 'sgtin6')) THEN 'значение2'
    WHEN id IN (SELECT ttn_id FROM ttn_spec_sgtin WHERE sgtin IN ('sgtin7', 'sgtin8')) THEN 'значение3'
    ELSE markSupplierFinancingSource
END
WHERE id IN (
    SELECT ttn_id FROM ttn_spec_sgtin WHERE sgtin IN ('sgtin1', 'sgtin2', 'sgtin3', 'sgtin4', 'sgtin5', 'sgtin6', 'sgtin7', 'sgtin8')
);