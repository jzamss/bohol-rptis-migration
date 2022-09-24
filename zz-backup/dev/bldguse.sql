/* BLDG USE  */

-- ADD xstructureid
alter table rptis_talibon.h_bldg_floor 
	add xstructureid varchar(50)
;

update 
	rptis_talibon.h_bldg_floor f, 
	training_etracs255.bldgrpu_structuraltype x
set 
	f.xstructureid = x.objid 
where f.trans_stamp = x.bldgrpuid
;


-- ADD xactualuseid 
alter table rptis_talibon.h_bldg_floor 
	add xactualuseid varchar(50)
;

update 
	rptis_talibon.h_bldg_floor f, 
	training_etracs255.bldgassesslevel x
set 
	f.xactualuseid = x.objid 
where f.actual_use = x.code 
	and f.class_code = x.classification_objid
;



alter table training_etracs255.bldguse 
	modify column actualuse_objid varchar(50) null 
;




insert into training_etracs255.bldguse (
  objid,
  bldgrpuid,
  structuraltype_objid,
  actualuse_objid,
  basevalue,
  area,
  basemarketvalue,
  depreciationvalue,
  adjustment,
  marketvalue,
  assesslevel,
  assessedvalue,
  addlinfo,
  adjfordepreciation,
  taxable
)
select
  f.xoid as objid,
  f.trans_stamp as bldgrpuid,
  f.xstructureid as structuraltype_objid,
  f.xactualuseid as actualuse_objid,
  f.amount / f.area as basevalue,
  f.area,
  f.amount as basemarketvalue,
  0 as depreciationvalue,
  0 as adjustment,
  f.amount as marketvalue,
  0 as assesslevel,
  0  as assessedvalue,
  null as addlinfo,
  0 as adjfordepreciation,
  1 as taxable
from rptis_talibon.h_bldg_floor f
where exists(select * from training_etracs255.bldgrpu where objid = f.trans_stamp)
;

