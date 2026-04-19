/* »справленна€ верси€: перенесен источник markDocumentId на таблицу mark_processing (m).
«апрос выводит строго одну строку на каждый уникальный markDocumentId.
*/

WITH UniqueDocs AS (
    SELECT 
        m2.id, 
        m2.sscc, 
        m2.ttnId, 
        m.createDate,
        m3.description,
        -- —корее всего, поле находитс€ в таблице m (mark_processing)
        m.markDocumentId,documentid,
        ROW_NUMBER() OVER (
            PARTITION BY m.markDocumentId 
            ORDER BY m.createDate DESC
        ) AS rn , ttn_sscc.ost
    FROM 
        TTN_SSCC_UNPACK_DOCUMENT m2 
    INNER JOIN 
        mark_processing m ON m.documentid = m2.id 
    INNER JOIN -- »спользуем INNER дл€ точности фильтрации по описанию
        mark_processing_description m3 ON m3.id = m.descriptionId INNER JOIN TTN_SSCC ON M2.SSCC = TTN_SSCC.SSCC inner join ttn_spec_sgtin t1 on t1.sscc = ttn_sscc.sscc 
    WHERE 
        
         m.markDocumentId IS NOT NULL AND ttn_sscc.OST = 1 and t1.ost =2
)
SELECT TOP (20002)
    id,
    sscc,
    ttnId,
    createDate,
    description,
    markDocumentId,documentid,ost
FROM 
    UniqueDocs
WHERE 
    rn = 1
ORDER BY 
    createDate DESC;