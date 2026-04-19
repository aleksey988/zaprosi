SELECT        TOP (20000) m2.id, m2.documentId, m2.markDocumentId, m2.markActionId, m2.createDate, m2.processingStatusId, m2.plannedItemsFile, m2.descriptionId, m2.artisUserId
FROM            MARK_PROCESSING AS m2 INNER JOIN
                         MARK_PROCESSING_DESCRIPTION AS m1 ON m1.id = m2.descriptionId
WHERE        (m1.Description LIKE '%вложенным%') AND (m2.createDate >= '2025-10-01 10:00:00')
ORDER BY m2.createDate DESC