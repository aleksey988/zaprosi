with params as (select id as pvid from pri_voz where id in ('2994358')),
sscc_specs as (select distinct pvs.pvid,pvs.sscc from pri_voz_spec_sgtin pvs 
join params p on p.pvid = pvs.pvid where pvs.sscc is not null),
sscc_hds as (select pvh.pvid,pvh.sscc from PRI_VOZ_SSCC pvh
join params p on p.pvid = pvh.pvid where pvh.sscc is not null)
select coalesce (s1.pvid,s2.pvid) as pvid,
 coalesce (s1.sscc , s2.sscc) as sscc,
case when s1.sscc is null then 'нет спек сгитин' 
 when s2.sscc is null then 'нет в привоз' end
from sscc_specs s1 full outer join sscc_hds s2 on s1.pvid = s2.pvid
and s1.sscc = s2.sscc
where s1.sscc is null or s2.sscc is null
