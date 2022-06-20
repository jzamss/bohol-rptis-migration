/* MACHINERY SMV */


/*=================================================
IMPORTANT !!!  
    PLEASE SET BEFORE EXECUTING:
      @revisionyear
      @municipalcode
=================================================*/

set @revisionyear = 2016;
set @municipalcode = 42;


insert ignore into training_etracs255.machrysetting(
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
  concat('MR:',municipal_code,':', @revisionyear) as objid,
  'APPROVED' as state,
  @revisionyear as ry,
  m.municipal_desc as appliedto,
  null as previd,
  null as remarks,
  '' as ordinanceno,
  null as ordinancedate
from rptis.m_municipality m
where m.municipal_code = @municipalcode
;


insert ignore into training_etracs255.machassesslevel(
  objid,
  machrysettingid,
  classification_objid,
  code,
  name,
  fixrate,
  rate,
  previd
)
select distinct 
  concat('MRA:',@municipalcode,':', @revisionyear, ':', a.class_code) as objid,
  concat('MR:',@municipalcode,':', @revisionyear) as landrysettingid,
  c.class_group as classification_objid,
  c.class_code as code,
  c.class_desc as name,
  1 as fixrate,
  assessment_level * 100 as rate,
  null as previd
from rptis.m_assessment_levels a, rptis.m_classification c 
where a.class_code = c.class_code
and a.prop_type_code = 'M'
and municipal_code = @municipalcode
;


update rptis_talibon.m_assessment_levels a, rptis_talibon.m_classification c set 
  a.objid = concat('MRA:',@municipalcode,':', @revisionyear, ':', a.class_code) 
where a.class_code = c.class_code
and a.prop_type_code = 'M'
and municipal_code = @municipalcode
;


insert ignore into training_etracs255.rysetting_lgu(
  objid,
  rysettingid,
  lguid,
  settingtype,
  barangayid,
  lguname
)
select  
  objid,
  objid as rysettingid,
  (select objid from training_etracs255.municipality) as lguid,
  'mach' as settingtype,
  null as barangayid,
  (select name from training_etracs255.municipality) as lguname
from training_etracs255.machrysetting
;

