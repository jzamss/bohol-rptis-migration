/* LAND SMV */


/*=================================================
IMPORTANT !!!  
    PLEASE SET BEFORE EXECUTING:
      @revisionyear
      @municipalcode
=================================================*/

set @revisionyear = 2016;
set @municipalcode = 42;


insert ignore into training_etracs255.landrysetting(
  objid,
  state,
  ry,
  appliedto,
  previd,
  remarks,
  ordinanceno,
  ordinancedate
)
select
  concat('LR:',municipal_code,':', @revisionyear) as objid,
  'APPROVED' as state,
  @revisionyear as ry,
  m.municipal_desc as appliedto,
  null as previd,
  null as remarks,
  '' as ordinanceno,
  null as ordinancedate
from rptis_talibon.m_municipality m
where m.municipal_code = @municipalcode
;



update rptis_talibon.m_assessment_levels set municipal_code = @municipalcode
;


insert ignore into training_etracs255.landassesslevel(
  objid,
  landrysettingid,
  classification_objid,
  code,
  name,
  fixrate,
  rate,
  previd
)
select
  concat('LRA:',@municipalcode,':', @revisionyear, line_no) as objid,
  concat('LR:',@municipalcode,':', @revisionyear) as landrysettingid,
  c.class_group as classification_objid,
  c.class_code as code,
  c.class_desc as name,
  case when a.value_from is null then 1 else 0 end as fixrate,
  a.assessment_level as rate,
  null as previd
from rptis_talibon.m_assessment_levels a, rptis_talibon.m_classification c 
where a.class_code = c.class_code
and a.prop_type_code = 'L'
and municipal_code = @municipalcode
;

alter table rptis_talibon.m_assessment_levels 
	add objid varchar(50)
;

update 
	rptis_talibon.m_assessment_levels a, 
	rptis_talibon.m_classification c
set 
  a.objid = concat('LRA:',@municipalcode,':', @revisionyear, line_no)
where a.class_code = c.class_code
and a.prop_type_code = 'L'
and municipal_code = @municipalcode
;



insert ignore into training_etracs255.lcuvspecificclass(
  objid,
  landrysettingid,
  classification_objid,
  areatype,
  previd,
  landspecificclass_objid
)
select
  concat('LRSPC:',@municipalcode,':', @revisionyear, ':', class_code) as objid,
  concat('LR:',@municipalcode,':', @revisionyear) as landrysettingid,
  class_group as classification_objid,
  case when class_group = 'A' then 'HA' else 'SQM' end  areatype,
  null as previd,
  class_code as  landspecificclass_objid
from rptis_talibon.m_classification
;


alter table rptis_talibon.m_classification 
	add objid varchar(50)
;

update rptis_talibon.m_classification set 
  objid = concat('LRSPC:',@municipalcode,':', @revisionyear, ':', class_code)
;



insert ignore into training_etracs255.lcuvsubclass(
  objid,
  specificclass_objid,
  landrysettingid,
  code,
  name,
  unitvalue,
  previd
)
select
  concat('LRSUB:',@municipalcode,':', @revisionyear, ':', c.sub_class_code, ':', v.class_level_code) as objid,
	concat('LRSPC:',@municipalcode,':', @revisionyear, ':', c.class_code) as specificclass_objid,
  concat('LR:',@municipalcode,':', @revisionyear) as landrysettingid,
  concat(c.sub_class_code, substring(v.class_level_code, 1,1)) as code,
  concat(v.class_level_code, ' CLASS') as name,
  v.class_level_amt as unitvalue,
  null as previd
from rptis_talibon.m_classification c
inner join rptis_talibon.m_unit_value v on c.class_code = v.class_code
;

alter table rptis_talibon.m_unit_value 
	add objid varchar(50),
	add spcid varchar(50)
;

update 
	rptis_talibon.m_classification c,
	rptis_talibon.m_unit_value v 
set 
  v.objid = concat('LRSUB:',@municipalcode,':', @revisionyear, ':', c.sub_class_code, ':', v.class_level_code),
	v.spcid = concat('LRSPC:',@municipalcode,':', @revisionyear, ':', c.class_code)
where c.class_code = v.class_code
;
