with base as (
    SELECT         
        t.id, ttn_id, KOL_TOV, markAddressId as склад,
        receiverMarkAddressId as ттн, T.ttns_id, t.sgtin, t.sscc, gtin, seria, price,sc.ost krob,
        vatValue, t.tsd, t.accept, t.ost, mdlp_status, mdlp_status_date, 
        mdlp_status_check_counts, mdlp_good_status, inArchive, t.qrCode, expiration_date,
        row_number() over(partition by t.ttns_id order by t.sgtin) rn, -- одна ttns
        ROW_NUMBER() OVER (PARTITION BY t.ttn_id ORDER BY t.sgtin  desc) as sgtin_rn, --один на ттн
		 ROW_NUMBER() OVER (PARTITION BY t.sscc ORDER BY t.sgtin  desc) as ssc-- один sgtin на sscc 
    FROM TTN_SPEC_SGTIN t 
    inner join ttn on ttn.id = t.ttn_id 
    
    LEFT JOIN TOV_ZAP P ON P.TTNS_ID = T.TTNS_ID 
    left join s_sklads s on s.id = ttn.sklad_id left join ttn_sscc sc on sc.sscc = t.sscc and sc.ttnId=t.ttn_id
       -- Исключаем ненужный сгтин
	  where t.sscc  in ('076133260152091819')
	
)
select   ttn_id, KOL_TOV, склад,  ттн, ttns_id, sgtin, sscc, gtin, seria, 
       price, vatValue, tsd, accept, ost,krob, mdlp_status, mdlp_status_date, 
       mdlp_status_check_counts, mdlp_good_status, inArchive, qrCode, expiration_date
from base 
