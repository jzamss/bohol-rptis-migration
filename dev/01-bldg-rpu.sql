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
  concat(b.date_completed, '-01-01') as dtcompleted,
  concat(b.date_occupied, '-01-01') as dtoccupied,
  ifnull(b.no_of_storeys,1) as floorcount,
  0 as depreciation,
  0 as depreciationvalue,
  0 as totaladjustment,
  ifnull(b.bldg_age,0) as bldgage,
  100 as percentcompleted,
  0 as assesslevel,
  null as bldgclass,
  ifnull(b.bldg_age,0) as effectiveage,
  concat(b.date_constructed, '-01-01') as dtconstructed,
  null as occpermitno,
	0 as condominium
from 
	rptis_talibon.h_property_info p,
	rptis_talibon.h_bldg_gen_info b
where p.trans_stamp = b.trans_stamp 
and p.prop_type_code = 'B'
and exists(select * from rptis_talibon.p_ar where trans_stamp = p.trans_stamp)
;
