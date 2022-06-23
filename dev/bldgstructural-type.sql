/* BLDG STRUCTURAL TYPE */
/* ADD xoid */
alter table rptis_talibon.h_bldg_floor 
	add xoid varchar(50)
;

create unique index ux_oid on rptis_talibon.h_bldg_floor (xoid)
;

update rptis_talibon.h_bldg_floor set 
  xoid = md5(concat(rand(),trans_stamp,trans_datetime))
;


insert into training_etracs255.bldgrpu_structuraltype (
  objid,
  bldgrpuid,
  bldgtype_objid,
  bldgkindbucc_objid,
  floorcount,
  basefloorarea,
  totalfloorarea,
  basevalue,
  unitvalue,
  classification_objid
)
select
  min(xoid) as objid,
  f.trans_stamp as bldgrpuid,
  bt.xobjid as bldgtype_objid,
  bucc.xobjid as bldgkindbucc_objid,
  0 as floorcount,
  0 as basefloorarea,
  0 as totalfloorarea,
  0 as basevalue,
  0 as unitvalue,
  'R' as classification_objid
from rptis_talibon.h_bldg_floor f,
	rptis_talibon.m_building_structure_type bt,
	rptis_talibon.m_building_kinds bk,
	rptis_talibon.m_sched_bldg_cost bucc
where f.struc_code = bt.struc_code
and f.bldg_kind_code = bk.bldg_kind_code
and f.struc_code = bt.struc_code
and bucc.struc_code = f.struc_code
and bucc.bldg_class_code = f.bldg_class_code
and bucc.bldg_kind_code = bk.bldg_kind_code
and exists(select * from training_etracs255.bldgrpu where objid = f.trans_stamp)
group by 
	f.trans_stamp,
  bt.xobjid,
  bucc.xobjid
;


