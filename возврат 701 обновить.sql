update ttn_spec_sgtin 
set ost = 1,--reserved = 0 --если ost 0 reserved 0
where sscc in ('046027890014502375062418767','046027890014508845182455243','046027890028083032457376565','046027890028083052250780950','046027890028083383184436108','046027890028087988617937742')




UPDATE TTN_SSCC
SET ost = 0,--reserved=0
FROM TTN_SSCC
where sscc in ('146601536547927688','146601536547927695','146601536547927732')

update ttn-sscc
set ost = 
where

--update ttn_spec_sgtin 
--set ost = 1
--mdlp_status = 'out_of_circulation'

	
	