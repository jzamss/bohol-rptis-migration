/* STRUCTURE */
delete from training_etracs255.structurematerial;
delete from training_etracs255.structure;



alter table rptis_talibon.m_building_components 
	add xobjid varchar(50)
;

update rptis_talibon.m_building_components set 
	xobjid = replace(bldg_components_desc, ' ', '')
;

insert ignore into training_etracs255.structure (
  objid,
  state,
  code,
  name,
  indexno,
  showinfaas
)
select 
  xobjid as objid,
  'APPROVED' as state,
  substring(bldg_components_desc, 1, 8) as code,
  bldg_components_desc as name,
  ifnull(order_no,100) as indexno,
  case 
		when bldg_components_desc = 'ROOF' then 1 
		when bldg_components_desc = 'FLOORING' then 1 
		when bldg_components_desc = 'WALL' then 1 
		else 0
	end as showinfaas
from rptis_talibon.m_building_components 
where length(trim(bldg_components_desc)) > 0
;


/* ADD xoid */
alter table rptis_talibon.d_bldg_floor 
	add xoid varchar(50)
;

create unique index ux_oid on rptis_talibon.d_bldg_floor (xoid)
;

update rptis_talibon.d_bldg_floor set xoid = null
;

update rptis_talibon.d_bldg_floor set 
  xoid = md5(concat(rand(),trans_stamp,trans_datetime))
;


insert into training_etracs255.bldgstructure (
  objid,
  bldgrpuid,
  structure_objid,
  material_objid,
  floor
)
select 
  xoid as objid,
  f.trans_stamp as bldgrpuid,
  c.xobjid as structure_objid,
  m.bldg_matls_desc as material_objid,
  case when f.floor_no REGEXP '[0-9]+' then f.floor_no else 1 end as floor
from 
	rptis_talibon.d_bldg_floor f,
	rptis_talibon.m_building_components c,
	rptis_talibon.m_building_materials m
where f.bldg_components_code = c.bldg_components_code
and f.bldg_matls_code = m.bldg_matls_code
and exists(select * from training_etracs255.bldgrpu where objid = f.trans_stamp)
;
