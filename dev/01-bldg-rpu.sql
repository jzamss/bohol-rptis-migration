insert into training_etracs255.bldgrpu (
  objid,
  landrpuid,
  permitno,
  permitdate,
  basevalue,
  dtcompleted,
  dtoccupied,
  floorcount,
  depreciation,
  depreciationvalue,
  totaladjustment,
  bldgage,
  percentcompleted,
  assesslevel,
  bldgclass,
  effectiveage,
  dtconstructed,
  occpermitno,
	condominium
)
select 
  b.trans_stamp as objid,
  null as landrpuid,
  b.bldg_permit as permitno,
  null as permitdate,
  0 as basevalue,
  case 
    when b.date_completed <= year(now()) and b.date_completed >= 1800
      then concat(b.date_completed, '-01-01') 
      else null
    end  as dtcompleted,
  case 
    when b.dtoccupied <= year(now()) and b.dtoccupied >= 1800
      then concat(b.dtoccupied, '-01-01') 
      else null
    end as dtoccupied,
  ifnull(b.no_of_storeys,1) as floorcount,
  0 as depreciation,
  0 as depreciationvalue,
  0 as totaladjustment,
  ifnull(b.bldg_age,0) as bldgage,
  100 as percentcompleted,
  0 as assesslevel,
  null as bldgclass,
  ifnull(b.bldg_age,0) as effectiveage,
  case 
    when b.dtconstructed <= year(now()) and b.dtconstructed >= 1800
      then concat(b.dtconstructed, '-01-01') 
      else null
    end as dtconstructed,
  null as occpermitno,
	0 as condominium
from 
	rptis_talibon.h_property_info p,
	rptis_talibon.h_bldg_gen_info b
where p.trans_stamp = b.trans_stamp 
and p.prop_type_code = 'B'
and exists(select * from rptis_talibon.p_ar where trans_stamp = p.trans_stamp)
;
