/*=====================================================================
* STEPS:
*    1. REPLACE ALL instances of "training_etracs255" with 
*       the actual ETRACS db name
*    2. REPLACE ALL instances of "rptis." with the actual RPTIS Database
*       Name such as "rptis_talibon."
*    3. Copy to Navicat and Execute ALL script by pressing CTRL + R

IMPORTANT !!!  
    PLEASE SET BEFORE EXECUTING:
      @revisionyear
      @municipalcode
      @municlass

======================================================================*/

set @revisionyear = 2016;
set @municipalcode = 42;
set @municlass = '1ST';


insert into training_etracs255.landrpu (
  objid,
  idleland,
  totallandbmv,
  totallandmv,
  totallandav,
  totalplanttreebmv,
  totalplanttreemv,
  totalplanttreeadjustment,
  totalplanttreeav,
  landvalueadjustment,
  publicland,
  distanceawr,
  distanceltc
)
select distinct 
  p.trans_stamp as objid,
  0 as idleland,
  0 as totallandbmv,
  0 as totallandmv,
  0 as totallandav,
  0 as totalplanttreebmv,
  0 as totalplanttreemv,
  0 as totalplanttreeadjustment,
  0 as totalplanttreeav,
  0 as landvalueadjustment,
  0 as publicland,
  null as distanceawr,
  null as distanceltc
from 
	rptis.p_ar a, 
	rptis.h_property_info p
where p.trans_stamp = a.trans_stamp
;



/* LAND DETAIL */

alter table rptis.d_land_appraisal 
	add xoid varchar(50)
;

create unique index ux_oid on rptis.d_land_appraisal (xoid)
;

update rptis.d_land_appraisal set xoid = md5(concat(rand(),line_no))
;


delete from  training_etracs255.landdetail
;

insert into training_etracs255.landdetail (
  objid,
  landrpuid,
  subclass_objid,
  specificclass_objid,
  actualuse_objid,
  stripping_objid,
  striprate,
  areatype,
  addlinfo,
  area,
  areasqm,
  areaha,
  basevalue,
  unitvalue,
  taxable,
  basemarketvalue,
  adjustment,
  landvalueadjustment,
  actualuseadjustment,
  marketvalue,
  assesslevel,
  assessedvalue,
  landspecificclass_objid
)
select 
  a.xoid as objid,
  p.trans_stamp landrpuid,
  uv.xobjid as subclass_objid,
  uv.xspcid as specificclass_objid,
  (select objid from training_etracs255.landassesslevel where objid = al.xobjid) as actualuse_objid,
  null as stripping_objid,
  0 as striprate,
  case when a.class_group = 'A' then 'HA' else 'SQM' end areatype,
  null as addlinfo,
  case when a.class_group = 'A' then a.area else a.area * 10000 end as area,
  a.area * 10000 as areasqm,
  a.area as areaha,
  a.unit_value / 10000 as basevalue,
  a.unit_value / 10000 as unitvalue,
  case when a.taxability_type = 'T' then 1 else 0 end taxable,
  case when a.class_group = 'A' then a.area else a.area * 10000 end * a.unit_value / 10000 as basemarketvalue,
  0 as adjustment,
  0 as landvalueadjustment,
  0 as actualuseadjustment,
  a.market_value as marketvalue,
  0 as assesslevel,
  0 as assessedvalue,
  c.xobjid as landspecificclass_objid
from 
	rptis.h_property_info p,
	rptis.d_land_appraisal a, 
	rptis.m_assessment_levels al,
	rptis.m_classification c,
	rptis.m_unit_value uv
where p.trans_stamp = a.trans_stamp
and a.actual_use = al.class_code
and p.prop_type_code = al.prop_type_code
and p.prop_type_code = 'L'
and a.class_code = c.class_code
and a.class_code = uv.class_code 
and a.class_level_code = uv.class_level_code 
;


/* TODO: WHY UNIT VALUE IS LARGE */