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
  (select objid from training_etracs255.lcuvsubclass where objid = uv.xobjid) as subclass_objid,
  (select objid from training_etracs255.lcuvspecificclass where objid = uv.xspcid) as specificclass_objid,
  (select objid from training_etracs255.landassesslevel where objid = al.xobjid) as actualuse_objid,
  null as stripping_objid,
  0 as striprate,
	case when a.class_group = 'A' then 'HA' else 'SQM' end areatype,
  null as addlinfo,
  case when a.class_group = 'A' then a.area else a.area * 10000 end as area,
	a.area * 10000 as areasqm,
  a.area as areaha,
  case when a.class_group = 'A' then a.unit_value else a.unit_value / 10000 end as basevalue,
  case when a.class_group = 'A' then a.unit_value else a.unit_value / 10000 end as unitvalue,
  case when a.taxability_type = 'T' then 1 else 0 end taxable,
  a.area * a.unit_value as basemarketvalue,
  0 as adjustment,
  0 as landvalueadjustment,
  0 as actualuseadjustment,
  a.market_value as marketvalue,
  0 as assesslevel,
  0 as assessedvalue,
  c.class_code as landspecificclass_objid
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
and exists(select * from training_etracs255.rpu where objid = p.trans_stamp)
;


/* UPDATE RPU TOTAL BMV */

drop table if exists rptis.zztmp_rpu_totals
;


create table rptis.zztmp_rpu_totals
as 
select 
	landrpuid,
	sum(basemarketvalue) as totalbmv
from training_etracs255.landdetail 
group by landrpuid
;


update training_etracs255.rpu r, rptis.zztmp_rpu_totals z set 
	r.totalbmv = z.totalbmv
where r.objid = z.landrpuid
;

update training_etracs255.landrpu r, rptis.zztmp_rpu_totals z set 
	r.totallandbmv = z.totalbmv
where r.objid = z.landrpuid
;



/* UPDATE RPU CLASSIFICATION BASED ON DOMINANT AREA*/

drop table if exists rptis.zztmp_rpu_totalarea_byclass
;


create table rptis.zztmp_rpu_totalarea_byclass
as 
select 
	ld.landrpuid,
	al.classification_objid,
	sum(ld.areasqm) as areasqm
from training_etracs255.landdetail ld, training_etracs255.landassesslevel al 
where ld.actualuse_objid = al.objid 
and al.classification_objid is not null 
group by landrpuid, al.classification_objid
;

create index ix_rpuid on rptis.zztmp_rpu_totalarea_byclass(landrpuid)
;

drop table if exists rptis.zztmp_rpu_dominant_area
;

create table rptis.zztmp_rpu_dominant_area
as 
select 
	landrpuid,
	sum(areasqm) as maxarea
from rptis.zztmp_rpu_totalarea_byclass
group by landrpuid
;


create index ix_rpuid on rptis.zztmp_rpu_dominant_area(landrpuid)
;

/* UPDATE CLASSIFICATION BASE ON DOMINANT AREA*/
update 
	training_etracs255.rpu r,  
	rptis.zztmp_rpu_totalarea_byclass c,
	rptis.zztmp_rpu_dominant_area a
set 
	r.classification_objid = c.classification_objid 
where r.objid = c.landrpuid 
and r.objid = a.landrpuid 
and c.areasqm = a.maxarea
;


update training_etracs255.faas_list fl, training_etracs255.rpu r set 
	fl.classification_objid = r.classification_objid
where fl.rpuid = r.objid
;


update training_etracs255.faas_list fl, training_etracs255.rpu r set 
	fl.classification_objid = r.classification_objid,
	fl.classcode = r.classification_objid
where fl.rpuid = r.objid
;

