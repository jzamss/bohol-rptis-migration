/* MACHINERY SMV */


/*=================================================
IMPORTANT !!!  
    PLEASE SET BEFORE EXECUTING:
      @revisionyear
      @municipalcode
      @municlass
=================================================*/

set @revisionyear = 2016;
set @municipalcode = 42;
set @municlass = '1ST';


delete from training_etracs255.rysetting_lgu 
where lguid like concat('%', @municipalcode)
and settingtype = 'mach';

delete from training_etracs255.machforex;
delete from training_etracs255.machassesslevelrange;
delete from training_etracs255.machassesslevel;
delete from training_etracs255.machrysetting;


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
  concat('MR:',@municlass,':', @revisionyear) as objid,
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
  concat('MRA:',@municlass,':', @revisionyear, ':', a.class_code) as objid,
  concat('MR:',@municlass,':', @revisionyear) as machrysetting,
  c.class_group as classification_objid,
  c.class_code as code,
  c.class_desc as name,
  1 as fixrate,
  assessment_level * 100 as rate,
  null as previd
from rptis_talibon.m_assessment_levels a, rptis_talibon.m_classification c 
where a.class_code = c.class_code
and a.prop_type_code = 'M'
and municipal_code = @municipalcode
;


update rptis_talibon.m_assessment_levels a, rptis_talibon.m_classification c set 
  a.objid = concat('MRA:',@municlass,':', @revisionyear, ':', a.class_code)
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


