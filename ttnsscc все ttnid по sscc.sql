SELECT        id, ttnId, sscc, parentSscc, tsd, accept, ost, temporalTtnSpecId
FROM            TTN_SSCC
WHERE        (ttnId IN
                             (SELECT        ttnId
                               FROM            TTN_SSCC AS TTN_SSCC_1
                               WHERE        (sscc IN ('146037799929840727', '146037799929849812', '146037799929854243', '146037799929867427', '146037799929872292', '146037799929885506'))) and ost = 1)