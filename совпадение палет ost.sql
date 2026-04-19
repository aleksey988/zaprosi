with base as (select t.sscc palet,t2.sscc korob,t.ost p_ost,t2.ost k_ost from ttn_sscc t
inner join ttn_sscc t2 on t2.parentsscc = t.sscc and t.sscc =t.parentsscc and t2.sscc!=t2.parentsscc and t.ttnid =t2.ttnid
and t.sscc in (select parentsscc from ttn_sscc where parentsscc is not null)
and t.sscc not in (select sscc from ttn_spec_sgtin where sscc is not null) 
where t.ttnid in ('263026','263060','263022','263075','263063','263032','263031','262960','263017','263016','263052','263030','263021','263041','263085','263037','263001','263029','263004','263046','263023','263091','263035','263042','263018'))
,base2 as(
select palet,korob,p_ost,k_ost, case when k_ost =2 and p_ost !=1 then 1 when K_ost =1 and p_ost=1 then 1 else 0 end as mismatch from base),
base3 as (
select palet,korob,p_ost,k_ost ,
row_number()over(partition by palet order by mismatch desc,korob) rn
from base2
where mismatch = 1)
select palet,korob,p_ost,k_ost from base3
where rn=1 and korob not in (select sscc from ttn_spec_sgtin where sscc is not null and sgtin like '%[^0-9A-Za-z]%')


