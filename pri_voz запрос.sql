SELECT        TOP (200) v.id, pv_type_id, pri_voz, pv_reason_id, nom, pv_num
  
  , v.create_date, pv_date, otr_date, apt_date, pa_id, agent_id, sklad_id, lpv_id, pvs_cnt, v.catalog_id, cez_zakaz_id, cez_zayav_svod_id, apt_vozvrat_id, 
                         doc_status_id, parus, otg_date, v.plat_id, gruzo_id, pku_type_id, opl_type_id, pv_svod_id, to_sklad_id, pv_reason_info, brak_file_id, otr_user_id, dogovor_id, zayav_id, zayav_type_id, note, parus_code, dlo_zayav_id, 
                         dlo_apt_vozvrat_id, transit, doing_date, modif_date, mark_doc_id, mark_sender_address_id, mark_reciever_address_id, mark_accept_date, is_mark, v.owner_id, calcSumType, molAgentId, mark_financing_item_id, 
                         mark_contract_type_id, AptekaWeb_ZagrDate, StoreWeb_ZagrDate, is_self_pickup
FROM            PRI_VOZ v 
WHERE        v.id IN ('3136560','3136513','3136500','3136406','3136326','3136200','3137499','3136380','3136374','3136361','3136345','3136336','3136296','3136290','3136228','3136224','3136419') 
--AND ID not  IN (SELECT DOCUMENTID FROM MARK_PROCESSING where documentid is not null and processingstatusid =3)
OR
                         (nom IN ('')) AND (pv_date LIKE '%2026%') 