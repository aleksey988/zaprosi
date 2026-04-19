with base as (SELECT pp_code,
    tss.sscc,
    tss.parentsscc,
    tss.ost,row_number()over(partition by pp_code order by tss.sscc) rn ,sgtin
FROM post_parties pp
INNER JOIN ttn t
    ON t.p_party_id = pp.id
INNER JOIN ttn_sscc tss
    ON tss.ttnid = t.id inner join ttn_spec_sgtin tt on tt.sscc = tss.sscc and tt.ttn_id = tss.ttnid
WHERE pp.pp_code in ('26-2605', '26-2623', '26-3016', '26-3035', '26-3091', '26-3154')
) select pp_code,sscc,sgtin,parentsscc,ost from base where rn in (1,2)
order by pp_code ;
 with base2 as ( select pp_code,sgtin,ost,row_number()over(partition by pp_code order by sgtin) n from post_parties p
inner join ttn t 
on t.p_party_id = p.id
inner join ttn_spec_sgtin s on s.ttn_id = t.id and s.sscc is null
where pp_code in ('26-2605', '26-2623', '26-3016', '26-3035', '26-3091', '26-3154'))
select pp_code,sgtin,ost from base2 where n in (1,2)
order by pp_code
