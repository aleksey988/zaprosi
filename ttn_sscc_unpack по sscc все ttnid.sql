/* Запрос находит ttnId для заданного SSCC, 
а затем выводит ВСЕ SSCC, которые привязаны к этому же ttnId.
*/

SELECT TOP (20002) 
    id, 
    sscc, 
    ttnId, 
    createDate
FROM 
    TTN_SSCC_UNPACK_DOCUMENT
WHERE 
    ttnId IN (
        -- Находим ttnId, связанные с вашим списком SSCC
        SELECT ttnId 
        FROM TTN_SSCC_UNPACK_DOCUMENT 
        WHERE sscc IN ('146063670077073586', '146063670080988938') 
    )
ORDER BY 
    ttnId, createDate;