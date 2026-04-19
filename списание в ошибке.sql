WITH RankedDocuments AS (
    SELECT 
        mp.markDocumentId, 
        mp.markActionId, 
        mp.createDate, 
        mp.processingStatusId, 
        mp.plannedItemsFile, 
        mp.descriptionId, 
        mp.artisUserId,
        mp.documentid,
        -- Нумеруем строки для каждого документа, учитывая оба типа действий
        ROW_NUMBER() OVER (
            PARTITION BY mp.documentid 
            ORDER BY mp.createDate DESC
        ) as RN
    FROM mark_processing mp
    WHERE 
        -- Добавлено условие для выбора обоих типов действий
        mp.markActionId IN (8, 14)
        AND mp.createDate >= '2026-01-01 16:09:56.823'
        AND mp.createDate <= GETDATE()
)
SELECT 
    markDocumentId, 
    markActionId, 
    createDate, 
    processingStatusId, 
    plannedItemsFile, 
    descriptionId, 
    artisUserId,
    documentid
FROM RankedDocuments
WHERE 
    -- Выбираем только самую свежую запись по конкретному документу
    RN = 1 
    -- Проверяем статус именно этой последней записи
    -- Если статус 3, условие не пройдет и документ не отобразится
    AND processingStatusId IN (2, 4)
ORDER BY createDate DESC;